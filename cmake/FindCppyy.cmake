#.rst:
# FindCppyy
# -------
#
# Find Cppyy
#
# This module finds an installed Cppyy.  It sets the following variables:
#
# ::
#
#   Cppyy_FOUND - set to true if Cppyy is found
#   Cppyy_DIR - the directory where Cppyy is installed
#   Cppyy_EXECUTABLE - the path to the Cppyy executable
#   Cppyy_INCLUDE_DIRS - Where to find the ROOT header files.
#   Cppyy_VERSION - the version number of the Cppyy backend.
#
#
# The module also defines the following functions:
#
#   cppyy_add_bindings - Generate a set of bindings from a set of header files.
#
# The minimum required version of Cppyy can be specified using the
# standard syntax, e.g.  find_package(Cppyy 4.19)
#

find_program(genreflex_EXEC NAMES genreflex)
execute_process(COMMAND cling-config --cmake OUTPUT_VARIABLE CPYY_MODULE_PATH OUTPUT_STRIP_TRAILING_WHITESPACE)

if(genreflex_EXEC)
  #
  # Cppyy_DIR.
  #
  set(Cppyy_DIR ${CPYY_MODULE_PATH}/../)
  #
  # Cppyy_INCLUDE_DIRS.
  #
  set(Cppyy_INCLUDE_DIRS ${Cppyy_DIR}include)
  #
  # Cppyy_VERSION.
  #
  find_package(ROOT QUIET REQUIRED PATHS ${CPYY_MODULE_PATH})
  if(ROOT_FOUND)
    set(Cppyy_VERSION ${ROOT_VERSION})
  endif()
endif()

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
    Cppyy
    REQUIRED_VARS genreflex_EXEC Cppyy_DIR Cppyy_INCLUDE_DIRS
    VERSION_VAR Cppyy_VERSION)

mark_as_advanced(Cppyy_VERSION)

find_library(LibCling_LIBRARY libCling.so PATHS ${Cppyy_DIR}/lib)

