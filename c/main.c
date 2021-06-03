#include <stdio.h>
#define BOOL char
#define FALSE 0
#define TRUE 1

int main() {
  int a1 = 3;
  float b2 = 4.5;
  double c3 = 5.25;
  float sum;

  int a = 0, b = 1, c = 2, d = 3, e = 4;
  a = b - c + d * e;
  printf("%d", a); /* will print 1-2+3*4 = 11 */



  printf("The sum of a, b, and c is %f.", sum);
  return 0;
}
