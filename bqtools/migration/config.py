from os import path, environ, getcwd


DIRECTORY = path.join(
    getcwd(),
    environ.get(
        'MIGRATIONS_DIRECTORY',
        'migrations'))
DATASET = '{}.{}'.format(environ['GOOGLE_CLOUD_PROJECT'], 'bqtools')
TABLE = '{}.{}'.format(DATASET, environ.get('MIGRATIONS_HISTORY_TABLE', 'schema_history'))
LOCATION = environ.get('GOOGLE_CLOUD_LOCATION', 'australia-southeast1')
SEPARATOR = '__'
EXTENSION = '.sql'

