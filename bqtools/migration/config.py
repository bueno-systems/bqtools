from os import path, environ, getcwd


DIRECTORY = path.join(getcwd(), 'migrations')
DATASET = '{}.{}'.format(environ['GOOGLE_CLOUD_PROJECT'], 'bqtools')
TABLE = '{}.{}'.format(DATASET, 'schema_history')
LOCATION = environ.get('GOOGLE_CLOUD_LOCATION', 'australia-southeast1')
SEPARATOR = '__'
EXTENSION = '.sql'
