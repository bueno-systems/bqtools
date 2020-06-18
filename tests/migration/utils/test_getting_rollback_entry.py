import pytest
import tempfile
from os import path
from bqtools.migration.utils import get_rollback_entry


def test_getting_rollback_entry():
    '''
    retrieves undo entry correctly
    '''
    with tempfile.TemporaryDirectory() as directory:
        v = 'V1.2.3.4__.sql'
        u = 'U1.2.3.4__.sql'
        with open(path.join(directory, v), 'w'):
            pass
        with open(path.join(directory, u), 'w'):
            pass
        assert get_rollback_entry(v, directory) == u


def test_getting_false_not_exist():
    '''
    retrieves false if there is no undo entry
    '''
    with tempfile.TemporaryDirectory() as directory:
        v = 'V1.2.3.4__.sql'
        with open(path.join(directory, v), 'w'):
            pass
        assert get_rollback_entry(v, directory) == False


def test_getting_false_invalid_entry():
    '''
    retrieves false if entry is not valid
    '''
    with tempfile.TemporaryDirectory() as directory:
        v = 'V1.2.3.4.sql'
        assert get_rollback_entry(v, directory) == False
