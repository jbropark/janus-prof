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
#include <linux/udp.h>

#define NUM_MESSAGES 10
#define MESSAGE_SIZE 1400

int main() {
    int sockfd;
    struct sockaddr_in server_addr;
    struct msghdr msg;
    struct iovec iovecs[NUM_MESSAGES];
    char messages[NUM_MESSAGES][MESSAGE_SIZE];
    char *control = calloc(NUM_MESSAGES, CMSG_SPACE(sizeof(uint16_t)));

    // Create a UDP socket
    if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
        perror("socket");
        exit(EXIT_FAILURE);
    }

    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(12345);
    server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");

    // Prepare messages

    // Send messages in a loop
    //
    struct timespec start, end;
    long seconds, nanoseconds;
    double elapsed;
    msg.msg_name = &server_addr;
    msg.msg_namelen = sizeof(server_addr);
    msg.msg_iov = iovecs;
    msg.msg_iovlen = sizeof(iovecs);
    msg.msg_control = control;
    msg.msg_controllen = NUM_MESSAGES * CMSG_SPACE(sizeof(uint16_t));
    msg.msg_flags = 0;
    clock_gettime(CLOCK_MONOTONIC, &start);
    struct cmsghdr *cm = CMSG_FIRSTHDR(&msg);
    for (int i = 0; i < NUM_MESSAGES; i++) {
        iovecs[i].iov_base = messages[i];
        iovecs[i].iov_len = MESSAGE_SIZE;
	printf("cm: %p\n", cm);
	cm->cmsg_level = IPPROTO_UDP;
        cm->cmsg_type = UDP_SEGMENT;
        cm->cmsg_len = CMSG_LEN(sizeof(uint16_t));
	*((uint16_t *) CMSG_DATA(cm)) = 699;
	cm = CMSG_NXTHDR(&msg, cm);
    }
    if (sendmsg(sockfd, &msg, 0) < 0) {
        perror("sendmsg");
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
