.global handler

.align 2

////////// DEFINES
// syscalls
.set SYS_READ, 3
.set SYS_WRITE, 4
.set SYS_CLOSE, 6
.set SYS_ACCEPT, 30
.set SYS_SOCKET, 97
.set SYS_BIND, 104
.set SYS_LISTEN, 106


.data
    response:
        .ascii "HTTP/1.1 200 OK\r\nContent-Length: 13\r\n\r\nHello, World!\n"
        .byte 0

socket_client_fd:
        .space 8

buffer:
        .space 1024




.text
handler:
// store client fd
        adrp x1, socket_client_fd@PAGE
        add x1, x1, socket_client_fd@PAGEOFF
        str x0, [x1]

// Read
// 63	AUE_READ	ALL	{ ssize_t read(int fd, void *buf, size_t count); }
        mov x0, x0 // client fd
        adrp x1, buffer@PAGE
        add x1, x1, buffer@PAGEOFF
        mov x2, #10 // length of buffer
        mov x16, SYS_READ // syscall number
        svc #0x80

// Write
// 64	AUE_WRITE	ALL	{ ssize_t write(int fd, const void *buf, size_t count); }
        mov x0, #1 // stdout
        mov x16, SYS_WRITE
        adrp x1, buffer@PAGE
        add x1, x1, buffer@PAGEOFF
        mov x2, #1023 // length of buffer
        svc 0x80

// Close
// 57	AUE_CLOSE	ALL	{ int close(int fd); }
        adrp x0, socket_client_fd@PAGE
        add x0, x0, socket_client_fd@PAGEOFF
        ldr x0, [x0]
        mov x16, SYS_CLOSE
        svc #0x80

// Return
        ret