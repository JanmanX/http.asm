#include<stdio.h>
#include<sys/types.h>
#include<sys/socket.h>
#include<netinet/in.h>

int main(int argc, char *argv[])
{
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        perror("socket");
        return 1;
    }

    // bind
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(8080);
    addr.sin_addr.s_addr = INADDR_ANY;

    if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("bind");
        return 1;
    }

    // listen
    if (listen(sock, 5) < 0) {
        perror("listen");
        return 1;
    }

    // accept
    struct sockaddr_in client_addr;
    socklen_t client_len = sizeof(client_addr);
    int client_sock = accept(sock, (struct sockaddr *)&client_addr, &client_len);
    if (client_sock < 0) {
        perror("accept");
        return 1;
    }
    printf("Accepted connection from %s:%d\n",
           inet_ntoa(client_addr.sin_addr), ntohs(client_addr.sin_port));


    // read
    char buffer[1024];
    ssize_t bytes_read = read(client_sock, buffer, sizeof(buffer) - 1);


    // Close 
    close(client_sock);

    return 0;
}