import subprocess


def pytest():
    subprocess.run(
        ['python', '-u', '-m', 'pytest', 'tests/', '--verbose']
    )
