import pytest
from os import environ
from bqtools.migration.setup import client


def test_connected_project():
    """
    client is using correct cloud project
    """
    assert client.project == environ['GOOGLE_CLOUD_PROJECT']
