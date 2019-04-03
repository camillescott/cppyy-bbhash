#include "bbhash/BooPHF.h"

#include <cstdint>

template class boomphf::SingleHashFunctor<uint16_t>;
template class boomphf::SingleHashFunctor<uint32_t>;
template class boomphf::SingleHashFunctor<uint64_t>;
template class boomphf::SingleHashFunctor<unsigned long long>;

template class boomphf::SingleHashFunctor<int16_t>;
template class boomphf::SingleHashFunctor<int32_t>;
template class boomphf::SingleHashFunctor<int64_t>;


template class boomphf::mphf<uint16_t, boomphf::SingleHashFunctor<uint16_t>>;
template class boomphf::mphf<uint32_t, boomphf::SingleHashFunctor<uint32_t>>;
template class boomphf::mphf<uint64_t, boomphf::SingleHashFunctor<uint64_t>>;
template class boomphf::mphf<unsigned long long, boomphf::SingleHashFunctor<unsigned long long>>;

template class boomphf::mphf<int16_t, boomphf::SingleHashFunctor<int16_t>>;
template class boomphf::mphf<int32_t, boomphf::SingleHashFunctor<int32_t>>;
template class boomphf::mphf<int64_t, boomphf::SingleHashFunctor<int64_t>>;

namespace boomphf {
    typedef boomphf::mphf<int64_t, boomphf::SingleHashFunctor<int64_t>> DefaultMPHF;
}
