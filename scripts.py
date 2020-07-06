import subprocess
import sys


def pytest():
    subprocess.run(
        ['python', '-m', 'pytest', '--pspec', 'tests/', '-s'] + sys.argv[1:]
    )


def autopep8():
    subprocess.run(
        ['python', '-m', 'autopep8', '-i', '-r', '-a', '-a', '.']
    )
