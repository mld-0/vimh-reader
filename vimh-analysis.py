import sys
import os
import logging
import pandas as pd
logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)

path_input = os.path.join(os.getenv('HOME'), '.vimh')
assert os.path.isfile(path_input)


def read_df_vimh(path_input):
    df = pd.read_csv(path_input, delimiter='\t', names=[ 'datetime', 'filename', 'host', 'action', 'filepath', 'realpath', ])
    logging.debug("df=(%s)" % df)


if __name__ == '__main__':
    read_df_vimh(path_input)

