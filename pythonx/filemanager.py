#! python3.8 -u
#  -*- coding: utf-8 -*-

##############################
## Package PyCTLib
##############################
__all__ = """
    path
    file
""".split()

import os, re, struct

"""
from pyctlib.system.filemanager import *
"""

def totuple(num):
    if isinstance(num, str): return (num,)
    try: return tuple(num)
    except: return (num,)

class path:

    def __init__(self, _path):
        self._path = os.path.abspath(".")

    def parent(self):
        return path(os.path.abspath(self._path + os.path.pathsep + ".."))

    def name(self):
        return self._path.split(os.path.pathsep)[-1].split(os.path.extsep)[0]

    def ls(self):
        return os.listdir(self._path)
