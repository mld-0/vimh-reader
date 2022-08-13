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

#   Reports: 
#           count-unique (per-interval)
#           last-unique (per-interval?)
#           datetime-splits (sum per-interval, per-unique?)

class VimhAnalysis:

    #   Ongoing: 2022-07-28T22:47:49AEST is 'loop_df' a copy of (or window into) origional dataframe?
    #   Ongoing: 2022-07-26T22:52:45AEST 'groupByDay()' return nested-index dataframe, or list-of-dataframes?
    @staticmethod
    def countUniquePerDay(df: pd.DataFrame, col_count_unique: str='filepath') -> pd.DataFrame:
        """Group by day and count unique values in a given column""" 
        #   Produces result with multiindex: [date,path] = count
        df_countUniqueByDay = df.groupby(pd.Grouper(key='date', axis=0, freq='D'))[col_count_unique].value_counts()
        logging.debug("df_countUniqueByDay=(%s)" % df_countUniqueByDay)
        return df_countUniqueByDay
        #   Conversion to 'List[ pd.DataFrame ]'
        #   {{{
        #result = [ x for x in df_countUniqueByDay.groupby(level=0) ]
        #logging.debug("result=(%s)" % result)
        #return result
        #   }}}
        #   Conversion to 'List[ Tuple[ List[str], List[str], List[int] ] ]'
        #   {{{
        #result = []
        #for date, loop_df in df_countUniqueByDay.groupby(level=0):
        #    date_str = date.strftime("%F")
        #    loop_df_flat = loop_df.droplevel(0)
        #    loop_uniques = loop_df_flat.index.to_list()
        #    loop_counts = loop_df_flat.to_list()
        #    result.append( ( date_str, loop_uniques, loop_counts ) )
        #logging.debug("result=(%s)" % pprint.pformat(result))
        #return result
        #   }}}

    @staticmethod
    def lastUniqueByColumn(df: pd.DataFrame, col_last_unique: str='filepath') -> pd.DataFrame:
        """Keep only records which have the last instance of each given unique value in a given column"""
        df_lastUnique = df.drop_duplicates(subset=col_last_unique, keep='last')
        logging.debug("df_lastUnique=(%s)" % df_lastUnique)
        return df_lastUnique

    @staticmethod
    def substituteHomeStr(df: pd.DataFrame) -> pd.DataFrame:
        """Replaces instances of '$HOME' with '~' in df ~~(for given columns 'col_replace' (which must be strings?))~~ (for all columns that are strings?) """
        raise NotImplementedError()

    @staticmethod
    def filterEmptyByCol(df: pd.DataFrame, col_filter_by: str):
        """Remove records where value in given column i'col_filter_by' is empty (NaN?) (in-place?)"""
        raise NotImplementedError()

    @staticmethod
    def parseDateTimes(df: pd.DataFrame, col: str):
        """Convert df iso-datetime column strings to columns date/time"""
        def convertStringToDateTime(df: pd.DataFrame):
            iso_fmt = "%Y-%m-%dT%H:%M:%S%z"
            str2dt = lambda x: datetime.datetime.strptime(x, iso_fmt)
            df[col] = pd.to_datetime(df[col].apply(str2dt), utc=True)
        def splitDateTimeColumn(df: pd.DataFrame):
            df.insert(0, 'date', df[col].dt.date)
            df.insert(1, 'time', df[col].dt.time)
            df.drop(col, axis=1, inplace=True)
            df['date'] = pd.to_datetime(df['date'])
            df['time'] = df['time']
        convertStringToDateTime(df)
        splitDateTimeColumn(df)

    @staticmethod
    def read_vimh_df(path_input: str) -> pd.DataFrame:
        columns = [ 'datetime', 'filename', 'host', 'action', 'filepath', 'realpath', ]
        df = pd.read_csv(path_input, delimiter='\t', names=columns)
        #df = df.tail(10000) 
        #logging.debug("tail(10000)")
        VimhAnalysis.parseDateTimes(df, 'datetime')
        logging.debug("df=(%s)" % df)
        return df

    @staticmethod
    def reduceToDirs(df: pd.DataFrame, col: str='filepath'):
        df[col] = df[col].apply(lambda x: os.path.dirname(x))
        logging.debug("df=(%s)" % df)
        return df

    @staticmethod
    def filterExisting(df: pd.DataFrame, col: str='filepath'):
        does_not_exist = lambda x: not os.path.exists(x)
        count_before_drop = len(df)
        rows_to_drop = df[col].map(does_not_exist)
        df.drop(df[rows_to_drop].index, inplace=True)
        count_after_drop = len(df)
        count_rows_to_drop = len(rows_to_drop[rows_to_drop])
        logging.debug("count_before_drop=(%s)" % count_before_drop)
        logging.debug("count_rows_to_drop=(%s)" % count_rows_to_drop)
        logging.debug("count_after_drop=(%s)" % count_after_drop)
        logging.debug("df=(%s)" % df)
        return df



def runCountUniquePathsPerDay():
    df = VimhAnalysis.read_vimh_df(path_input)
    df = VimhAnalysis.countUniquePerDay(df)
    print_df_countUniqueByDay(df)

def runCountUniqueExistingPathsPerDay():
    df = VimhAnalysis.read_vimh_df(path_input)
    df = VimhAnalysis.filterExisting(df)
    df = VimhAnalysis.countUniquePerDay(df)
    print_df_countUniqueByDay(df)

def runCountUniqueDirsPerDay():
    df = VimhAnalysis.read_vimh_df(path_input)
    df = VimhAnalysis.reduceToDirs(df)
    df = VimhAnalysis.countUniquePerDay(df)
    print_df_countUniqueByDay(df)

def runCountUniqueExistingDirsPerDay():
    df = VimhAnalysis.read_vimh_df(path_input)
    df = VimhAnalysis.reduceToDirs(df)
    df = VimhAnalysis.filterExisting(df)
    df = VimhAnalysis.countUniquePerDay(df)
    print_df_countUniqueByDay(df)

def print_df_countUniqueByDay(df):
    for date, df_day in df.groupby(level=0):
        df_day = df_day.droplevel(0)
        print(date.strftime("%F"))
        print(df_day.to_string(header=False))
        print()

def runFilterLastUniquePaths():
    df = VimhAnalysis.read_vimh_df(path_input)
    df_lastUnique = VimhAnalysis.lastUniqueByColumn(df)


if __name__ == '__main__':
    path_input = os.path.join(os.getenv('HOME'), '.vimh')
    assert os.path.isfile(path_input)

    runCountUniquePathsPerDay()
    #runCountUniqueDirsPerDay()
    #runCountUniqueExistingPathsPerDay()
    #runCountUniqueExistingDirsPerDay()

    #runFilterLastUniquePaths()

