# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.21

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Produce verbose output by default.
VERBOSE = 1

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /opt/homebrew/Cellar/cmake/3.21.3_1/bin/cmake

# The command to remove a file.
RM = /opt/homebrew/Cellar/cmake/3.21.3_1/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Users/lucaswells/Projects/open-fvs/trunk/bin/FVSls_CmakeDir

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/lucaswells/Projects/open-fvs/trunk/bin/FVSls_CmakeDir

# Include any dependencies generated for this target.
include CMakeFiles/FVSls.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include CMakeFiles/FVSls.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/FVSls.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/FVSls.dir/flags.make

CMakeFiles/FVSls.dir/Users/lucaswells/Projects/open-fvs/trunk/base/main.f.o: CMakeFiles/FVSls.dir/flags.make
CMakeFiles/FVSls.dir/Users/lucaswells/Projects/open-fvs/trunk/base/main.f.o: /Users/lucaswells/Projects/open-fvs/trunk/base/main.f
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/lucaswells/Projects/open-fvs/trunk/bin/FVSls_CmakeDir/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building Fortran object CMakeFiles/FVSls.dir/Users/lucaswells/Projects/open-fvs/trunk/base/main.f.o"
	/opt/homebrew/bin/gfortran $(Fortran_DEFINES) $(Fortran_INCLUDES) $(Fortran_FLAGS) -c /Users/lucaswells/Projects/open-fvs/trunk/base/main.f -o CMakeFiles/FVSls.dir/Users/lucaswells/Projects/open-fvs/trunk/base/main.f.o

CMakeFiles/FVSls.dir/Users/lucaswells/Projects/open-fvs/trunk/base/main.f.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing Fortran source to CMakeFiles/FVSls.dir/Users/lucaswells/Projects/open-fvs/trunk/base/main.f.i"
	/opt/homebrew/bin/gfortran $(Fortran_DEFINES) $(Fortran_INCLUDES) $(Fortran_FLAGS) -E /Users/lucaswells/Projects/open-fvs/trunk/base/main.f > CMakeFiles/FVSls.dir/Users/lucaswells/Projects/open-fvs/trunk/base/main.f.i

CMakeFiles/FVSls.dir/Users/lucaswells/Projects/open-fvs/trunk/base/main.f.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling Fortran source to assembly CMakeFiles/FVSls.dir/Users/lucaswells/Projects/open-fvs/trunk/base/main.f.s"
	/opt/homebrew/bin/gfortran $(Fortran_DEFINES) $(Fortran_INCLUDES) $(Fortran_FLAGS) -S /Users/lucaswells/Projects/open-fvs/trunk/base/main.f -o CMakeFiles/FVSls.dir/Users/lucaswells/Projects/open-fvs/trunk/base/main.f.s

# Object files for target FVSls
FVSls_OBJECTS = \
"CMakeFiles/FVSls.dir/Users/lucaswells/Projects/open-fvs/trunk/base/main.f.o"

# External object files for target FVSls
FVSls_EXTERNAL_OBJECTS =

FVSls: CMakeFiles/FVSls.dir/Users/lucaswells/Projects/open-fvs/trunk/base/main.f.o
FVSls: CMakeFiles/FVSls.dir/build.make
FVSls: CMakeFiles/FVSls.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/lucaswells/Projects/open-fvs/trunk/bin/FVSls_CmakeDir/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking Fortran executable FVSls"
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/FVSls.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/FVSls.dir/build: FVSls
.PHONY : CMakeFiles/FVSls.dir/build

CMakeFiles/FVSls.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/FVSls.dir/cmake_clean.cmake
.PHONY : CMakeFiles/FVSls.dir/clean

CMakeFiles/FVSls.dir/depend:
	cd /Users/lucaswells/Projects/open-fvs/trunk/bin/FVSls_CmakeDir && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/lucaswells/Projects/open-fvs/trunk/bin/FVSls_CmakeDir /Users/lucaswells/Projects/open-fvs/trunk/bin/FVSls_CmakeDir /Users/lucaswells/Projects/open-fvs/trunk/bin/FVSls_CmakeDir /Users/lucaswells/Projects/open-fvs/trunk/bin/FVSls_CmakeDir /Users/lucaswells/Projects/open-fvs/trunk/bin/FVSls_CmakeDir/CMakeFiles/FVSls.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/FVSls.dir/depend

