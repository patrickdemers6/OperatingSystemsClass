all: $(patsubst %.cpp, %.out, $(wildcard *.cpp))

#Rule how to create arbitary .out files. 
#First state what is needed for them e.g. additional headers, .cpp files in an include folder...
#Then the command to create the .out file, probably you want to add further options to the g++ call.
%.out: %.cpp Makefile
	g++ $< -lpthread -o $@ -std=c++0x

clean:
	rm -f *.out