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
.set SYS_SOCKET, 97
.set SYS_BIND, 104
.set SYS_LISTEN, 106
.set SYS_ACCEPT, 30


// syscall.h
.set PF_INET, 2
.set SOCK_STREAM, 1
.set PROTOCOL_IP, 0




// Variables
// Socket
// 4 bytes for the socket file descriptor
socket_fd: .space 4

// sockaddr_in
sockaddr_in:
sockaddr_in_len: .byte
sockaddr_in_family: .byte 
sockaddr_in_port: .hword  // 2 bytes
sockaddr_in_addr: .byte 4 // 4 bytes
sockaddr_in_zero: .byte 8 // 8 bytes





.text
_start: 
// Setup socket
// 97	AUE_SOCKET	ALL	{ int socket(int domain, int type, int protocol); }
        mov X0, PF_INET  // domain = AF_INET/PF_INET. This is for UDP, TCP, etc.
        mov X1, SOCK_STREAM // type = SOCK_STREAM = TCP
        mov X2 , PROTOCOL_IP // protocol = IP 
        mov X16, SYS_SOCKET // syscall number
        svc #0x80


        str X0, socket_fd

// Setup bind



// 104	AUE_BIND	ALL	{ int bind(int s, const struct sockaddr *addr, socklen_t addrlen); }
        ldr X0, socket_fd
        ldr X1, sockaddr_in
        mov X2, #16 // length of sockaddr_in
        mov X16, SYS_BIND // syscall number
        svc #0x80



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
