#include <semaphore.h>

#include <functional>
#include <iostream>

using namespace std;

class Foo {
   public:
    sem_t first_done, second_done;
    Foo() {
        sem_init(&first_done, 0, 0);
        sem_init(&second_done, 0, 0);
    }

    void first(function<void()> printFirst) {
        printFirst();
        sem_post(&first_done);
    }

    void second(function<void()> printSecond) {
        sem_wait(&first_done);
        printSecond();
        sem_post(&second_done);
    }

    void third(function<void()> printThird) {
        sem_wait(&second_done);
        printThird();
    }
};

int main() {
    cout << "Please see https://leetcode.com/problems/print-in-order/ to run." << endl;
}