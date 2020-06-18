from bqtools.migration import commands


def migrate():
    commands.migrate()


def rollback():
    commands.rollback()


def refresh():
    commands.refresh()


def reset():
    commands.reset()
