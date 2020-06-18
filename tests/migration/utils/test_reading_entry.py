import pytest
import tempfile
from os import path
from bqtools.migration.utils import read_entry


def test_reading_entry():
    '''
    reads the content of an entry
    '''
    with tempfile.TemporaryDirectory() as directory:
        with open(path.join(directory, 'file.sql'), 'w') as file:
            file.write('test')

        content = read_entry('file.sql', directory=directory)
        assert content == 'test'

        with pytest.raises(FileNotFoundError):
            read_entry('whatever.sql', directory=directory)