#
# Generate a set of bindings from a set of header files. Somewhat like CMake's
# add_library(), the output is a compiler target. In addition ancilliary files
# are also generated to allow a complete set of bindings to be compiled,
# packaged and installed.
#
#   cppyy_add_bindings(
#       pkg
#       pkg_version
#       author
#       author_email
#       [URL url]
#       [LICENSE license]
#       [LANGUAGE_STANDARD std]
#       [LINKDEFS linkdef...]
#       [IMPORTS pcm...]
#       [GENERATE_OPTIONS option...]
#       [COMPILE_OPTIONS option...]
#       [INCLUDE_DIRS dir...]
#       [LINK_LIBRARIES library...]
#       [H_DIRS H_DIRSectory]
#       H_FILES h_file...)
#
# The bindings are based on https://cppyy.readthedocs.io/en/latest/, and can be
# used as per the documentation provided via the cppyy.cgl namespace. First add
# the directory of the <pkg>.rootmap file to the LD_LIBRARY_PATH environment
# variable, then "import cppyy; from cppyy.gbl import <some-C++-entity>".
#
# Alternatively, use "import <pkg>". This convenience wrapper supports
# "discovery" of the available C++ entities using, for example Python 3's command
# line completion support.
#
# The bindings are complete with a setup.py, supporting Wheel-based
# packaging, and a test.py supporting pytest/nosetest sanity test of the bindings.
#
# The bindings are generated/built/packaged using 3 environments:
#
#   - One compatible with the header files being bound. This is used to
#     generate the generic C++ binding code (and some ancilliary files) using
#     a modified C++ compiler. The needed options must be compatible with the
#     normal build environment of the header files.
#
#   - One to compile the generated, generic C++ binding code using a standard
#     C++ compiler. The resulting library code is "universal" in that it is
#     compatible with both Python2 and Python3.
#
#   - One to package the library and ancilliary files into standard Python2/3
#     wheel format. The packaging is done using native Python tooling.
#
# Arguments and options:
#
#   pkg                 The name of the package to generate. This can be either
#                       of the form "simplename" (e.g. "Akonadi"), or of the
#                       form "namespace.simplename" (e.g. "KF5.Akonadi").
#
#   pkg_version         The version of the package.
#
#   author              The name of the library author.
#
#   author_email        The email address of the library author.
#
#   URL url             The home page for the library. Default is
#                       "https://pypi.python.org/pypi/<pkg>".
#
#   LICENSE license     The license, default is "LGPL 2.0".
#
#   LANGUAGE_STANDARD std
#                       The version of C++ in use, "14" by default.
#
#   IMPORTS pcm         Files which contain previously-generated bindings
#                       which pkg depends on.
#
#   GENERATE_OPTIONS option
#                       Options which are to be passed into the rootcling
#                       command. For example, bindings which depend on Qt
#                       may need "-D__PIC__;-Wno-macro-redefined" as per
#                       https://sft.its.cern.ch/jira/browse/ROOT-8719.
#
#   LINKDEFS def        Files or lines which contain extra #pragma content
#                       for the linkdef.h file used by rootcling. See
#                       https://root.cern.ch/root/html/guides/users-guide/AddingaClass.html#the-linkdef.h-file.
#
#                       In lines, literal semi-colons must be escaped: "\;".
#
#   EXTRA_CODES code    Files which contain extra code needed by the bindings.
#                       Customisation is by routines named "c13n_<something>";
#                       each such routine is passed the module for <pkg>:
#
#                           def c13n_doit(pkg_module):
#                               print(pkg_module.__dict__)
#
#                       The files and individual routines within files are
#                       processed in alphabetical order.
#
#   EXTRA_HEADERS hdr   Files which contain extra headers needed by the bindings.
#
#   EXTRA_PYTHONS py    Files which contain extra Python code needed by the bindings.
#
#   COMPILE_OPTIONS option
#                       Options which are to be passed into the compile/link
#                       command.
#
#   INCLUDE_DIRS dir    Include directories.
#
#   LINK_LIBRARIES library
#                       Libraries to link against.
#
#   H_DIRS directory    Base directories for H_FILES.
#
#   H_FILES h_file      Header files for which to generate bindings in pkg.
#                       Absolute filenames, or filenames relative to H_DIRS. All
#                       definitions found directly in these files will contribute
#                       to the bindings. (NOTE: This means that if "forwarding
#                       headers" are present, the real "legacy" headers must be
#                       specified as H_FILES).
#
#                       All header files which contribute to a given C++ namespace
#                       should be grouped into a single pkg to ensure a 1-to-1
#                       mapping with the implementing Python class.
#
# Returns via PARENT_SCOPE variables:
#
#   target              The CMake target used to build.
#
#   setup_py            The setup.py script used to build or install pkg.
#
# Examples:
#
#   find_package(Qt5Core NO_MODULE)
#   find_package(KF5KDcraw NO_MODULE)
#   get_target_property(_H_DIRS KF5::KDcraw INTERFACE_INCLUDE_DIRECTORIES)
#   get_target_property(_LINK_LIBRARIES KF5::KDcraw INTERFACE_LINK_LIBRARIES)
#   set(_LINK_LIBRARIES KF5::KDcraw ${_LINK_LIBRARIES})
#   include(${KF5KDcraw_DIR}/KF5KDcrawConfigVersion.cmake)
#
#   cppyy_add_bindings(
#       "KDCRAW" "${PACKAGE_VERSION}" "Shaheed" "srhaque@theiet.org"
#       LANGUAGE_STANDARD "14"
#       LINKDEFS "../linkdef_overrides.h"
#       GENERATE_OPTIONS "-D__PIC__;-Wno-macro-redefined"
#       INCLUDE_DIRS ${Qt5Core_INCLUDE_DIRS}
#       LINK_LIBRARIES ${_LINK_LIBRARIES}
#       H_DIRS ${_H_DIRS}
#       H_FILES "dcrawinfocontainer.h;kdcraw.h;rawdecodingsettings.h;rawfiles.h")
#
function(cppyy_generate_setup pkg version lib_so_file rootmap_file pcm_file map_file)
    set(SETUP_PY_FILE ${CMAKE_CURRENT_BINARY_DIR}/setup.py)
    set(CPPYY_PKG ${pkg})
    get_filename_component(CPPYY_LIB_SO ${lib_so_file} NAME)
    get_filename_component(CPPYY_ROOTMAP ${rootmap_file} NAME)
    get_filename_component(CPPYY_PCM ${pcm_file} NAME)
    get_filename_component(CPPYY_MAP ${map_file} NAME)
    configure_file(${CMAKE_SOURCE_DIR}/setup.py.in ${SETUP_PY_FILE})

    set(SETUP_PY_FILE ${SETUP_PY_FILE} PARENT_SCOPE)
