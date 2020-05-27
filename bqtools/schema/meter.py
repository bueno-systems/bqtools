import os
from google.cloud import bigquery

client = bigquery.Client()

def create_or_replace():
    project_id = os.environ['GOOGLE_CLOUD_PROJECT']
    dataset_id = 'bqstudio'

    directory = os.path.dirname(os.path.realpath(__file__))
    with open('{}/meter.sql'.format(directory), 'r') as file :
        sql_content = file.read()

    sql = (
        sql_content
        .replace('{{ project_id }}', project_id)
        .replace('{{ dataset_id }}', dataset_id)
    )
    client.query(sql)
