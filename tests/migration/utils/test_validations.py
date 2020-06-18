import pytest
from bqtools.migration.utils import is_valid, is_regular, is_undo, is_repeatable


def test_valid_entry():
    '''
    invalidates the naming pattern of an entry
    '''
    assert is_valid('V1__') == False
    assert is_valid('whatever') == False
    assert is_valid('__') == False
    assert is_valid('V1__description.md') == False
    assert is_valid('U1.3_description.sql') == False
    assert is_valid('V1__') == False


def test_invalid_entry():
    '''
    validates the naming pattern of an entry
    '''
    assert is_valid('V1__.sql')
    assert is_valid('U1__.sql')
    assert is_valid('R__.sql')
    assert is_valid('R1__.sql')


def test_valid_regular_entry():
    '''
    validates a regular entry
    '''
    assert is_regular('V1__.sql')
    assert is_regular('U1__.sql') == False
    assert is_regular('R__.sql') == False


def test_valid_undo_entry():
    '''
    validates an undo entry
    '''
    assert is_undo('V1__.sql') == False
    assert is_undo('U1__.sql')
    assert is_undo('R__.sql') == False


def test_valid_repeatable_entry():
    '''
    validates a repeatable entry
    '''
    assert is_repeatable('V1__.sql') == False
    assert is_repeatable('U1__.sql') == False
    assert is_repeatable('R__.sql')
