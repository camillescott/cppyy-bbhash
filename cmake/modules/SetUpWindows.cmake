set(ROOT_PLATFORM win32)

#---Global variables for Win32 platform-------------------------------------------------
set(SYSLIBS advapi32.lib)
set(XLIBS)
set(CILIBS)
set(CRYPTLIBS)

#----Check the compiler that is used-----------------------------------------------------
if(CMAKE_COMPILER_IS_GNUCXX)

  set(ROOT_ARCHITECTURE win32gcc)

  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pipe  -Wall -W -Woverloaded-virtual")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pipe -Wall -W")
  set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -std=legacy")

  set(CINT_CXX_DEFINITIONS "-DG__REGEXP -DG__UNIX -DG__SHAREDLIB -DG__OSFDLL -DG__ROOT -DG__REDIRECTIO -DG__STD_EXCEPTION ${SPECIAL_CINT_FLAGS}")
  set(CINT_C_DEFINITIONS "-DG__REGEXP -DG__UNIX -DG__SHAREDLIB -DG__OSFDLL -DG__ROOT -DG__REDIRECTIO -DG__STD_EXCEPTION ${SPECIAL_CINT_FLAGS}")


  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined")

  # Select flags.
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g -DNDEBUG")
  set(CMAKE_CXX_FLAGS_RELEASE        "-O2 -DNDEBUG")
  set(CMAKE_CXX_FLAGS_OPTIMIZED      "-Ofast -DNDEBUG")
  set(CMAKE_CXX_FLAGS_DEBUG          "-g")
  set(CMAKE_CXX_FLAGS_DEBUGFULL      "-g3")
  set(CMAKE_CXX_FLAGS_PROFILE        "-g3 -ftest-coverage -fprofile-arcs")
  set(CMAKE_C_FLAGS_RELWITHDEBINFO   "-O2 -g -DNDEBUG")
  set(CMAKE_C_FLAGS_RELEASE          "-O2 -DNDEBUG")
  set(CMAKE_C_FLAGS_OPTIMIZED        "-Ofast -DNDEBUG")
  set(CMAKE_C_FLAGS_DEBUG            "-g")
  set(CMAKE_C_FLAGS_DEBUGFULL        "-g3 -fno-inline")
  set(CMAKE_C_FLAGS_PROFILE          "-g3 -fno-inline -ftest-coverage -fprofile-arcs")


  #---Set Linker flags----------------------------------------------------------------------
  set(CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS "${CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS}")
  set(CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS "${CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS}")

  # Settings for cint
  set(CPPPREP "${CMAKE_CXX_COMPILER} -E -C")
  set(CXXOUT "-o ")

  set(EXEEXT "")
  set(SOEXT "so")

elseif(MSVC)

  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
     set(ROOT_ARCHITECTURE win64)
     set(WIN_EXTRA_DEFS "-D_WINDOWS -DWIN32 -D_AMD64_")
  elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
     set(ROOT_ARCHITECTURE win32)
     set(WIN_EXTRA_DEFS "-D_WINDOWS -DWIN32 -D_X86_")
  endif()

  set(ROOT_ARCHITECTURE win32)

  math(EXPR VC_MAJOR "${MSVC_VERSION} / 100")
  math(EXPR VC_MINOR "${MSVC_VERSION} % 100")

  if(winrtdebug)
    set(BLDCXXFLAGS "-Zc:__cplusplus -MDd -GR")
    set(BLDCFLAGS   "-MDd")
  else()
    set(BLDCXXFLAGS "-Zc:__cplusplus -MD -GR")
    set(BLDCFLAGS   "-MD")
  endif()

  if(CMAKE_PROJECT_NAME STREQUAL ROOT)
    set(CMAKE_CXX_FLAGS "-nologo -I${CMAKE_SOURCE_DIR}/build/win -FIw32pragma.h -FIsehmap.h ${BLDCXXFLAGS} ${WIN_EXTRA_DEFS} -EHsc- -W3 -wd4141 -wd4291 -wd4244 -wd4049 -D_XKEYCHECK_H -D_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER -DNOMINMAX -D_CRT_SECURE_NO_WARNINGS")
    set(CMAKE_C_FLAGS   "-nologo -I${CMAKE_SOURCE_DIR}/build/win -FIw32pragma.h -FIsehmap.h ${BLDCFLAGS} ${WIN_EXTRA_DEFS} -EHsc- -W3 -D_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER -DNOMINMAX")
    install(FILES ${CMAKE_SOURCE_DIR}/build/win/w32pragma.h  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT headers)
    install(FILES ${CMAKE_SOURCE_DIR}/build/win/sehmap.h  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT headers)
  else()
    set(CMAKE_CXX_FLAGS "-nologo -FIw32pragma.h -FIsehmap.h ${BLDCXXFLAGS} ${WIN_EXTRA_DEFS} -EHsc- -W3 -wd4244")
    set(CMAKE_C_FLAGS   "-nologo -FIw32pragma.h -FIsehmap.h ${BLDCFLAGS} ${WIN_EXTRA_DEFS} -EHsc- -W3")
  endif()

  #---Select compiler flags----------------------------------------------------------------
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -Z7")
  set(CMAKE_CXX_FLAGS_RELEASE        "-O2")
  set(CMAKE_CXX_FLAGS_OPTIMIZED      "-O2")
  set(CMAKE_CXX_FLAGS_DEBUG          "-Od -Z7")
  set(CMAKE_C_FLAGS_RELWITHDEBINFO   "-O2 -Z7")
  set(CMAKE_C_FLAGS_RELEASE          "-O2")
  set(CMAKE_C_FLAGS_OPTIMIZED        "-O2")
  set(CMAKE_C_FLAGS_DEBUG            "-Od -Z7")

  #---Set Linker flags----------------------------------------------------------------------
  set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -ignore:4049,4206,4217,4221 -incremental:no")
  set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -ignore:4049,4206,4217,4221 -incremental:no")

  set(SOEXT dll)
  set(EXEEXT exe)

  foreach( OUTPUTCONFIG ${CMAKE_CONFIGURATION_TYPES} )
    string( TOUPPER ${OUTPUTCONFIG} OUTPUTCONFIG )
    set( CMAKE_RUNTIME_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY} )
    set( CMAKE_LIBRARY_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_LIBRARY_OUTPUT_DIRECTORY} )
    set( CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${OUTPUTCONFIG} ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY} )
  endforeach( OUTPUTCONFIG CMAKE_CONFIGURATION_TYPES )

else()
  message(FATAL_ERROR "There is no setup for compiler '${CMAKE_CXX_COMPILER}' on this Windows system up to now. Stop cmake at this point.")
endif()


