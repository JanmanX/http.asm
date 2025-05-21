.global handler

.align 2

////////// DEFINES
// syscalls
.set SYS_OPEN, 2
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

filepath:
        .ascii "./index.html"
        .byte 0

socket_client_fd:
        .space 8

buffer:
        .space 1024
        .byte 0


file_buffer:
        .space 8192
        .byte 0


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
        adrp x0, socket_client_fd@PAGE
        add x0, x0, socket_client_fd@PAGEOFF
        ldr x0, [x0]
        adrp x1, response@PAGE
        add x1, x1, response@PAGEOFF
        mov x2, #100 // length of buffer
        mov x16, SYS_WRITE
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


//prepare_file:
//// Open file
//// 57	AUE_OPEN	ALL	{ int open(const char *pathname, int flags); }
//        adrp x0, filepath@PAGE
//        add x0, x0, filepath@PAGEOFF
//        mov x1, #0x00000000 // O_RDONLY
//        mov x16, SYS_OPEN
//        svc #0x80
//
//        mov x19 , x0 // save file fd
//
//// read file
//// 63	AUE_READ	ALL	{ ssize_t read(int fd, void *buf, size_t count); }
//        mov x0, x0 // file fd
//        adrp x1, response@PAGE
//        add x1, x1, response@PAGEOFF
//        mov x2, #8192 // length of buffer
//        mov x16, SYS_READ // syscall number
//        svc #0x80
//
//// close
//// 57	AUE_CLOSE	ALL	{ int close(int fd); }
//        mov x0, x19 // file fd
//        mov x16, SYS_CLOSE
//        svc #0x80
//
//// Return
//        ret