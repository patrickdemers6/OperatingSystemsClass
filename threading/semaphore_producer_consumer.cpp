#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <unistd.h>

#include <iostream>
#include <queue>
#include <string>
#include <variant>
using namespace std;
sem_t sem_c, sem_p;
queue<char> contents;

void *consumer(void *arg) {
    cout << "consumer started" << endl;
    int count = 0;

    // print the 26 characters, could also be an infinite loop
    while (count < 26) {
        // wait until the consumer is ready to be run
        sem_wait(&sem_c);

        // print the letter and remove from queue
        cout << contents.front();
        contents.pop();

        count++;

        // tell the producer it can run again
        sem_post(&sem_p);
    }

    cout << endl;
    return nullptr;
}

void *producer(void *arg) {
    cout << "producer started" << endl;

    // print the upper case alphabet
    for (char i = 65; i < 91; ++i) {
        // wait until producer is ready to be run
        sem_wait(&sem_p);

        // push the letter
        contents.push(i);

        // tell the consumer it is ready to run
        sem_post(&sem_c);
    }
    return nullptr;
}

int main() {
    // the threads that will be created for consumer and producer
    pthread_t c, p;

    // the consumer semaphore starts at 0 since it is not ready to run
    sem_init(&sem_c, 0, 0);

    // the producer semaphore starts at 1 since it is ready to run
    sem_init(&sem_p, 0, 1);

    // create the consumer, it will wait until producer sends something
    pthread_create(&c, nullptr, &consumer, nullptr);

    // one second, for demonstration
    usleep(1000000);

    // create the producer
    pthread_create(&p, nullptr, &producer, nullptr);

    // wait for producer and consumer to be finished
    pthread_join(c, nullptr);
    pthread_join(p, nullptr);

    cout << "threads joined again" << endl;
}