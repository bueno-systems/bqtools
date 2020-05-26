import os
from google.cloud import bigquery


def create_or_replace():
    client = bigquery.Client()
    directory = os.path.dirname(os.path.realpath(__file__))

    with open('{}/all.sql'.format(directory), 'r') as file :
        sql_content = file.read()

    sql = sql_content.replace('{{ project_id }}', os.environ['GOOGLE_CLOUD_PROJECT'])

    client.query(sql)
