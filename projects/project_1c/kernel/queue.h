#include <stdint.h> 
#include "param.h"
#define NPROC 64
// added: pulled from project specification
#define MAX_UINT64 (-1) 
#define EMPTY MAX_UINT64 
#define NUM_QUEUES 3
#define QTABLE_SIZE (NPROC + 2*NUM_QUEUES)
#define QUEUE_HIGH 2
#define QUEUE_MEDIUM 1
#define QUEUE_LOW 0
#define DEFAULT_PASS 1
#define priority(p) (p->nice > 10 ? QUEUE_LOW : p->nice > -10 ? QUEUE_MEDIUM : QUEUE_HIGH)
#define quantum(p) (p->queue == QUEUE_HIGH ? 1 : p->queue == QUEUE_MEDIUM ? 10 : 15)
#define add_to_queue(p) (enqueue_back(qtable, p->queue, p - proc, DEFAULT_PASS))

// a node of the linked list 
typedef struct qentry { 
    uint64_t pass; // used by the stride scheduler to keep the list sorted 
    uint64_t prev; // index of previous qentry in list 
    uint64_t next; // index of next qentry in list 
} qentry;

// added: signatures of functions in queue.c
void enqueue(qentry qtable[QTABLE_SIZE], int queue_num, uint64_t to_insert, uint64_t pass);

void enqueue_back(qentry qtable[QTABLE_SIZE], int queue_num, uint64_t to_insert, uint64_t pass);

int64_t dequeue(qentry qtable[QTABLE_SIZE]);

void initialize(qentry qtable[QTABLE_SIZE], int num_queues);

void print_queue(qentry qtable[QTABLE_SIZE]);