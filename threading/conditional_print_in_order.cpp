#include <functional>
#include <mutex>
#include <iostream>
using namespace std;

class Foo {
   public:
    pthread_mutex_t m;
    pthread_cond_t c;
    int done = 0;
    Foo() {
        pthread_mutex_init(&m, nullptr);
        pthread_cond_init(&c, nullptr);
    }

    void first(function<void()> printFirst) {
        // printFirst() outputs "first". Do not change or remove this line.

        pthread_mutex_lock(&m);
        printFirst();
        done = 1;
        pthread_cond_broadcast(&c);
        pthread_mutex_unlock(&m);
    }

    void second(function<void()> printSecond) {
        // printSecond() outputs "second". Do not change or remove this line.

        pthread_mutex_lock(&m);
        while (done != 1) {
            pthread_cond_wait(&c, &m);
        }

        printSecond();
        done = 2;
        pthread_cond_broadcast(&c);
        pthread_mutex_unlock(&m);
    }

    void third(function<void()> printThird) {
        // printThird() outputs "third". Do not change or remove this line.

        pthread_mutex_lock(&m);
        while (done != 2) {
            pthread_cond_wait(&c, &m);
        }

        printThird();
        pthread_mutex_unlock(&m);
    }
};

int main() {
    cout << "Please see https://leetcode.com/problems/print-in-order/ to run." << endl;
}