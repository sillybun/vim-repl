import sys
from os.path import join, dirname, realpath, abspath, exists
from dotenv import load_dotenv, find_dotenv
load_dotenv(dotenv_path=find_dotenv(), verbose=True)

try:
    cur_path = dirname(realpath(__file__))
except Exception as e:
    cur_path = dirname(realpath('__file__'))
else:
    print(cur_path)
    sys.path.append(abspath(join(cur_path, '../')))
    sys.path.append(abspath(join(cur_path, '../schema')))

def process_etl():
    a = 1
