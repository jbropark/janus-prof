#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <errno.h>
#include <arpa/inet.h>

#define NUM_MESSAGES 100
#define MESSAGE_SIZE 1400

int main() {
    int sockfd;
    struct sockaddr_in server_addr[NUM_MESSAGES];
    struct msghdr msgs[NUM_MESSAGES];
    struct iovec iovecs[NUM_MESSAGES];
    char messages[NUM_MESSAGES][MESSAGE_SIZE];

    // Create a UDP socket
    if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        perror("socket");
        exit(EXIT_FAILURE);
    }

    // Configure server address
    for (int i = 0; i < NUM_MESSAGES; i++) {
        memset(&server_addr[i], 0, sizeof(server_addr[i]));
        server_addr[i].sin_family = AF_INET;
        server_addr[i].sin_port = htons(12345);  // Change to desired port
        server_addr[i].sin_addr.s_addr = inet_addr("192.168.1.14");  // Change to desired IP
    }

    // Prepare messages

    // Send messages in a loop
    //
    struct timespec start, end;
    long seconds, nanoseconds;
    double elapsed;
    clock_gettime(CLOCK_MONOTONIC, &start);
    for (int i = 0; i < NUM_MESSAGES; i++) {
        iovecs[i].iov_base = messages[i];
        iovecs[i].iov_len = MESSAGE_SIZE;

        msgs[i].msg_name = &server_addr[i];
        msgs[i].msg_namelen = sizeof(server_addr[i]);
        msgs[i].msg_iov = &iovecs[i];
        msgs[i].msg_iovlen = 1;
        msgs[i].msg_control = NULL;
        msgs[i].msg_controllen = 0;
        msgs[i].msg_flags = 0;
        if (sendmsg(sockfd, &msgs[i], 0) < 0) {
            perror("sendmsg");
            close(sockfd);
            exit(EXIT_FAILURE);
        }
    }
    clock_gettime(CLOCK_MONOTONIC, &end);

    seconds = end.tv_sec - start.tv_sec;
    nanoseconds = end.tv_nsec - start.tv_nsec;
    elapsed = seconds + nanoseconds*1e-9;

    printf("Spent %.9f seconds.\n", elapsed);

    // Close socket
    close(sockfd);
    return 0;
}
