.global _start

#[ci    [CONSTANTS]
.equ UART_ADDRESS,              0x10000000
.equ LINE_STATUS_REGISTER,      0x5
.equ LINE_CONTROL_REGISTER,     0x3
.equ FIFO_CONTROL_REGISTER,     0x2
.equ INTERRUPT_ENABLE_REGISTER, 0x1
.equ LINE_STATUS_DATA_READY,    0x1
.equ HEAP_LIST_SIZE, 0x400000
.equ HEAP_BLOCK_SIZE, 64
.equ HEAP_SIZE, HEAP_LIST_SIZE*HEAP_BLOCK_SIZE

.equ E_ERROR,0x1

#[gi    [macros]
.include "macros.s"
.include "debug.s"

#[yi    [data]
        .section .data
str: .string "NEOH"
hex: .ascii "0123456789abcdef"
HEX: .ascii "0123456789ABCDEF"
hex_prefix: .string "0x"
.include "data/uart_async.data"
.include "data/machine.data"
.include "data/bios.data"
.include "data/ivshmem.data"
.include "data/heap.data"
.include "data/pci.data"
.include "data/vga.data"
#.include "data/xhcl.data"
stack: .zero 65536
stack_pointer:
buffer: .space 512
data.end:           

#[yi    [ BSS ]
        .section .bss
        .align 16
heap_list: .space HEAP_LIST_SIZE*4
heap: .space HEAP_SIZE


#[mi    [Program]
        .section .text.start
.include "start.s"
        .section .text.drivers
.include "lib/drivers/uart.s"
.include "lib/drivers/uart_async.s"
.include "lib/drivers/pci.s"
.include "lib/drivers/ivshmem.s"
.include "lib/drivers/PLIC.s"

.include "lib/drivers/vga/init.s"
.include "lib/drivers/vga/api.s"

#.include "lib/drivers/usb/xhcl/init.s"
#.include "lib/drivers/usb/xhcl/api.s"

.include "lib/drivers/virtio/pci/transport.s"
.include "lib/drivers/virtio/pci/keyboard.s"
.include "lib/drivers/virtio/input.s"
        .section .text.print
.include "lib/print/print.s"
.include "lib/print/printf.s"
.include "lib/print/print_number.s"
        .section .text.memory
.include "lib/memory/memcpy.s"
.include "lib/memory/heap.s"
        .section .text.machine
.include "machine.s"
        .section .text.bios
.include "bios.s"
        .section .text.drive
.include "drive.s"
        .section .text.programs
.include "programs/bounce.s"

    .section .text.end
