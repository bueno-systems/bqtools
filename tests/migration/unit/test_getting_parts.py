import pytest
from bqtools.migration.utils import get_parts
from bqtools.migration.types import Prefix


def test_getting_false():
    """
    retrieves false for invalid entry
    """
    dic = get_parts('whatever.sql')
    assert dic == False

    dic = get_parts('V1_description.sql')
    assert dic == False


def test_getting_parts():
    """
    retrieves parts of the naming pattern for validation.
    """
    dic = get_parts('V1.2.3__this_is_description.sql')
    assert dic['description'] == 'this is description'
    assert dic['prefix'] == Prefix.V.name
    assert dic['version'] == '1.2.3'
    assert dic['suffix'] == '.sql'

    dic = get_parts('R1.2.3__.sql')
    assert dic['prefix'] == Prefix.R.name
    dic = get_parts('V1.2.3__.sql')
    assert dic['prefix'] == Prefix.V.name
    dic = get_parts('U1.2.3__.sql')
    assert dic['prefix'] == Prefix.U.name


def test_ignoring_version():
    """
    ignores the version for valid repeatable entry
    """
    dic = get_parts('R1.2.3__this_is_description.sql')
    assert dic['description'] == 'this is description'
    assert dic['prefix'] == Prefix.R.name
    assert dic['version'] is None
    assert dic['suffix'] == '.sql'