endfunction(cppyy_generate_setup)


function(cppyy_generate_init)
    set(simple_args PKG LIB_FILE MAP_FILE)
    set(list_args NAMESPACES)
    cmake_parse_arguments(ARG
                          ""
                          "${simple_args}"
                          "${list_args}"
                          ${ARGN}
    )

    set(INIT_PY_FILE ${CMAKE_CURRENT_BINARY_DIR}/${ARG_PKG}/__init__.py)
    set(CPPYY_PKG ${ARG_PKG})
    get_filename_component(CPPYY_LIB_SO ${ARG_LIB_FILE} NAME)
    get_filename_component(CPPYY_MAP ${ARG_MAP_FILE} NAME)

    list(JOIN ARG_NAMESPACES ", " _namespaces)

    if(NOT "${ARG_NAMESPACES}" STREQUAL "")
        list(JOIN ARG_NAMESPACES ", " _namespaces)
        set(NAMESPACE_INJECTIONS "from cppyy.gbl import ${_namespaces}")
    else()
        set(NAMESPACE_INJECTIONS "")
    endif()

    configure_file(${CMAKE_SOURCE_DIR}/__init__.py.in ${INIT_PY_FILE})

    set(INIT_PY_FILE ${INIT_PY_FILE} PARENT_SCOPE)
endfunction(cppyy_generate_init)


