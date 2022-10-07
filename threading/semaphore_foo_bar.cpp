#include <functional>
#include <iostream>

#include "semaphore.h"

using namespace std;

class FooBar {
   private:
    int n;
    sem_t f, b;

   public:
    FooBar(int n) {
        this->n = n;
        sem_init(&f, 0, 1);
        sem_init(&b, 0, 0);
    }

    void foo(function<void()> printFoo) {
        for (int i = 0; i < n; i++) {
            sem_wait(&f);
            printFoo();
            sem_post(&b);
        }
    }

    void bar(function<void()> printBar) {
        for (int i = 0; i < n; i++) {
            sem_wait(&b);
            printBar();
            sem_post(&f);
        }
    }
};

int main() {
    cout << "Please see https://leetcode.com/problems/print-foobar-alternately/ to run." << endl;
}