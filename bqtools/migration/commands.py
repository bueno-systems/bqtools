from .setup import create_dataset, create_history_table, delete_history_table
from .utils import list_entries, commit


def migrate():
    """
    Migrate all of the migrations and update the schema history.
    Within a single migration run, repeatable migrations are always applied last
    """
    try:
        create_dataset()
        create_history_table()
        entries = list_entries()
        for entry in entries:
            commit(entry)
    except Exception as e:
        print('Migration stopped.')
        print('ERROR: {}'.format(e))
        quit(1)


def rollback():
    """
    Roll back all of the migrations, then destroy the schema history table.
    All undo entries `U` will be queried in reverse order.
    ONLY use if you have provided appropriate undos for all versioned migrations.
    """
    try:
        entries = list_entries(reverse=True)
        for entry in entries:
            commit(entry, rollback=True)
        reset()
    except Exception as e:
        print('Rollback stopped.')
        print('ERROR: {}'.format(e))
        quit(2)


def refresh():
    """
    Roll back everything first and then migrate from the beginning.
    """
    rollback()
    migrate()


def reset():
    """
    Destroy the schema history table.
    """
    try:
        delete_history_table()
    except Exception as e:
        print('ERROR: {}'.format(e))
        quit(3)
