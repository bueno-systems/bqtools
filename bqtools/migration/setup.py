from google.cloud import bigquery
from .config import DATASET, TABLE, LOCATION


client = bigquery.Client()


def create_dataset(dataset_id=DATASET, location=LOCATION):
    """
    Create a dataset on specified geographic location. Ignores if already exists.
    """
    dataset = bigquery.Dataset(dataset_id)
    dataset.location = location
    dataset = client.create_dataset(dataset, exists_ok=True)


def delete_dataset(dataset_id=DATASET):
    """
    Delete a dataset. Ignores if not found.
    """
    dataset = bigquery.Dataset(dataset_id)
    client.delete_dataset(dataset, delete_contents=True, not_found_ok=True)


def create_history_table(table_id=TABLE):
    """
    Create the schema history table. Ignores if already exists.
    """
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
    table = bigquery.Table(table_id, schema=schema)
    table = client.create_table(table, exists_ok=True)


def delete_history_table(table_id=TABLE):
    """
    Delete the schema history table. Ignores if not found.
    """
    client.delete_table(table_id, not_found_ok=True)
