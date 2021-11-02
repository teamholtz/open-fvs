
#	$Id: makefile 3486 2021-04-13 20:42:22Z nickcrookston $	

# runs all the tests where the directory names start with FVS, ignoring errors.

export TestDirs = $(shell ls -d FVS*)

all : $(addsuffix .test,$(TestDirs))

%.test : 
	cd $(basename $@); ${MAKE} --ignore-errors
	

