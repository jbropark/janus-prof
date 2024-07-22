#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <arpa/inet.h>

#define NUM_MESSAGES 16
#define MESSAGE_SIZE 1400
#define BUFFER_SIZE 1024 * 1024

int main() {
    int sockfd;
    struct sockaddr_in server_addr;
    struct mmsghdr msgs[NUM_MESSAGES];
    struct iovec iovecs[NUM_MESSAGES];
    char messages[NUM_MESSAGES][MESSAGE_SIZE];
    struct timespec start, end;
    long seconds, nanoseconds;
    double elapsed;
    int sndbuf_size = BUFFER_SIZE;
    int rcvbuf_size = BUFFER_SIZE;


    // Create a UDP socket
    if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        perror("socket");
        exit(EXIT_FAILURE);
    }

    /*
    int flags = fcntl(sockfd, F_GETFL, 0);
    if (fcntl(sockfd, F_SETFL, flags | O_NONBLOCK) < 0) {
        perror("fcntl failed");
        close(sockfd);
        exit(EXIT_FAILURE);
    }
    */

    /*
    // 송신 버퍼 크기 설정
    if (setsockopt(sockfd, SOL_SOCKET, SO_SNDBUF, &sndbuf_size, sizeof(sndbuf_size)) < 0) {
        perror("setsockopt SO_SNDBUF failed");
        close(sockfd);
        exit(EXIT_FAILURE);
    }

    // 수신 버퍼 크기 설정
    if (setsockopt(sockfd, SOL_SOCKET, SO_RCVBUF, &rcvbuf_size, sizeof(rcvbuf_size)) < 0) {
        perror("setsockopt SO_RCVBUF failed");
        close(sockfd);
        exit(EXIT_FAILURE);
    }
    */

    // Configure server address
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(12345);  // Change to desired port
    server_addr.sin_addr.s_addr = inet_addr("192.168.1.14");  // Change to desired IP

    clock_gettime(CLOCK_MONOTONIC, &start);
    // Prepare messages
    for (int i = 0; i < NUM_MESSAGES; i++) {
        iovecs[i].iov_base = messages[i];
        iovecs[i].iov_len = MESSAGE_SIZE;

        msgs[i].msg_hdr.msg_name = &server_addr;
        msgs[i].msg_hdr.msg_namelen = sizeof(server_addr);
        msgs[i].msg_hdr.msg_iov = &iovecs[i];
        msgs[i].msg_hdr.msg_iovlen = 1;
        msgs[i].msg_hdr.msg_control = NULL;
        msgs[i].msg_hdr.msg_controllen = 0;
        msgs[i].msg_hdr.msg_flags = 0;
        msgs[i].msg_len = 0;
    }
    // Send messages
    int ret = sendmmsg(sockfd, msgs, NUM_MESSAGES, 0);
    if (ret < 0) {
        perror("sendmmsg");
        close(sockfd);
        exit(EXIT_FAILURE);
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
