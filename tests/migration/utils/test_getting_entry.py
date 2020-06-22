import pytest
import tempfile
from os import path
from bqtools.migration.utils import get_undo_entry, get_regular_entry


def test_getting_undo_entry():
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
        assert get_undo_entry(v, directory) == u


def test_getting_regular_entry():
    '''
    retrieves regular entry correctly
    '''
    with tempfile.TemporaryDirectory() as directory:
        v = 'V1.2.3.4__.sql'
        u = 'U1.2.3.4__.sql'
        with open(path.join(directory, v), 'w'):
            pass
        with open(path.join(directory, u), 'w'):
            pass
        assert get_regular_entry(u, directory) == v


def test_getting_false_not_exist():
    '''
    retrieves false if there is no opposite entry
    '''
    with tempfile.TemporaryDirectory() as directory:
        v = 'V1.2.3.4__valid.sql'
        with open(path.join(directory, v), 'w'):
            pass
        assert get_undo_entry(v, directory) == False

    with tempfile.TemporaryDirectory() as directory:
        u = 'U1.2.3.4__valid.sql'
        with open(path.join(directory, u), 'w'):
            pass
        assert get_regular_entry(u, directory) == False


def test_getting_false_invalid_entry():
    '''
    retrieves false if the entry is invalid
    '''
    with tempfile.TemporaryDirectory() as directory:
        assert get_undo_entry('V1.2.3.4invalid.sql', directory) == False
        assert get_regular_entry('U1.2.3.4invalid.sql', directory) == False
