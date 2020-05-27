import pytest
import os
from google.cloud import bigquery


client = bigquery.Client()


def test_connected_project():
    assert client.project == os.environ['GOOGLE_CLOUD_PROJECT']


def test_required_datasets():
    client = bigquery.Client()
    available = list(map(lambda dataset: dataset.dataset_id, client.list_datasets()))
    required = ['reports', 'bqtools']
    assert all(item in available for item in required) == True
