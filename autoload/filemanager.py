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
from typing import TextIO

"""
from pyctlib.system.filemanager import *
"""

def totuple(num):
    if isinstance(num, str): return (num,)
    try: return tuple(num)
    except: return (num,)

class path(str):

    sep = os.path.sep #/
    extsep = os.path.extsep #.
    pathsep = os.path.pathsep #:
    namesep = '_'
    File = b'\x04'
    Folder = b'\x07'
    homedir = os.path.expanduser("~")

    class pathList(list):

        def __new__(cls, lst, main_folder = os.curdir):
            self = super().__new__(cls)
            for e in lst:
                if e not in self: self.append(e)
            self.main_folder = main_folder
            return self

        def __init__(self, *args, **kwargs): pass

        def __or__(self, k): return self[[x|k for x in self]]
        def __sub__(self, y): return path.pathList([x - y for x in self])
        def __neg__(self): return self - self.main_folder
        def __matmul__(self, k): return path.pathList([x.matmul(k) for x in self])
        def __mod__(self, k): return path.pathList([x % k for x in self])
        def __getitem__(self, i):
            if callable(i): return self[[i(x) for x in self]]
            if isinstance(i, list) and len(i) == len(self): return path.pathList([x for x, b in zip(self, i) if b])
            return super().__getitem__(i)

    @staticmethod
    def rlistdir(folder, tofolder=False, relative=False, ext='', filter=lambda x: True):
        folder = path(folder)
        # file_list = []
        for f in os.listdir(str(folder)):
            if f == '.DS_Store': continue
            p = folder / f
            if p.isdir():
                # file_list.extend(path.rlistdir(p, tofolder))
                for cp in path.rlistdir(p, tofolder, relative=relative, ext=ext, filter=filter):
                    if filter(cp) and (cp | ext):
                        yield cp
            if p.isfile() and not tofolder and filter(p) and (p | ext):
                yield p
        if tofolder and not file_list and filter(folder) and (folder | ext):
            # file_list.append(folder)
            yield folder
        # file_list = path.pathList(file_list, main_folder=folder)
        # if relative: file_list = -file_list
        # if ext: file_list = file_list[file_list|ext]
        # return file_list[filter]

    def __new__(cls, *init_texts):
        if len(init_texts) <= 0 or len(init_texts[0]) <= 0:
            self = super().__new__(cls, "")
        elif len(init_texts) == 1 and init_texts[0] == "~":
            self = super().__new__(cls, path.homedir)
        else:
            self = super().__new__(cls, os.path.join(*[str(x).replace('$', '') for x in init_texts]).strip())
        self.init()
        return self

    def init(self): pass
    def __and__(x, y): return path(path.pathsep.join((str(x).rstrip(path.pathsep), str(y).lstrip(path.pathsep))))
    def __mul__(x, y): return path(x).mkdir(y)
    def __mod__(x, y): return path(str(x) % totuple(y))
    def __sub__(x, y): return path(os.path.relpath(str(x), str(y)))
    def __add__(x, y):
        y = str(y)
        if x.isfilepath():
            file_name = x.matmul(path.File)
            folder_name = x.matmul(path.Folder)
            parts = file_name.split(path.extsep)
            if parts[-1].lower() in ('zip', 'gz', 'rar') and len(parts) > 2: brk = -2
            else: brk = -1
            ext = path.extsep.join(parts[brk:])
            name = path.extsep.join(parts[:brk])
            return folder_name/(name + y + path.extsep + ext)
        else: return path(str(x) + y)
    def __xor__(x, y):
        y = str(y)
        if x.isfilepath():
            file_name = x.matmul(path.File)
            folder_name = x.matmul(path.Folder)
            parts = file_name.split(path.extsep)
            if parts[-1].lower() in ('zip', 'gz', 'rar') and len(parts) > 2: brk = -2
            else: brk = -1
            ext = path.extsep.join(parts[brk:])
            name = path.extsep.join(parts[:brk])
            return folder_name/(name.rstrip(path.namesep) + path.namesep + y.lstrip(path.namesep) + path.extsep + ext)
        else: return path(path.namesep.join((str(x).rstrip(path.namesep), y.lstrip(path.namesep))))
    def __pow__(x, y):
        output = rootdir
        for p, q in zip((~path(x)).split(), (~path(y)).split()):
            if p == q: output /= p
            else: break
        return output - curdir
    def __floordiv__(x, y): return path(path.extsep.join((str(x).rstrip(path.extsep), str(y).lstrip(path.extsep))))
    def __invert__(self): return path(os.path.abspath(str(self)))
    def __abs__(self): return path(os.path.abspath(str(self)))
    def __truediv__(x, y): return path(os.path.join(str(x), str(y)))
    def __or__(x, y):
        if y == "": return True
        if y == path.File: return x.isfile()
        if y == path.Folder: return x.isdir()
        if isinstance(y, int): return len(x) == y
        if '.' not in y: y = '.*\\' + x.extsep + y
        return re.fullmatch(y.lower(), x[-1].lower()) is not None
        # return x.lower().endswith(x.extsep + y.lower())
    def __eq__(x, y): return str(x) == str(y)
    # def __matmul__(self, k):
    #     if k == path.Folder: return path(self[:-1])
    #     elif k == path.File: return path(self[-1:])
    #     return
    def matmul(self, k):
        if k == path.Folder: return path(self[:-1])
        elif k == path.File: return path(self[-1:])
        return
    def __lshift__(self, k): return path.rlistdir(self, k == path.Folder, ext=k if k not in (path.File, path.Folder) else '')
    def __setitem__(self, i, v):
        lst = self.split()
        lst[i] = v
        return path(lst)
    def __getitem__(self, i):
        res = self.split()[i]
        return res if isinstance(res, str) else path(path.sep.join(res))
    def __len__(self): return len(self.split())

    def __iter__(self):
        for p in self<<path.File:
            yield p

    def __contains__(self, x): return x in str(self)

    @property
    def ext(self):
        file_name = self.matmul(path.File)
        parts = file_name.split(path.extsep)
        if parts[-1].lower() in ('zip', 'gz', 'rar') and len(parts) > 2: brk = -2
        elif len(parts) > 1: brk = -1
        else: brk = 1
        return path.extsep.join(parts[brk:])
    @property
    def name(self):
        file_name = self.matmul(path.File)
        parts = file_name.split(path.extsep)
        if parts[-1].lower() in ('zip', 'gz', 'rar') and len(parts) > 2: brk = -2
        elif len(parts) > 1: brk = -1
        else: brk = 1
        return path.extsep.join(parts[:brk])
    def split(self, *args):
        if len(args) == 0: return [path(x) if x else path("$") for x in str(self).split(path.sep)]
        else: return str(self).split(*args)
    def abs(self): return path(os.path.abspath(self))
    def listdir(self, recursively=False):
        return self << path.File if recursively else path.pathList([self / x for x in os.listdir(str(self))])
    # changed by zhangyiteng
    def ls(self, func=lambda x: True):
        return [x for x in self.listdir() if func(x)]
    def cd(self, folder_name):
        folder_name = path(folder_name)
        if folder_name.isabs():
            return folder_name
        new_folder = self / folder_name
        if new_folder.isdir():
            if self.isabs():
                return new_folder.abs()
            return new_folder
        elif (new_folder.matmul(path.Folder)).isdir():
            # raise NotADirectoryError("%s doesn't exist, all available folder is: %s" % (new_folder, (new_folder @ path.Folder).ls().filter(lambda x: x.isdir()).map(lambda x: x.name)))
            raise NotADirectoryError("%s doesn't exist" % new_folder)
        else:
            raise NotADirectoryError("%s doesn't exist" % new_folder)
    def cmd(self, command):
        try:
            if self.isdir():
                os.system("cd %s; %s" % (self, command))
            elif self.isfile():
                if "{}" in command:
                    self.parent.cmd(command.format(self))
                else:
                    self.parent.cmd(command + " " + self)
        except Exception as e:
            print("cmd error:", e)
    def open(self):
        if self.isdir():
            self.cmd("open .")
        elif self.isfile():
            self.parent.cmd("open %s" % self)
    @property
    def parent(self):
        return self.matmul(path.Folder)
    # end changed by zhangyiteng
    def isabs(self): return os.path.isabs(self)
    def exists(self): return os.path.exists(self)
    def isfile(self): return os.path.isfile(self)
    def isdir(self): return os.path.isdir(self)
    def isfilepath(self): return True if os.path.isfile(self) else 0 < len(self.ext) < 7
    def isdirpath(self): return True if os.path.isdir(self) else (len(self.ext) == 0 or len(self.ext) >= 7)
    def mkdir(self, to: str='Auto'):
        cumpath = path(os.path.curdir)
        if self.isabs(): cumpath = cumpath.abs()
        fp = self - cumpath
        if to == path.Folder: fp = fp.matmul(path.Folder)
        elif to == path.File: pass
        elif self.isfilepath(): fp = fp.matmul(path.Folder)
        for p in fp.split():
            cumpath /= p
            if not cumpath.exists(): os.mkdir(cumpath)
        return self

rootdir = (~path(os.path.curdir))[0] + path.sep
curdir = path(os.path.curdir)
pardir = path(os.path.pardir)
codedir = path(os.getcwd())
codefolder = path(os.getcwd())
File = b'\x04'
Folder = b'\x07'

if __name__ == '__main__': pass
