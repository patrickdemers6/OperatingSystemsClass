#include <pthread.h>
#include <stdio.h>

#include <iostream>

#define ITERATIONS 100000000
#define EXPECTED (ITERATIONS << 1)

using namespace std;

pthread_mutex_t mutex;

unsigned long long int total = 0;

void *adder(void *arg) {
    for (long long int i = 0; i < ITERATIONS; ++i) {
        // lock the mutex, start critical section
        pthread_mutex_lock(&mutex);

        // can freely modify total since in critical section
        ++total;

        // unlock the mutex, end critical section
        pthread_mutex_unlock(&mutex);
    }
    return nullptr;
}

int main() {
    // the threads that will be created for adding
    pthread_t a, b;

    // the mutex used to protect critical sections
    pthread_mutex_init(&mutex, nullptr);

    // create the two threads
    pthread_create(&a, nullptr, &adder, nullptr);
    pthread_create(&b, nullptr, &adder, nullptr);

    // wait for the two threads to be finished
    pthread_join(a, nullptr);
    pthread_join(b, nullptr);

    // print the output
    cout << "calculated: " << total << endl
         << "expected: " << EXPECTED << endl;

    cout << "threads joined again" << endl;
}