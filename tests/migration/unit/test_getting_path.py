import pytest
from bqtools.migration.utils import get_path


def test_get_path():
    """
    retrieves the full file path of an entry
    """
    path = get_path('entry', 'directory')
    assert path == 'directory/entry'
