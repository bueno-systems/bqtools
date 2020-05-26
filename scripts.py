import subprocess


def pytest():
    subprocess.run(
        ['python', '-m', 'pytest', 'tests/', '-v']
    )
