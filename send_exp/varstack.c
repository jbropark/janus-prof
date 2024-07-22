#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void func(int n)
{
  char s[n + 1];
  memset(s, 'a', n);
  s[n] = 0;
  printf("String: %s\n", s);
}

int main()
{
  func(10);
  func(13);
  return 0;
}
