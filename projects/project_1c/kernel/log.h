// file created for project 1b
// defined a logentry struct which stores a log entry

#define LOG_SIZE 100

struct logentry
{
    int pid;  // process id
    int time; // number of ticks
    int queue; // queue the process is in
    int priority_boost; // whether this was a priority boost
};

extern int time;