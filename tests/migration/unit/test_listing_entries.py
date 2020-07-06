import pytest
import tempfile
from os import path
from bqtools.migration.utils import list_entries


def test_empty_list():
    """
    returns an empty list when reading directory is empty
    """
    with tempfile.TemporaryDirectory() as directory:
        entries = list_entries(directory=directory)
        assert entries == []


def test_ignoring_anti_patterns():
    """
    ignores all anti-pattern migration entries
    """
    with tempfile.TemporaryDirectory() as directory:
        with open(path.join(directory, 'whatever.sql'), 'w'):
            pass
        with open(path.join(directory, 'whatever.something'), 'w'):
            pass
        with open(path.join(directory, 'R.sql'), 'w'):
            pass
        with open(path.join(directory, 'U__.sql'), 'w'):
            pass
        with open(path.join(directory, 'U1.sql'), 'w'):
            pass
        with open(path.join(directory, 'V__.sql'), 'w'):
            pass
        with open(path.join(directory, 'V1.sql'), 'w'):
            pass

        entries = list_entries(directory=directory)
        assert entries == []


def test_ignoring_undos():
    """
    ignores undo migration entries
    """
    with tempfile.TemporaryDirectory() as directory:
        with open(path.join(directory, 'U1__test.sql'), 'w'):
            pass
        with open(path.join(directory, 'U1.1__test_2.sql'), 'w'):
            pass
        entries = list_entries(directory=directory)
        assert entries == []


def test_sorted_listing():
    """
    retrieves a list of valid regular and repeatable migration entries in order
    """
    with tempfile.TemporaryDirectory() as directory:
        with open(path.join(directory, 'R__2.sql'), 'w'):
            pass
        with open(path.join(directory, 'R__1.sql'), 'w'):
            pass
        with open(path.join(directory, 'V2.1__.sql'), 'w'):
            pass
        with open(path.join(directory, 'V2.2__.sql'), 'w'):
            pass
        with open(path.join(directory, 'V1__.sql'), 'w'):
            pass

        entries = list_entries(directory=directory)
        assert len(entries) == 5
        assert entries[0] == 'V1__.sql'
        assert entries[1] == 'V2.1__.sql'
        assert entries[2] == 'V2.2__.sql'
        assert entries[3] == 'R__1.sql'
        assert entries[4] == 'R__2.sql'


def test_reversed_listing():
    """
    retrieves a list of valid regular migration entries in reverse order
    """
    with tempfile.TemporaryDirectory() as directory:
        with open(path.join(directory, 'R__2.sql'), 'w'):
            pass
        with open(path.join(directory, 'R__1.sql'), 'w'):
            pass
        with open(path.join(directory, 'V2.1__.sql'), 'w'):
            pass
        with open(path.join(directory, 'U2.1__.sql'), 'w'):
            pass
        with open(path.join(directory, 'V2.2__.sql'), 'w'):
            pass
        with open(path.join(directory, 'V1__.sql'), 'w'):
            pass

        entries = list_entries(directory=directory, reverse=True)
        assert len(entries) == 3
        assert entries[0] == 'V2.2__.sql'
        assert entries[1] == 'V2.1__.sql'
        assert entries[2] == 'V1__.sql'
