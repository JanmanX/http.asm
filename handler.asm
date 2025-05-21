.global handler

.align 2

////////// DEFINES
// syscalls
.set SYS_READ, 3
.set SYS_WRITE, 4
.set SYS_OPEN, 5
.set SYS_CLOSE, 6
.set SYS_ACCEPT, 30
.set SYS_SOCKET, 97
.set SYS_BIND, 104
.set SYS_LISTEN, 106


.data
filepath:
        .ascii "./index.html"
        .byte 0

socket_client_fd:
        .space 8

buffer:
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
        mov x2, #512// length of buffer
        mov x16, SYS_READ // syscall number
        svc #0x80

// Write request to stdout
// 64	AUE_WRITE	ALL	{ ssize_t write(int fd, const void *buf, size_t count); }
        mov x0, 1 // stdout
        adrp x1, buffer@PAGE
        add x1, x1, buffer@PAGEOFF
        mov x2, #512// length of buffer
        mov x16, SYS_WRITE // syscall number
        svc #0x80

////////////// Open response file and write to file_buffer /////////////////
// 57	AUE_OPEN	ALL	{ int open(const char *pathname, int flags); }
        adrp x0, filepath@PAGE
        add x0, x0, filepath@PAGEOFF
        mov x1, #0x00000000 // O_RDONLY
        mov x16, SYS_OPEN
        svc #0x80

        mov x19 , x0 // save file fd

// read file
// 63	AUE_READ	ALL	{ ssize_t read(int fd, void *buf, size_t count); }
        mov x0, x0 // file fd
        adrp x1, buffer@PAGE
        add x1, x1, buffer@PAGEOFF
        mov x2, #8192 // length of buffer
        mov x16, SYS_READ // syscall number
        svc #0x80

// close
// 57	AUE_CLOSE	ALL	{ int close(int fd); }
        mov x0, x19 // file fd
        mov x16, SYS_CLOSE
        svc #0x80

// Write response to client
// 64	AUE_WRITE	ALL	{ ssize_t write(int fd, const void *buf, size_t count); }
        adrp x0, socket_client_fd@PAGE
        add x0, x0, socket_client_fd@PAGEOFF
        ldr x0, [x0]
        adrp x1, buffer@PAGE
        add x1, x1, buffer@PAGEOFF
        mov x2, #8192// length of buffer
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
