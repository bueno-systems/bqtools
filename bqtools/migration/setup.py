from google.cloud import bigquery
from .config import DATASET, TABLE, LOCATION


client = bigquery.Client()


def create_history_dataset():
    '''
    Create the base dataset on specified geographic location. Ignores if already exists.
    '''
    dataset = bigquery.Dataset(DATASET)
    dataset.location = LOCATION
    dataset = client.create_dataset(dataset, exists_ok=True)
    print("The dataset `{}` is up.".format(DATASET))


def delete_history_dataset():
    '''
    Delete the base dataset. Ignores if not found.
    '''
    dataset = bigquery.Dataset(DATASET)
    dataset = client.delete_dataset(
        dataset, delete_contents=True, not_found_ok=True)
    print("The dataset `{}` is down.".format(DATASET))


def create_history_table():
    '''
    Create the schema history table. Ignores if already exists.
    '''
    schema = [
        bigquery.SchemaField("type", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("version", "STRING", mode="NULLABLE"),
        bigquery.SchemaField("description", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("slot_millis", "INTEGER", mode="NULLABLE"),
        bigquery.SchemaField("success", "BOOL", mode="REQUIRED"),
        bigquery.SchemaField("installed_at", "TIMESTAMP", mode="REQUIRED"),
        bigquery.SchemaField("entry", "STRING", mode="REQUIRED"),
        bigquery.SchemaField("checksum", "STRING", mode="REQUIRED")
    ]
    table = bigquery.Table(TABLE, schema=schema)
    table = client.create_table(table, exists_ok=True)
    print("The schema history table `{}` is up.".format(TABLE))


def delete_history_table():
    '''
    Delete the schema history table. Ignores if not found.
    '''
    client.delete_table(TABLE, not_found_ok=True)
    print("The schema history table `{}` is down.".format(TABLE))
