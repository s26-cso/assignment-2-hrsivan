#include <stdio.h>
#include <dlfcn.h>

typedef int (*op) (int, int);

int main(){
    char operation[10];
    int a, b;
    char library[50];
    void* getlib = NULL;
    op func;

    while(scanf("%s %d %d", operation, &a, &b) == 3){
        snprintf(library, 50, "./lib%s.so", operation);

        getlib = dlopen(library, RTLD_LAZY);

        func = (op) dlsym(getlib, operation);

        printf("%d\n", func(a, b));

        dlclose(getlib);
        getlib = NULL;
    }

    return 0;
}