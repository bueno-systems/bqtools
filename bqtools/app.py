from bqtools.functions import all as funcs
from google.cloud import bigquery

# @TODO: implement a migration mechanism
def run():
    funcs.create_or_replace()
