#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>


int main()
{
  int n;
  unsigned int m = sizeof(n);
  int fdsocket;
  fdsocket = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP); // example
  getsockopt(fdsocket,SOL_SOCKET,SO_RCVBUF,(void *)&n, &m);
  printf("size: %d\n", n);
}
