# Makefile for lake problem
CC = g++
FLAGS = -Wall -O3 -Wno-unused-local-typedefs
INCL = -I boost_1_56_0 

SOURCES = $(wildcard *.cpp)
OBJECTS = $(SOURCES:.cpp=.o)
EXE = lake.exe

all: $(SOURCES) $(EXE)
	rm $(OBJECTS)

.cpp.o:
	$(CC) -c $(CFLAGS) $^ -o $@ $(INCL)
	
$(EXE): $(OBJECTS)
	$(CC) $(OBJECTS) $(CFLAGS) -o $@ $(INCL)

clean:
	rm -f $(OBJECTS) $(EXE)
