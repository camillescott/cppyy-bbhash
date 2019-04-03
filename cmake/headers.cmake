set(_headers
    bbhash/BooPHF.h
)

foreach (path ${_headers})
    list(APPEND HEADERS ${CMAKE_SOURCE_DIR}/${path})
endforeach(path)
