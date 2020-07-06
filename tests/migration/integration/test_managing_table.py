import pytest
from os import environ
from google.cloud import bigquery
from bqtools.migration.utils import mark
from bqtools.migration.setup import client, create_dataset, create_history_table, delete_history_table, delete_dataset


def test_managing_table():
    """
    creates and deletes history table
    """

    project_name = environ['GOOGLE_CLOUD_PROJECT']
    dataset_name = 'bqtools'
    table_name = 'schema_history'

    dataset_id = '{}.{}'.format(project_name, dataset_name)
    table_id = '{}.{}'.format(dataset_id, table_name)

    create_dataset(dataset_id)
    dataset = client.get_dataset(dataset_id)
    assert dataset.project == project_name
    assert dataset.dataset_id == dataset_name

    create_history_table(table_id)
    table = client.get_table(table_id)
    assert table.project == project_name
    assert table.dataset_id == dataset_name
    assert table.table_id == table_name

    delete_history_table(table_id)
    with pytest.raises(Exception) as info:
        client.get_table(table_id)
    assert 'Not found' in str(info.value)

    delete_dataset(dataset_id)
    with pytest.raises(Exception) as info:
        client.get_dataset(dataset_id)
    assert 'Not found' in str(info.value)
