import pytest
from os import environ
from google.cloud import bigquery
from bqtools.migration.utils import mark, get_checksum
from bqtools.migration.setup import client, create_dataset, create_history_table
from bqtools.migration.commands import migrate


def test_migration():
    """
    migrates all of the migrations and updates the schema history.
    """

    migrate()

    history_table = environ.get('MIGRATIONS_HISTORY_TABLE', 'schema_history')
    table_id = '{}.{}.{}'.format(
        environ['GOOGLE_CLOUD_PROJECT'],
        'bqtools',
        history_table)
    table = client.get_table(table_id)
    assert table.table_id == history_table

    rows = []
    for row in client.list_rows(table_id):
        rows.append([value for index, value in enumerate(
            row) if index not in [3, 5]])

    assert len(rows) == 4

    assert rows[0] == [
        'V',
        '1.1',
        'create fruit table',
        True,
        'V1.1__create_fruit_table.sql',
        get_checksum(
            'V1.1__create_fruit_table.sql',
            directory=environ['MIGRATIONS_DIRECTORY'])]

    assert rows[1] == [
        'V',
        '1.2',
        'create car table',
        True,
        'V1.2__create_car_table.sql',
        get_checksum(
            'V1.2__create_car_table.sql',
            directory=environ['MIGRATIONS_DIRECTORY'])]

    assert rows[2] == [
        'R',
        None,
        'insert one car',
        True,
        'R__insert_one_car.sql',
        get_checksum(
            'R__insert_one_car.sql',
            directory=environ['MIGRATIONS_DIRECTORY'])]

    assert rows[3] == [
        'R',
        None,
        'insert two fruits',
        True,
        'R__insert_two_fruits.sql',
        get_checksum(
            'R__insert_two_fruits.sql',
            directory=environ['MIGRATIONS_DIRECTORY'])]

    table_id = '{}.{}.{}'.format(
        environ['GOOGLE_CLOUD_PROJECT'], 'bqtools', 'fruit')
    table = client.get_table(table_id)
    assert table.table_id == 'fruit'
    rows = list(client.list_rows(table_id))
    assert len(rows) == 2
    assert rows[0][0] == 'Apple'
    assert rows[1][0] == 'Orange'

    table_id = '{}.{}.{}'.format(
        environ['GOOGLE_CLOUD_PROJECT'], 'bqtools', 'car')
    table = client.get_table(table_id)
    assert table.table_id == 'car'
    rows = list(client.list_rows(table_id))
    assert len(rows) == 1
    assert rows[0][0] == 'Ferrari'
