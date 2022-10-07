#include <functional>
#include <iostream>

using namespace std;

class FooBar {
   private:
    int n, turn;
    pthread_mutex_t lock;
    pthread_cond_t bar_cond, foo_cond;

   public:
    FooBar(int n) {
        this->n = n;
        this->turn = 0;
        pthread_mutex_init(&lock, nullptr);
        pthread_cond_init(&bar_cond, nullptr);
        pthread_cond_init(&foo_cond, nullptr);
    }

    void foo(function<void()> printFoo) {
        for (int i = 0; i < n; i++) {
            pthread_mutex_lock(&lock);
            while (turn == 1)
                pthread_cond_wait(&foo_cond, &lock);
            printFoo();
            turn = 1;
            pthread_cond_signal(&bar_cond);
            pthread_mutex_unlock(&lock);
        }
    }

    void bar(function<void()> printBar) {
        for (int i = 0; i < n; i++) {
            pthread_mutex_lock(&lock);
            while (turn == 0)
                pthread_cond_wait(&bar_cond, &lock);
            printBar();
            turn = 0;
            pthread_cond_signal(&foo_cond);
            pthread_mutex_unlock(&lock);
        }
    }
};

int main() {
    cout << "Please see https://leetcode.com/problems/print-foobar-alternately/ to run." << endl;
}