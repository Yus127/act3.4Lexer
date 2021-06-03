#include<stdio.h>

#define NAME "blabla"
#define AGE 10

int runner()
{
    static int count = 0;
    count++;
    return count;
    //Comaterio :D
}

int main()
{
    char vowels[] = {'A', 'E', 'I', 'O', 'U'};

    printf("%d ", runner());
    printf("%d ", runner());
    return 0;
    
}
