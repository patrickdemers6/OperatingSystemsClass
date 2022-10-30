// class that implements the nice command.
// A user is able to start a program and set its
// nice value using this command.

// Authors: Kyle Rooney and Patrick Demers

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/log.h"
struct logentry schedlog[LOG_SIZE];

int main(int argc, char *argv[])
{
    // Error checking
    if (argc < 3) {
        printf("Unexpected number of arguments.\n");
        return 1;
    }
    int n;
    char* program;

    n = atoi(argv[1]);
    program = argv[2];
        
    nice(n);
    exec(program, &argv[2]);

    return 0;
}