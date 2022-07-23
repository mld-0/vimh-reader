#!/usr/bin/env python3
#   {{{3
#   vim: set tabstop=4 modeline modelines=10:
#   vim: set foldlevel=2 foldcolumn=2 foldmethod=marker:
#   {{{2
import sys
import os
import logging
import datetime
import dateutil
import pandas as pd
import pprint
logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)
#   Ongoings:
#   {{{
#   Ongoing: 2022-07-24T00:37:00AEST when/where to modify df in place versus return modified copy?
#   Ongoing: 2022-07-24T00:38:03AEST df rows are called records?
#   Ongoing: 2022-07-24T02:43:38AEST 'apply(strptime)' is faster than 'pd.to_datetime()'?
#   }}}

path_input = os.path.join(os.getenv('HOME'), '.vimh')
assert os.path.isfile(path_input)

def countUniquePerDayByColumn(df: pd.DataFrame, col: int) -> pd.DataFrame:
    """Group by day and count unique values in a given column"""


def groupByDay(df: pd.DataFrame):
    ...


def filterLastUniqueByColumn(df: pd.DataFrame, col: int) -> pd.DataFrame:
    """Keep only records which have the last instance of each given unique value in a given column"""

def substituteHomeStr(df: pd.DataFrame) -> pd.DataFrame:
    """Replaces instances of '$HOME' with '~' in df"""


def filterEmptyByCol(df: pd.DataFrame, col: int):
    """Remove records where value in given column is empty (NaN)"""
    #   (in-place?)

def parseDateTimes(df: pd.DataFrame, col: str):
    """Convert column containing strings to iso-datetimes"""
    _fmt = "%Y-%m-%dT%H:%M:%S%z"
    df[col] = pd.to_datetime(df[col].apply(lambda x: datetime.datetime.strptime(x, _fmt)), utc=True)

def splitDateTimes(df: pd.DataFrame):
    """Replace 'datetime' column with 'date' and 'time' columns"""
    df.insert(0, 'date', df['datetime'].dt.date)
    df.insert(1, 'time', df['datetime'].dt.time)
    df.drop('datetime', axis=1, inplace=True)

def read_vimh_df(path_input: str) -> pd.DataFrame:
    columns = _getVimhColumns()
    df = pd.read_csv(path_input, delimiter='\t', names=columns)

    parseDateTimes(df, 'datetime')
    splitDateTimes(df)

    logging.debug("df=(%s)" % df)
    return df

def _getVimhColumns():
    return [ 'datetime', 'filename', 'host', 'action', 'filepath', 'realpath', ]

def runCountUniquePathsPerDay():
    df = read_vimh_df(path_input)

def runFilterLastUniquePaths():
    raise NotImplementedError()


if __name__ == '__main__':
    runCountUniquePathsPerDay()

