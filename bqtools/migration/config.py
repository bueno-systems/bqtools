from os import path, environ, getcwd


DIRECTORY = path.join(getcwd(), 'migrations')
DATASET = '{}.{}'.format(environ['GOOGLE_CLOUD_PROJECT'], 'bqhistory')
TABLE = '{}.{}'.format(DATASET, 'schema_history')
LOCATION = environ['GOOGLE_CLOUD_LOCATION'] if environ['GOOGLE_CLOUD_LOCATION'] is not None else 'australia-southeast1'
SEPARATOR = '__'
EXTENSION = '.sql'
