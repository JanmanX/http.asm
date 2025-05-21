/////////
//
// Sources:
//              https://github.com/apple/darwin-xnu/blob/main/bsd/kern/syscalls.master
//              /Library/Developer/CommandLineTools/SDKs/MacOSX14.5.sdk/usr/include/sys/socket.h
//              https://users.ece.utexas.edu/~valvano/mspm0/ArmClang_Reference_Guide_100067_0612_00_en.pdf
/////////


.global _start            // Provide program starting address to linker
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


// syscall.h
.set PF_INET, 2
.set SOCK_STREAM, 1
.set IPPROTO_TCP, 6




.data
socket_fd:
        .space 8

socket_client_fd:
        .space 8

sockaddr_in:
        .byte 0x10
        .byte PF_INET          // sin_family
        .hword 0x901F            // sin_port (port 8080 in network order 0x1F90 = 8080)
        .word 0x0100007f       // sin_addr = 127.0.0.1
        .byte 0               // zero
        .byte 0               // zero
        .byte 0               // zero
        .byte 0               // zero
        .byte 0               // zero
        .byte 0               // zero
        .byte 0               // zero
        .byte 0               // zero


buffer:
        .space 1024



.text
_start: 
// Socket
// 97	AUE_SOCKET	ALL	{ int socket(int domain, int type, int protocol); }
        mov X0, PF_INET                         // domain = AF_INET/PF_INET. This is for UDP, TCP, etc.
        mov X1, SOCK_STREAM                     // type = SOCK_STREAM = TCP
        mov X2,  IPPROTO_TCP                    // protocol = IP 
        mov X16, SYS_SOCKET                     // syscall number
        svc #0x80

        // Store socket fd in memory
        adrp X1, socket_fd@PAGE
        add X1, X1, socket_fd@PAGEOFF
        str X0, [X1]

// Bind
// 104	AUE_BIND	ALL	{ int bind(int s, const struct sockaddr *addr, socklen_t addrlen); }
        adrp X0, socket_fd@PAGE
        add X0, X0, socket_fd@PAGEOFF
        ldr X0, [X0] // load socket fd from memory
        adrp X1, sockaddr_in@PAGE
        add X1, X1, sockaddr_in@PAGEOFF
        mov X2, #16 // length of sockaddr_in
        mov X16, SYS_BIND 
        svc #0x80

// Listen
// 106	AUE_LISTEN	ALL	{ int listen(int s, int backlog); }
        adrp X0, socket_fd@PAGE
        add X0, X0, socket_fd@PAGEOFF
        ldr X0, [X0] // load socket fd from memory
        mov X1, #5 // backlog of connections
        mov X16, SYS_LISTEN
        svc #0x80

accept_loop:
// Accept
// 30	AUE_ACCEPT	ALL	{ int accept(int s, struct sockaddr *addr, socklen_t *addrlen); }
        adrp X0, socket_fd@PAGE
        add X0, X0, socket_fd@PAGEOFF
        ldr X0, [X0]
        mov X1, #0 // NULL
        mov X2, #0 // NULL
        mov X16, SYS_ACCEPT
        svc #0x80

        // Store client fd in memory
        adrp X1, socket_client_fd@PAGE
        add X1, X1, socket_client_fd@PAGEOFF
        str X0, [X1]

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


// Return to accept loop
        b accept_loop

// EXIT
        mov     X0, #0      // Use 0 return code
        mov     X16, #1     // Service command code 1 terminates this program
        svc     0           // Call MacOS to terminate the program




helloworld:      .ascii  "Hello World!\n"


//
// Assembler program to print "Hello World!"
// to stdout.
//
// X0-X2 - parameters to linux function services
// X16 - linux function number
//
// .global _start             // Provide program starting address to linker
// .align 2
// 
// // Setup the parameters to print hello world
// // and then call Linux to do it.
// 
// _start: mov X0, #1     // 1 = StdOut
//         adr X1, helloworld // string to print
//         mov X2, #13     // length of our string
//         mov X16, #4     // MacOS write system call
//         svc 0     // Call linux to output the string
// 
// // Setup the parameters to exit the program
// // and then call Linux to do it.
// 
//         mov     X0, #0      // Use 0 return code
//         mov     X16, #1     // Service command code 1 terminates this program
//         svc     0           // Call MacOS to terminate the program
// 
// helloworld:      .ascii  "Hello World!\n"
