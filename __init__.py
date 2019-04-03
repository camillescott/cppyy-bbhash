import os
import cppyy
from . import bindings_utils
bindings_utils.initialise('cppyy_bbhash', 'libcppyy_bbhashCppyy.so', 'cppyy_bbhash.map')
del bindings_utils
from cppyy.gbl import boomphf
