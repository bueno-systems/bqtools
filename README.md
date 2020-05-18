# BQtools

Bueno-defined persistent functions/scripts on BigQuery by using SQL expressions or JavaScript

## Prerequisites
* [Pyenv](https://github.com/pyenv/pyenv) version manager
* [Poetry](https://python-poetry.org/) packaging and dependency manager

## Internal Repository

Store the credentials of nexus internal repository. If you do not specify the password, you will be prompted to enter.
```
❯ poetry config http-basic.bueno username password
```

## Setup Virtual Environment

Install the Python version using `pyenv`.
```
❯ pyenv install 3.8.2
```
Additionaly, you can set the local application-specific Python version into `.python-version'.
```
❯ pyenv local 3.8.2
```

## Resolve Dependencies

Create and activate the virtual environment inside the project's root under `.venv` directory and then install all the dependencies.
```
❯ poetry install
```

Virtual env has been set to be in project. Check out `poetry.toml`.

## Run

Run the app and tests like so:

```
❯ poetry run app
```
```
❯ poetry run test
```


## Additional Help

### Define Commands

The Poetry run command will execute the given command inside the project's virtualenv.
```
❯ poetry run python -V
Python 3.8.2
```

A new custom command can be defined under `[tool.poetry.scripts]` in `pyproject.toml` file as below:
```
[tool.poetry.scripts]
my-script = "my_module:main"
```
You can execute it like so:
```
❯ poetry run my-script
```

### Add Dependencies

Add more dependencies from external or internal repos:
```
❯ poetry add pybueno
❯ poetry add pendulum@^2.0.5
```

### For more help
```
❯ poetry -h
```
