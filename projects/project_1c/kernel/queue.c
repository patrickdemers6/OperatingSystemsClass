#include "queue.h"
#include <stdio.h>
// imported from Xinu's book:
// Operating System Design: The Xinu Approach, Linksys Version. 2011
// modified to match my code's names
#define queuehead(q) (q)
#define queuetail(q) ((q) + 1)
#define firstid(q) (qtable[queuehead(q)].next)
#define lastid(q) (qtable[queuetail(q)].prev)
#define isempty(q) (firstid(q) >= NPROC)
#define nonempty(q) (firstid(q) < NPROC)
#define firstkey(q) (qtable[firstid(q)].pass)
#define lastkey(q) (qtable[lastid(q)].pass)

// added: gets the head or tail given the queue number
#define gethead(q) (NPROC + (q << 1))
#define gettail(q) (NPROC + (q << 1) + 1)

void remove_pid(qentry qtable[QTABLE_SIZE], int pid_to_delete);

#if DEBUG
/**
 * @brief prints the current queue contents
 * 
 * @param qtable 
 */
void print_queue(qentry qtable[QTABLE_SIZE])
{
    int printed = 0;
    uint64_t h, t;
    for (int i = QUEUE_HIGH; i >= QUEUE_LOW; --i)
    {
        h = gethead(i);
        t = gettail(i);

        if (isempty(h))
            continue;
        printed = 1;
        while (h != t)
        {
            printf("%d ", h);
            h = qtable[h].next;
        }
        printf("%d\n", t);
    }
    if (printed)
        printf("\n");
}
#endif

/**
 * @brief Add a process to the qtable
 *
 * @param qtable add process to this qtable
 * @param queue_num the queue to add the process to
 * @param to_insert process to insert
 * @param pass the process' pass value
 */
void enqueue(qentry qtable[QTABLE_SIZE], int queue_num, uint64_t to_insert, uint64_t pass)
{
    uint64_t curr;
    curr = gethead(queue_num);

    qtable[to_insert].pass = pass;

    qtable[to_insert].next = qtable[curr].next;
    qtable[to_insert].prev = curr;
    qtable[curr].next = to_insert;
    qtable[qtable[to_insert].next].prev = to_insert;

#if DEBUG
    if (qtable[curr].next == 999 || qtable[curr].prev == 999)
    {
        print_queue(qtable);
        qtable[curr].next = -1;
    }

    printf("enqueue front %d\n", to_insert);
    print_queue(qtable);
#endif
}

void enqueue_back(qentry qtable[QTABLE_SIZE], int queue_num, uint64_t to_insert, uint64_t pass)
{
    uint64_t curr;
    curr = qtable[gettail(queue_num)].prev;

    qtable[to_insert].pass = pass;

    qtable[to_insert].next = qtable[curr].next;
    qtable[to_insert].prev = curr;
    qtable[curr].next = to_insert;
    qtable[qtable[to_insert].next].prev = to_insert;

#if DEBUG
    printf("enqueue back %d TO QUEUE %d\n", to_insert, queue_num);
    print_queue(qtable);
#endif
}

/**
 * @brief Pop the first process in qtable. Checks high, then medium, then low.
 *
 * @param qtable qtable to dequeue from
 * @return int64_t process ID to be run. -1 if qtable is empty
 */
int64_t dequeue(qentry qtable[QTABLE_SIZE])
{
    int head;
    uint64_t i, to_delete, idx;
    head = EMPTY;
    for (i = QUEUE_HIGH; i >= QUEUE_LOW; --i)
    {
        idx = NPROC + (i << 1);
        if (nonempty(idx))
        {
            head = idx;
            break;
        }
    }
    if (head == EMPTY)
    {
        return head;
    }

    to_delete = firstid(head);
    remove_pid(qtable, to_delete);
#if DEBUG
    printf("dequeue %d", to_delete);
    print_queue(qtable);
#endif
    return to_delete;
}

/**
 * @brief remove a process from qtable
 *
 * @param qtable the qtable to remove process from
 * @param pid_to_delete process to remove
 */
void remove_pid(qentry qtable[QTABLE_SIZE], int pid_to_delete)
{
    // previous' next -> to_delete's next
    qtable[qtable[pid_to_delete].prev].next = qtable[pid_to_delete].next;

    // to_delete's next previous = to delet's previous
    qtable[qtable[pid_to_delete].next].prev = qtable[pid_to_delete].prev;

    qtable[pid_to_delete].next = 999;
    qtable[pid_to_delete].prev = 999;
}

/**
 * @brief Setup the head and tail nodes of the qtable
 *
 * @param qtable qtable to initialize
 * @param num_queues the number of queues to setup
 */
void initialize(qentry qtable[QTABLE_SIZE], int num_queues)
{
    int i;
    for (i = QTABLE_SIZE - (num_queues << 1); i < QTABLE_SIZE; i += 2)
    {
        qtable[i].next = i + 1;
        qtable[i + 1].prev = i;
        qtable[i].pass = 0;
        qtable[i + 1].pass = UINT16_MAX;
    }
}
