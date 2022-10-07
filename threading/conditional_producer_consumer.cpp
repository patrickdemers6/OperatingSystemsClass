#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <unistd.h>

#include <iostream>
#include <queue>
#include <string>
#include <variant>
using namespace std;

pthread_mutex_t mutex;
pthread_cond_t empty, filled;

queue<char> contents;

void *consumer(void *arg) {
    cout << "consumer started" << endl;
    int count = 0;

    // print the 26 characters, could also be an infinite loop
    while (count < 26) {
        pthread_mutex_lock(&mutex);

        // wait until there is something in the contents queue
        while (!contents.size()) {
            // start up thread once the buffer is filled
            // this alert comes from pthread_cond_signal(&filled)
            pthread_cond_wait(&filled, &mutex);
        }

        // print the letter and remove from queue
        cout << contents.front();
        contents.pop();

        count++;

        // signal that the buffer is empty, producer can start again
        pthread_cond_signal(&empty);

        // unlock the mutex, end critical section
        pthread_mutex_unlock(&mutex);
    }

    cout << endl;
    return nullptr;
}

void *producer(void *arg) {
    cout << "producer started" << endl;

    // print the upper case alphabet
    for (char i = 65; i < 91; ++i) {
        // lock the mutex, start critical section
        pthread_mutex_lock(&mutex);

        // if contents.size() is zero, we don't need to wait anymore
        while (contents.size()) {
            // wait until empty condition
            // mutex lock is released while waiting
            pthread_cond_wait(&empty, &mutex);
        }

        // push the letter
        contents.push(i);

        // signal that the buffer is filled
        pthread_cond_signal(&filled);

        // unlock the mutex, end critical section
        pthread_mutex_unlock(&mutex);
    }
    return nullptr;
}

int main() {
    // the threads that will be created for consumer and producer
    pthread_t c, p;

    // initialize the empty and filled conditions
    pthread_cond_init(&empty, nullptr);
    pthread_cond_init(&filled, nullptr);

    // the mutex used to protect critical sections
    pthread_mutex_init(&mutex, nullptr);

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