from cppyy.gbl import std
from cppyy_bbhash import boomphf

import pytest
import random

@pytest.fixture(params=['ULong64_t', 'int', 'unsigned int'])
def mphf_type(request):
    return request.param, boomphf.mphf[request.param, boomphf.SingleHashFunctor[request.param]]


@pytest.mark.parametrize('sample_size', (10, 100, 1000))
def test_mphf_lookup(sample_size, mphf_type):
    ''' Test basic lookup
    '''
    elem_t, mphf_t = mphf_type

    sample_space = list(range(10 * sample_size))
    items = std.vector[elem_t](random.sample(sample_space, sample_size))
    ph = mphf_t(len(items), items, 1, 2.0, False, False)

    mapped = [ph.lookup(item) for item in items]
    assert sorted(mapped) == list(range(sample_size))


@pytest.mark.parametrize('sample_size', (10, 100, 1000))
def test_mphf_query(sample_size, mphf_type):
    ''' Test the pythonized lookup, which is mapped to query
    '''
    elem_t, mphf_t = mphf_type

    sample_space = list(range(10 * sample_size))
    items = std.vector[elem_t](random.sample(sample_space, sample_size))
    ph = mphf_t(len(items), items, 1, 2.0, False, False)

    mapped = [ph.query(item) for item in items]
    assert sorted(mapped) == list(range(sample_size))
