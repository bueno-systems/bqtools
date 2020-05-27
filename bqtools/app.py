from bqtools.functions import all as funcs
from bqtools.schema import meter
from bqtools.schema import meter_daily
from google.cloud import bigquery

# @TODO: implement a database migration mechanism

def run():
    funcs.create_or_replace()
    meter.create_or_replace()
    meter_daily.create_or_replace()
