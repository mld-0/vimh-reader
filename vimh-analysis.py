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
from typing import List
logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)
#   Ongoings:
#   {{{
#   Ongoing: 2022-07-24T00:37:00AEST when/where to modify df in place versus return modified copy?
#   Ongoing: 2022-07-24T00:38:03AEST df rows are called records?
#   Ongoing: 2022-07-24T02:43:38AEST 'apply(strptime)' is faster than 'pd.to_datetime()'?
#   Ongoing: 2022-07-26T22:52:14AEST fast str2dt method(?)
#   }}}

path_input = os.path.join(os.getenv('HOME'), '.vimh')
assert os.path.isfile(path_input)

class VimhAnalysis:

    #   Ongoing: 2022-07-26T22:52:45AEST 'groupByDay()' method -> possible within a df, or return list of df-s?)
    @staticmethod
    def groupByDay(df: pd.DataFrame):
        """"""
        ...


    @staticmethod
    def countUniquePerDayByColumn(df: pd.DataFrame, col: int) -> pd.DataFrame:
        """Group by day and count unique values in a given column"""
        raise NotImplementedError()
    @staticmethod
    def filterLastUniqueByColumn(df: pd.DataFrame, col: int) -> pd.DataFrame:
        """Keep only records which have the last instance of each given unique value in a given column"""
        raise NotImplementedError()
    @staticmethod
    def substituteHomeStr(df: pd.DataFrame, cols: List[int]) -> pd.DataFrame:
        """Replaces instances of '$HOME' with '~' in df (for given columns 'cols') (which must be strings?)"""
        raise NotImplementedError()
    @staticmethod
    def filterEmptyByCol(df: pd.DataFrame, col: int):
        """Remove records where value in given column is empty (NaN) (in-place?)"""
        raise NotImplementedError()


    @staticmethod
    def parseDateTimes(df: pd.DataFrame, col: str):
        """Convert column containing iso-datetime strings to 'date' and 'time' columns"""
        def convertStringToDateTime(df: pd.DataFrame):
            iso_fmt = "%Y-%m-%dT%H:%M:%S%z"
            str2dt = lambda x: datetime.datetime.strptime(x, iso_fmt)
            df[col] = pd.to_datetime(df[col].apply(str2dt), utc=True)
        def splitDateTimeColumn(df: pd.DataFrame):
            df.insert(0, 'date', df['datetime'].dt.date)
            df.insert(1, 'time', df['datetime'].dt.time)
            df.drop(col, axis=1, inplace=True)
        convertStringToDateTime(df)
        splitDateTimeColumn(df)


    #   Continue: 2022-07-26T22:50:06AEST pd.read_csv -> limit to last N lines?
    @staticmethod
    def read_vimh_df(path_input: str) -> pd.DataFrame:
        columns = [ 'datetime', 'filename', 'host', 'action', 'filepath', 'realpath', ]
        df = pd.read_csv(path_input, delimiter='\t', names=columns)
        VimhAnalysis.parseDateTimes(df, 'datetime')
        logging.debug("df=(%s)" % df)
        return df



def runCountUniquePathsPerDay():
    df = VimhAnalysis.read_vimh_df(path_input)
    ...

def runFilterLastUniquePaths():
    df = VimhAnalysis.read_vimh_df(path_input)
    raise NotImplementedError()


if __name__ == '__main__':
    runCountUniquePathsPerDay()
    #runFilterLastUniquePaths()

