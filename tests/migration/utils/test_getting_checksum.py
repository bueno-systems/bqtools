import pytest
import tempfile
from os import path
from bqtools.migration.utils import get_checksum


def test_checksum_equality():
    '''
    retrieves same checksum values for two files with same content
    '''
    with tempfile.TemporaryDirectory() as directory:
        with open(path.join(directory, 'file1.sql'), 'w') as file:
            file.write('content')
        with open(path.join(directory, 'file2.sql'), 'w') as file:
            file.write('content')

        checksum1 = get_checksum('file1.sql', directory=directory)
        checksum2 = get_checksum('file2.sql', directory=directory)
        assert checksum1 == checksum2


def test_checksum_inequality():
    '''
    retrieves different checksum values for two files with different content
    '''
    with tempfile.TemporaryDirectory() as directory:
        with open(path.join(directory, 'file1.sql'), 'w') as file:
            file.write('content1')
        with open(path.join(directory, 'file2.sql'), 'w') as file:
            file.write('content2')

        checksum1 = get_checksum('file1.sql', directory=directory)
        checksum2 = get_checksum('file2.sql', directory=directory)
        assert checksum1 != checksum2
