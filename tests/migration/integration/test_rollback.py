import pytest
from os import environ
from google.cloud import bigquery
from bqtools.migration.utils import mark, get_checksum
from bqtools.migration.setup import client, create_dataset, create_history_table
from bqtools.migration.commands import rollback


def test_rollback():
    """
    rolls back all of the migrations and then destroys the schema history table.
    """

    rollback()

    table_id = '{}.{}.{}'.format(
        environ['GOOGLE_CLOUD_PROJECT'], 'bqtools', 'fruit')
    with pytest.raises(Exception) as info:
        client.get_table(table_id)
    assert 'Not found' in str(info.value)

    table_id = '{}.{}.{}'.format(
        environ['GOOGLE_CLOUD_PROJECT'], 'bqtools', 'car')
    with pytest.raises(Exception) as info:
        client.get_table(table_id)
    assert 'Not found' in str(info.value)

    table_id = '{}.{}.{}'.format(
        environ['GOOGLE_CLOUD_PROJECT'],
        'bqtools',
        'schema_history')
    with pytest.raises(Exception) as info:
        client.get_table(table_id)
    assert 'Not found' in str(info.value)
