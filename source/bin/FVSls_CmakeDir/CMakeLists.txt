

##If edits are made, make them in the CMakeList.txt file in the parent directory.
cmake_minimum_required (VERSION 2.8)

if (CMAKE_GENERATOR MATCHES "Visual Studio 10")
  set (CMAKE_C_FLAGS   "/D_WINDOWS /W3 /Zm100" CACHE STRING "VS10 mod A" FORCE)
  set (CMAKE_CXX_FLAGS "/D_WINDOWS /W3 /Zm100" CACHE STRING "VS10 mod B" FORCE)
  message(STATUS "Building FVS variant with VS10/Intel")
elseif (CMAKE_GENERATOR MATCHES "MinGW Makefiles")
  message(STATUS "Building FVS variant with MinGW")
elseif (CMAKE_GENERATOR MATCHES "Unix Makefiles")
  message(STATUS "Building FVS variant with Unix")
else ()
  message(STATUS "Unknown toolchain exiting")
  return()
endif()

project (FVS C CXX Fortran)

set (CMAKE_Fortran_Format FIXED)
set (CMAKE_VERBOSE_MAKEFILE ON)

file(GLOB sourceList FVS*_sourceList.txt)
get_filename_component (slfn ${sourceList} NAME CACHE)
string(REPLACE "_sourceList.txt" "" prgName ${slfn})
string(REPLACE "FVS" "" varName ${prgName})
message(STATUS "slfn = ${slfn} prgName= ${prgName}")

if (CMAKE_GENERATOR MATCHES "Visual Studio 10")
  add_definitions(-DANSI -DWINDOWS -D_WINDLL)
  elseif (CMAKE_GENERATOR MATCHES "MinGW Makefiles")
  add_definitions(-DANSI -DWINDOWS -D_WINDLL -DCMPgcc)
  elseif (CMAKE_GENERATOR MATCHES "Unix Makefiles")
  add_definitions(-DANSI -DCMPgcc) 
else()
endif()

set (OUTPUT_NAME ${prgName})
set (includeDirs)
set (CsourceSQL)
set (CsourceFFE)
#set (CsourceCFIM)
set (FsourceFVS)
set (FsourceMAIN)

file(STRINGS ${prgName}_sourceList.txt fileList)

foreach (fn ${fileList})
  get_filename_component (fname   ${fn} NAME CACHE)
  get_filename_component (pname   ${fn} PATH CACHE)
  get_filename_component (extname ${fn} EXT  CACHE)

  if (${extname} STREQUAL ".h" OR ${extname} STREQUAL ".F77")
    list (APPEND includeDirs  ${pname})
  endif()

  if (${extname} STREQUAL ".f")
    if (${fname} STREQUAL "main.f")
      list (APPEND FsourceMAIN ${fn})
    else()
      list (APPEND FsourceFVS ${fn})
    endif()
  elseif(${extname} STREQUAL ".c" OR ${extname} STREQUAL ".cpp")
    if(fname STREQUAL "sqlite3.c" OR fname STREQUAL "fvsqlite3.c" OR fname STREQUAL "apisubsc.c")
      list (APPEND CsourceSQL ${fn})
    else()
      list (APPEND CsourceFFE ${fn})
    endif()
  endif()
  unset (fname   CACHE)
  unset (pname   CACHE)
  unset (extname CACHE)
endforeach(fn)

list (REMOVE_DUPLICATES includeDirs)
list (APPEND includeDirs ${CMAKE_CURRENT_BINARY_DIR})

include_directories(BEFORE ${includeDirs})

message(STATUS "includeDirs= ${includeDirs}")
message(STATUS "CsourceSQL= ${CsourceSQL}")
message(STATUS "CsourceFFE= ${CsourceFFE}")
message(STATUS "FsourceFVS= ${FsourceFVS}")
message(STATUS "FsourceMAIN= ${FsourceMAIN}")

message(STATUS "FVSvariant = FVS${varName}")

add_library(FVSsql SHARED ${CsourceSQL})
add_library(FVSfofem SHARED ${CsourceFFE})
#add_library(FVScfim SHARED ${CsourceCFIM})  ### delete this line permanently
add_library(FVS_${varName} SHARED ${FsourceFVS})
add_executable (${prgName} ${FsourceMAIN})

#target_link_libraries(${prgName} FVS_${varName} FVSsql FVSfofem )
#target_link_libraries(FVS_${varName} FVSsql FVSfofem )

set_target_properties(${prgName} PROPERTIES LINKER_LANGUAGE Fortran)

# set up function alias for DLL containing CPP code

if (CMAKE_GENERATOR MATCHES "MinGW Makefiles")
  set_target_properties(FVSfofem PROPERTIES LINK_FLAGS -Wl,--add-stdcall-alias)
  # set_target_properties(FVScfim PROPERTIES LINK_FLAGS -Wl,--add-stdcall-alias)
endif()
