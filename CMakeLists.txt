cmake_minimum_required(VERSION 3.12)

project(cppyy_bbhash
        LANGUAGES CXX 
        VERSION 0.1 
        HOMEPAGE_URL "https://github.com/camillescott/cppyy-bbhash"
        DESCRIPTION "cppyy bindings for bbhash")

# headers are listed in a cmake file.
include(${CMAKE_SOURCE_DIR}/cmake/headers.cmake)
include(GNUInstallDirs)

# we want the conda includes if we're in a conda environment.
include_directories($ENV{CONDA_PREFIX}/include)

#
# Add our project's cmake dir the the module path. This gives us the
# Cppyy commands and targets.
#
list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_SOURCE_DIR}/cmake)
find_package(Cppyy)

#
# Make the default build us c++14 and "RELEASE" (-O3)
#
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
if(NOT CMAKE_BUILD_TYPE) 
    set(CMAKE_BUILD_TYPE Release)
endif(NOT CMAKE_BUILD_TYPE)

set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
find_package(Threads)

#
# Make an object file with the cpp header 
#
add_library(bbhash STATIC
            ${HEADERS}
)
set_target_properties(bbhash PROPERTIES LINKER_LANGUAGE CXX)
target_include_directories(bbhash
                           PUBLIC
                           ${CMAKE_SOURCE_DIR}/bbhash
)
target_link_libraries(bbhash
                      PRIVATE
                      Threads::Threads
)


#
# Set up the Cppyy bindings generation. This is a customized version defined
# in boink's cmake/ dir; it uses genreflex rather than calling rootcling directly.
# I did this because I couldn't get rootcling to properly include/exclude classes
# via the LinkDef header, and I wanted to be able to use the better syntax in
# the genreflex selection XML anyhow. Also, I think this is now the recommended /
# more modern way anyhow? Code was modified from the versions cppyy distributes.
#
cppyy_add_bindings(
    "cppyy_bbhash" "${PROJECT_VERSION}" "Camille Scott" "cswel@ucdavis.edu"
   LICENSE "MIT"
   LANGUAGE_STANDARD "14"
   SELECTION_XML  ${CMAKE_CURRENT_SOURCE_DIR}/selection.xml
   INTERFACE_FILE ${CMAKE_CURRENT_SOURCE_DIR}/interface.hh
   HEADERS        ${HEADERS} ${CMAKE_CURRENT_SOURCE_DIR}/interface.hh
   INCLUDE_DIRS   ${CMAKE_CURRENT_SOURCE_DIR}/bbhash
   LINK_LIBRARIES bbhash
   NAMESPACES     boomphf
)
