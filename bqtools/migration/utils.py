from os import walk, path
from hashlib import blake2b
from google.cloud import bigquery
from .types import Prefix
from .setup import client
from .config import DIRECTORY, TABLE, SEPARATOR, EXTENSION, LOCATION


def query(entry, location=LOCATION, directory=DIRECTORY):
    '''
    Run a query job for a migration entry and mark that as done if there is no error.
    '''
    sql = read_entry(entry, directory)
    job = client.query(sql, location=location)
    job.add_done_callback(lambda future: mark(
        entry,
        future.slot_millis,
        not future.exception()
    ))
    job.result()


def commit(entry, rollback=False):
    '''
    Commit or roll back a regular entry `V`.
    This method only accepts a regular or repeatable entry, `V` or `R`.
    If rollback flag is set to True, the matched undo entry `U` will be committed instead.
    '''
    if is_undo(entry) or (rollback and not is_done(entry)):
        return

    target = get_undo_entry(entry) if rollback else entry
    if target and not is_done(target):
        print('{} {}'.format('ROLLING BACK' if rollback else 'RUNNING', target))
        query(target)


def mark(entry, slot_millis, done=False, location=LOCATION, table=TABLE):
    '''
    Mark an entry as succeeded or failed.
    '''
    parts = get_parts(entry)
    job_config = bigquery.QueryJobConfig(
        query_parameters=[
            bigquery.ScalarQueryParameter('type', 'STRING', parts['prefix']),
            bigquery.ScalarQueryParameter('version', 'STRING', parts['version']),
            bigquery.ScalarQueryParameter('description', 'STRING', parts['description']),
            bigquery.ScalarQueryParameter('slot_millis', 'INTEGER', slot_millis),
            bigquery.ScalarQueryParameter('success', 'BOOL', done),
            bigquery.ScalarQueryParameter('entry', 'STRING', entry),
            bigquery.ScalarQueryParameter('checksum', 'STRING', get_checksum(entry))
        ]
    )

    query = '''
        INSERT INTO {} VALUES
        (@type, @version, @description, @slot_millis, @success, CURRENT_TIMESTAMP(), @entry, @checksum)
    '''.format(table)
    client.query(query, job_config=job_config, location=location).result()
    print('{}'.format('DONE' if done else 'FAILED'))


def list_entries(reverse=False, directory=DIRECTORY):
    '''
    Read valid entries from migrations directory.
    Undo entries `U` will not be read here. An undo entry is read and committed when a rollback for regular entry is needed.
    The reverse flag sorts regular entries in reverse order which is suitable for full rollback.
    Repeatable entries `R` come last if reverse flag is off and they are always committed last.
    '''
    entries = []
    for (_, _, filenames) in walk(directory):
        entries.extend(filenames)
        break

    regular = sorted(
        [entry for entry in entries if is_regular(entry)], reverse=reverse)
    if reverse:
        return regular

    repeatable = sorted([entry for entry in entries if is_repeatable(entry)])

    return regular + repeatable  # repeatable entries are always commited last


def read_entry(entry, directory=DIRECTORY):
    '''
    Read the content of a migration entry.
    '''
    filepath = get_path(entry, directory)
    with open(filepath, 'r') as file:
        sql = file.read()

    return sql


def get_path(entry, directory):
    '''
    Get the full file path of an entry.
    '''
    return '{}/{}'.format(directory, entry)


def get_regular_entry(entry, directory=DIRECTORY):
    '''
    Check whether an entry has a regular version or not.
    Returns regular entry if there is one or False otherwise.
    '''
    if not is_undo(entry):
        return False
    entry = Prefix.V.name + entry[1:]
    if path.isfile(get_path(entry, directory)):
        return entry
    return False


def get_undo_entry(entry, directory=DIRECTORY):
    '''
    Check whether an entry has an undo version or not.
    Returns undo entry if there is one or False otherwise.
    '''
    if not is_regular(entry):
        return False
    undo_entry = Prefix.U.name + entry[1:]
    if path.isfile(get_path(undo_entry, directory)):
        return undo_entry
    return False


def get_checksum(entry, directory=DIRECTORY):
    '''
    Retrieve a checksum value of file content to store on schema history.
    The checksum is there to detect accidental changes in a file.
    '''
    with open(get_path(entry, directory), 'rb') as file:
        data = file.read()
        checksum = blake2b(data).hexdigest()
    return checksum


def get_parts(entry):
    '''
    Retrieve parts of the naming pattern for validation.
    '''
    dic = {}
    if not is_valid(entry):
        return False

    filename, extension = path.splitext(entry)
    initial, description = filename.split(SEPARATOR)
    prefix = initial[:1].upper()
    version = None
    if prefix == Prefix.V.name or prefix == Prefix.U.name:
        version = initial[1:]

    dic['description'] = description.replace('_', ' ')
    dic['prefix'] = prefix
    dic['version'] = version
    dic['suffix'] = extension

    return dic


def is_done(entry, table=TABLE):
    '''
    Check whether a regular entry `V` or repeatable entry `R` has been already committed or not.
    Repeatable entry is re-applied only when its checksum changes.
    '''
    checksum = get_checksum(entry)
    parts = get_parts(entry)

    query = '''
        SELECT `success`, `checksum` FROM {}
        WHERE `entry` = @entry AND `success` = TRUE AND `type` = @type
        ORDER BY `installed_at` DESC
        LIMIT 1
    '''.format(table)
    job_config = bigquery.QueryJobConfig(
        query_parameters=[
            bigquery.ScalarQueryParameter('entry', 'STRING', entry),
            bigquery.ScalarQueryParameter('type', 'STRING', parts['prefix'])
        ]
    )

    rows = client.query(query, job_config=job_config)
    for row in rows:
        if row[0]:
            if checksum == row[1]:
                return True
            elif checksum != row[1] and is_repeatable(entry):
                print('INFO: A change is detected!')
                print('RE-APPLYING {}'.format(entry))
                return False
            elif checksum != row[1] and is_regular(entry):
                print('WARNING: Accidental change is detected!')
                print('Do not change an already commited versioned migration.')
                print('SKIPPING {}'.format(entry))
                return True
    return False


def is_valid(entry):
    '''
    Validate the entry name based on naming pattern.
    '''
    filename, extension = path.splitext(entry)
    if filename.find(SEPARATOR) == -1 or extension != EXTENSION:
        return False

    initial, _ = filename.split(SEPARATOR)
    prefix = initial[:1].upper()
    version = initial[1:]

    if prefix not in list(Prefix.__members__.keys()):
        return False
    if (prefix == Prefix.V.name or prefix == Prefix.U.name) and version == '':
        return False

    return True


def is_regular(entry):
    '''
    Check whether an entry is regular `V` or not.
    '''
    if is_valid(entry) and entry[0].upper() == Prefix.V.name:
        return True
    return False


def is_undo(entry):
    '''
    Check whether an entry is undo `U` or not.
    '''
    if is_valid(entry) and entry[0].upper() == Prefix.U.name:
        return True
    return False


def is_repeatable(entry):
    '''
    Check whether an entry is repeatable `R` or not.
    '''
    if is_valid(entry) and entry[0].upper() == Prefix.R.name:
        return True
    return False
