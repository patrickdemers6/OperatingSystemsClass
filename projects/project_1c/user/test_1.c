// author: Patrick Demers
// test two cpu bound processes
// automatically runs the two workloads, no input necessary.
// output: cpu log of context switches
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/log.h"
#define COUNT 1000000000

struct logentry schedlog[LOG_SIZE];

#pragma GCC push_options
#pragma GCC optimize("O0")

uint64 run()
{
    uint64 acc = 0;
    for (uint64 i = 0; i < COUNT; i++)
    {
        acc += i;
    }
    return acc;
}

#pragma GCC pop_options

int main(int argc, char *argv[])
{
    int a, b;
    startlog();

    a = fork();
    if (a == 0)
    {
        // child
        nice(-19);
        run();
        exit(0);
    }
    else
    {
        b = fork();
        // parent
        if (b == 0)
        {
            // child
            nice(-19);
            run();
            exit(0);
        }
    }
    printf("parent pid: %d\n", getpid());
    printf("first child pid: %d\n", a);
    printf("second child pid: %d\n", b);

    wait(0);
    wait(0);
    printf("long running completed\n\n");

    uint64 count = getlog(schedlog);

    for (int i = 0; i < count; i++)
    {
        if (schedlog[i].priority_boost)
            printf("** priority boost at time %d **\n", schedlog[i].time);
        else
            printf("pid %d started at %d in queue %s\n", schedlog[i].pid, schedlog[i].time, schedlog[i].queue == 2 ? "High" : schedlog[i].queue == 1 ? "Medium"
                                                                                                                                                     : "Low");
    }

    exit(0);
}