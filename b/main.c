//codigo de ejemplo   ~ ! # $ %  ^ & * ( ) _ + | \ - = { } [ ] : ; < > ? , . /
#include <stdio.h>
struct person
{
   int age;
   float weight;
};

int main()
{
    struct person *personPtr, person1;
    int numero = 4.5e3;
    int a = 2 + 4 * 7303;
    personPtr = &person1;
    /*
    Un comentario
    */
    printf("Enter age: ");
    scanf("%d", &personPtr->age);

    printf("Enter weight: ");
    scanf("%f", &personPtr->weight);

    printf("Displaying:\n");
    printf("Age: %d\n", personPtr->age);
    printf("weight: %f", personPtr->weight);

    return 0;
}
