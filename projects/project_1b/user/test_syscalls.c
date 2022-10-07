// Class that tests the ability to show the current
// pid as well as the time.

// Author Patrick Demers

#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/log.h"
struct logentry schedlog[LOG_SIZE];

int main()
{
    nice(10);
    startlog();
    if (fork() > 0)
        sleep(5);
    uint64 count = getlog(schedlog);

    // Error checking
    if (count == -1)
        return -1;

    // loop through and print the pid and the time
    for (int i = 0; i < count; i++) {
     printf("%d %d\n", schedlog[i].pid, schedlog[i].time);
    }
  printf("---\n");

    return 0;
}