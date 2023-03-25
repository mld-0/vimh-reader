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
#logging.basicConfig(stream=sys.stderr, level=logging.WARNING)
#   Ongoings:
#   {{{
#   Ongoing: 2022-07-24T00:37:00AEST when/where to modify df in place versus return modified copy?
#   Ongoing: 2022-07-24T00:38:03AEST df rows are called records?
#   Ongoing: 2022-07-24T02:43:38AEST 'apply(strptime)' is faster than 'pd.to_datetime()'?
#   Ongoing: 2022-07-26T22:52:14AEST fast str2dt method(?)
#   }}}

path_home = os.environ.get('HOME')
if not path_home:
    raise Exception(f"failed to get path_home=({path_home})")

path_input = os.path.join(path_home, '.vimh')
if not os.path.isfile(path_input):
    raise FileNotFoundError(path_input)

flag_filter_existing = False
flag_only_dirs = False
flag_replace_HOME_in_output = True

#   Reports: 
#           count-unique (per-interval)
#           last-unique (per-interval?)
#           datetime-splits (sum per-interval, per-unique?)

class VimhAnalysis:

    #   Ongoing: 2022-07-28T22:47:49AEST is 'loop_df' a copy of (or window into) origional dataframe?
    #   Ongoing: 2022-07-26T22:52:45AEST 'groupByDay()' return nested-index dataframe, or list-of-dataframes?
    @staticmethod
    def countUniquePerDay(df: pd.DataFrame, col_count_unique: str='filepath') -> pd.Series:
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
    def sumSplitsPerUniquePerDay(df: pd.DataFrame, seconds_threshold: int=300, col: str='filepath') -> pd.Series:
        df = df[~(df['delta_s'] > seconds_threshold)]
        df['delta_h'] = df['delta_s'] / 3600.0
        g = [pd.Grouper(key='date', axis=0, freq='D'), col]
        df_sumSplitsByUniqueByDay = df.groupby(g)['delta_h'].sum().sort_values(ascending=False)
        logging.debug("df_sumSplitsByUniqueByDay=(%s)" % df_sumSplitsByUniqueByDay)
        return df_sumSplitsByUniqueByDay

    @staticmethod
    def lastUniqueByColumn(df: pd.DataFrame, col_last_unique: str='filepath') -> pd.Series:
        """Keep only records which have the last instance of each given unique value in a given column"""
        df_lastUnique = df.drop_duplicates(subset=col_last_unique, keep='last')
        df_lastUnique = df_lastUnique.set_index(['date','time'])
        df_lastUnique = df_lastUnique[col_last_unique]
        logging.debug("df_lastUnique=(%s)" % df_lastUnique)
        return df_lastUnique

    #@staticmethod
    #def substituteHomeStr(df: pd.DataFrame) -> pd.DataFrame:
    #    """Replaces instances of '$HOME' with '~' in df ~~(for given columns 'col_replace' (which must be strings?))~~ (for all columns that are strings?) """
    #    raise NotImplementedError()

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
        convertStringToDateTime(df)

    @staticmethod
    def splitDateTimeColumn(df: pd.DataFrame, col: str):
        df.insert(0, 'date', df[col].dt.date)
        df.insert(1, 'time', df[col].dt.time)
        df.drop(col, axis=1, inplace=True)
        df['date'] = pd.to_datetime(df['date'])
        df['time'] = df['time']

    @staticmethod
    def read_vimh_df(path_input: str) -> pd.DataFrame:
        columns = [ 'datetime', 'filename', 'host', 'action', 'filepath', 'realpath', ]
        df = pd.read_csv(path_input, delimiter='\t', names=columns)
        #df = df.tail(10000) 
        #logging.debug("tail(10000)")
        VimhAnalysis.parseDateTimes(df, 'datetime')
        #VimhAnalysis.splitDateTimeColumn(df, 'datetime')
        logging.debug("df=(%s)" % df)
        return df

    @staticmethod
    def reduceToDirs(df: pd.DataFrame, col: str='filepath'):
        df[col] = df[col].apply(lambda x: os.path.dirname(x))
        logging.debug("df=(%s)" % df)
        return df

    @staticmethod
    def reduceToBasenames(df: pd.Series, col: str='filepath'):
        df[col] = df[col].apply(lambda x: os.path.splitext(os.path.basename(x))[0])
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

    @staticmethod
    def splitPaths(df: pd.Series) -> pd.DataFrame:
        """Turn Series of paths into DataFrame of ['dirpath','filename']"""
        df = df.apply(lambda x: os.path.split(x))
        df = pd.DataFrame(df.to_list(), index=df.index, columns=['dirpath','filename'])
        logging.debug("df=(%s)" % df)
        return df

    @staticmethod
    def datetimeSplits(df: pd.DataFrame):
        """Get difference in seconds between each datetime as new column 'delta_s'"""
        col = 'datetime'
        df['delta_s'] = df[col].diff()
        df['delta_s'] = df['delta_s'].dt.total_seconds()
        logging.debug(f"df=({df})")
        return df


def runCountUniquePathsPerDay(count_threshold=0):
    """Report count per unique file for each day"""
    df = handleReading()
    VimhAnalysis.splitDateTimeColumn(df, 'datetime')
    df = VimhAnalysis.countUniquePerDay(df)
    print_Series_DatePathIndex_Values(df, count_threshold)

def runSumSplits():
    """Report sum(delta_s) per unique file for each day"""
    df = handleReading()
    df = VimhAnalysis.datetimeSplits(df)
    VimhAnalysis.splitDateTimeColumn(df, 'datetime')
    df = VimhAnalysis.sumSplitsPerUniquePerDay(df)
    print_Series_DatePathIndex_Values(df, 0)

def handleReading():
    df = VimhAnalysis.read_vimh_df(path_input)
    if flag_only_dirs:
        df = VimhAnalysis.reduceToDirs(df)
    if flag_filter_existing:
        df = VimhAnalysis.filterExisting(df)
    return df

def print_Series_DatePathIndex_Values(df: pd.Series, value_threshold: int):
    #pd.set_option('precision', 2)
    for date, df_day in df.groupby(level=0):
        df_day = df_day.droplevel(0)
        if flag_replace_HOME_in_output:
            df_day.index = df_day.index.str.replace(path_home, '~')
        if value_threshold > 0:
            df_day = df_day[df_day > value_threshold]
        print(date.strftime("%F"))
        print(df_day.to_string(header=False))
        print()

def runFilterLastUniquePaths():
    """Report most recent log record of each unique file"""
    df = VimhAnalysis.read_vimh_df(path_input)
    VimhAnalysis.splitDateTimeColumn(df, 'datetime')
    df = VimhAnalysis.lastUniqueByColumn(df)
    #df = VimhAnalysis.splitPaths(df)
    pd.set_option('display.max_colwidth', None)
    if flag_replace_HOME_in_output:
        df = df.str.replace(path_home, '~')
    print(df.to_string(header=False))

def runCountUniqueExistingGitReposPerDay():
    raise NotImplementedError()


if __name__ == '__main__':
    ...
    runCountUniquePathsPerDay()
    #runSumSplits()

    #runFilterLastUniquePaths()

    #runCountUniqueExistingGitReposPerDay()

