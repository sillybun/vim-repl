#build the modules

from distutils.core import setup, Extension

setup(name='afpython', version='1.0',  \
      ext_modules=[Extension('afpython', ['afpython.cpp'])])