function(cppyy_add_bindings pkg pkg_version author author_email)
  set(simple_args URL LICENSE LANGUAGE_STANDARD)
  set(list_args INTERFACE_FILE HEADERS SELECTION_XML COMPILE_OPTIONS INCLUDE_DIRS LINK_LIBRARIES 
      EXTRA_PYTHONS GENERATE_OPTIONS NAMESPACES)
  cmake_parse_arguments(
    ARG
    ""
    "${simple_args}"
    "${list_args}"
    ${ARGN})
  if(NOT "${ARG_UNPARSED_ARGUMENTS}" STREQUAL "")
    message(SEND_ERROR "Unexpected arguments specified '${ARG_UNPARSED_ARGUMENTS}'")
  endif()
  string(REGEX MATCH "[^\.]+$" pkg_simplename ${pkg})
  string(REGEX REPLACE "\.?${pkg_simplename}" "" pkg_namespace ${pkg})
  set(pkg_dir ${CMAKE_CURRENT_BINARY_DIR})
  string(REPLACE "." "/" tmp ${pkg})
  set(pkg_dir "${pkg_dir}/${tmp}")
  set(lib_name "${pkg_namespace}${pkg_simplename}Cppyy")
  set(lib_file ${CMAKE_SHARED_LIBRARY_PREFIX}${lib_name}${CMAKE_SHARED_LIBRARY_SUFFIX})
  set(cpp_file ${CMAKE_CURRENT_BINARY_DIR}/${pkg_simplename}.cpp)
  set(pcm_file ${pkg_dir}/${CMAKE_SHARED_LIBRARY_PREFIX}${lib_name}_rdict.pcm)
  set(rootmap_file ${pkg_dir}/${CMAKE_SHARED_LIBRARY_PREFIX}${lib_name}.rootmap)
  set(extra_map_file ${pkg_dir}/${pkg_simplename}.map)

  #
  # Package metadata.
  #
  if("${ARG_URL}" STREQUAL "")
    string(REPLACE "." "-" tmp ${pkg})
    set(ARG_URL "https://pypi.python.org/pypi/${tmp}")
  endif()
  if("${ARG_LICENSE}" STREQUAL "")
    set(ARG_LICENSE "LGPL2.1")
  endif()
  #
  # Language standard.
  #
  if("${ARG_LANGUAGE_STANDARD}" STREQUAL "")
    set(ARG_LANGUAGE_STANDARD "14")
  endif()

  #
  # Set up genreflex args.
  #
  set(genreflex_args)
  if("${ARG_INTERFACE_FILE}" STREQUAL "")
      message(SEND_ERROR "No Interface specified")
  endif()
  list(APPEND genreflex_args "${ARG_INTERFACE_FILE}")
  if(NOT "${ARG_SELECTION_XML}" STREQUAL "")
      list(APPEND genreflex_args "--selection=${ARG_SELECTION_XML}")
  endif()

  list(APPEND genreflex_args "-o" "${cpp_file}")
  list(APPEND genreflex_args "--rootmap=${rootmap_file}")
  list(APPEND genreflex_args "--rootmap-lib=${lib_file}")
  list(APPEND genreflex_args "-l" "${lib_file}")

  foreach(dir ${ARG_INCLUDE_DIRS})
    list(APPEND genreflex_args "-I${dir}")
  endforeach(dir)

  set(genreflex_cxxflags "--cxxflags")
  list(APPEND genreflex_cxxflags "-std=c++${ARG_LANGUAGE_STANDARD}")

  # run genreflex
  file(MAKE_DIRECTORY ${pkg_dir})
  add_custom_command(OUTPUT ${cpp_file} ${rootmap_file} ${pcm_file}
    COMMAND ${genreflex_EXEC} ${genreflex_args} ${genreflex_cxxflags}
    WORKING_DIRECTORY ${pkg_dir}
  )

  #
  # Set up generator args.
  #
  list(APPEND ARG_GENERATE_OPTIONS "-std=c++${ARG_LANGUAGE_STANDARD}")
  foreach(dir ${ARG_INCLUDE_DIRS})
    list(APPEND ARG_GENERATE_OPTIONS "-I${dir}")
  endforeach(dir)
  #
  # Run generator. First check dependencies. TODO: temporary hack: rather
  # than an external dependency, enable libclang in the local build.
  #
  find_package(LibClang REQUIRED)
  get_filename_component(Cppyygen_EXECUTABLE ${genreflex_EXEC} DIRECTORY)
  set(Cppyygen_EXECUTABLE ${Cppyygen_EXECUTABLE}/cppyy-generator)
  #
  # Set up arguments for cppyy-generator.
  #
  set(generator_args)
  foreach(arg IN LISTS ARG_GENERATE_OPTIONS)
    string(REGEX REPLACE "^-" "\\\\-" arg ${arg})
    list(APPEND generator_args ${arg})
  endforeach()

  add_custom_command(OUTPUT ${extra_map_file}
      COMMAND ${LibClang_PYTHON_EXECUTABLE} ${Cppyygen_EXECUTABLE} --libclang ${LibClang_LIBRARY} --flags "\"${generator_args}\""
      ${extra_map_file} ${ARG_HEADERS} WORKING_DIRECTORY ${pkg_dir}
  )
  #
  # Compile/link.
  #
  add_library(${lib_name} SHARED ${cpp_file} ${pcm_file} ${rootmap_file} ${extra_map_file})
  set_property(TARGET ${lib_name} PROPERTY VERSION ${version})
  set_property(TARGET ${lib_name} PROPERTY CXX_STANDARD ${ARG_LANGUAGE_STANDARD})
  set_property(TARGET ${lib_name} PROPERTY LIBRARY_OUTPUT_DIRECTORY ${pkg_dir})
  target_include_directories(${lib_name} PRIVATE ${Cppyy_INCLUDE_DIRS} ${ARG_INCLUDE_DIRS})
  target_compile_options(${lib_name} PRIVATE ${ARG_COMPILE_OPTIONS})
  target_link_libraries(${lib_name} ${LibCling_LIBRARY} ${ARG_LINK_LIBRARIES})

  #
  # Generate __init__.py
  #
  cppyy_generate_init(PKG        ${pkg}
                      LIB_FILE   ${lib_file}
                      MAP_FILE   ${extra_map_file}
                      NAMESPACES ${ARG_NAMESPACES}
  )
  set(INIT_PY_FILE ${INIT_PY_FILE} PARENT_SCOPE)

  #
  # Generate setup.py
  #
  cppyy_generate_setup(${pkg} ${pkg_version} ${lib_file} ${rootmap_file} ${pcm_file} ${extra_map_file})
  set(SETUP_PY_FILE ${SETUP_PY_FILE} PARENT_SCOPE)

  file(WRITE ${setup_cfg} "[bdist_wheel]
universal=1
")
  #
  # Generate a pytest/nosetest sanity test script.
  #
  file(
    GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/test.py
    CONTENT "# pytest/nosetest sanity test script.
import logging
import os
import pydoc
import subprocess
import sys

from cppyy_backend import bindings_utils


SCRIPT_DIR = os.path.dirname(__file__)
pkg = '${pkg}'
PIPS = None


class Test(object):
    @classmethod
    def setup_class(klass):
        #
        # Make an attempt to check the verbosity setting (ignore quiet!).
        #
        verbose = [a for a in sys.argv[1:] if a.startswith(('-v', '--verbos'))]
        if verbose:
            logging.basicConfig(level=logging.DEBUG, format='%(asctime)s %(name)s %(levelname)s: %(message)s')
        else:
            logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
        global PIPS
        PIPS = bindings_utils.find_pips()

    @classmethod
    def teardown_class(klass):
        pass

    def setUp(self):
        '''This method is run once before _each_ test method is executed'''

    def teardown(self):
        '''This method is run once after _each_ test method is executed'''

    def test_install(self):
        for pip in PIPS:
            subprocess.check_call([pip, 'install', '--force-reinstall', '--pre', '.'], cwd=SCRIPT_DIR)

    def test_import(self):
        __import__(pkg)

    def test_help(self):
        pydoc.render_doc(pkg)

    def test_uninstall(self):
        for pip in PIPS:
            subprocess.check_call([pip, 'uninstall', '--yes', pkg], cwd=SCRIPT_DIR)
")
  #
  # Stage extra Python code.
  #
  foreach(extra_python IN LISTS ARG_EXTRA_PYTHONS)
    file(GENERATE OUTPUT ${pkg_dir}/../${extra_python} INPUT ${CMAKE_CURRENT_SOURCE_DIR}/${extra_python})
  endforeach()
  #
  # Return results.
  #
  set(target ${lib_name} PARENT_SCOPE)
  set(setup_py ${setup_py} PARENT_SCOPE)
endfunction(cppyy_add_bindings)

#
# Return a list of available pip programs.
#
function(cppyy_find_pips)
  execute_process(
    COMMAND python -c "from cppyy_backend import bindings_utils; print(\";\".join(bindings_utils.find_pips()))"
    OUTPUT_VARIABLE _stdout
    ERROR_VARIABLE _stderr
    RESULT_VARIABLE _rc
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(NOT "${_rc}" STREQUAL "0")
    message(FATAL_ERROR "Error finding pips: (${_rc}) ${_stderr}")
  endif()
  set(PIP_EXECUTABLES ${_stdout} PARENT_SCOPE)
endfunction(cppyy_find_pips)
