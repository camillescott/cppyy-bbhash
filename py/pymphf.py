from cppyy_bbhash import boomphf
from cppyy.gbl.std import vector

class MPHF(boomphf.mphf['ULong64_t', boomphf.SingleHashFunctor['ULong64_t']]):

    Base = boomphf.mphf['ULong64_t', boomphf.SingleHashFunctor['ULong64_t']]

    def __init__(self, iterable, gamma=2.0, threads=1, verbose=True, write_each=False):
        elements = vector['ULong64_t'](iterable)
        super(MPHF, self).__init__(len(elements), elements, threads, gamma, write_each, verbose)
