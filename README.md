# BQtools

Bueno-defined persistent functions/scripts on BigQuery by using SQL expressions or JavaScript

## Prerequisites
* [Pyenv](https://github.com/pyenv/pyenv) version manager
* [Poetry](https://python-poetry.org/) packaging and dependency manager
* [Direnv](https://direnv.net/) for loading environment variables

## Setup

### Internal Repository Credentials

Store the credentials of nexus internal repository. If you do not specify the password, you will be prompted to enter.
```
❯ poetry config http-basic.bueno <username> <password>
```

### Python Versions

Install the application-specific Python versions (defined in `.python-version` file).
```
❯ pyenv install
```

### Resolve Dependencies

Create a virtual environment locally if there is no one and install all the dependencies.
```
❯ poetry install
```

**Note:** Poetry has been configured to create virtual environment inside the project's root directory under `.venv`. You may need to set Python interpreter as `.venv/bin/python` in your editor if the packages are still unresolved.

### Load Environment Variables

Make a copy of `.envrc.example` as `.envrc` file in root directory and set variables. Then run:
```
❯ direnv allow .
```

## Run

Run the app and tests like so:

```
❯ poetry run app
```
```
❯ poetry run test
```

## Additional Help

### Set Python Versions

Set the local application-specific Python versions into `.python-version`.
```
❯ pyenv local 3.8.2 3.7.7
```

### Add Dependencies

Add more dependencies from external or internal repos.
```
❯ poetry add pybueno
❯ poetry add pendulum@^2.0.5
```

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

### Poetry Help

Check out Poetry [docs](https://python-poetry.org/docs/) or execute:
```
❯ poetry -h
```
