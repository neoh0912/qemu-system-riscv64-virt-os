.global _start

#[ci    [CONSTANTS]
.equ UART_ADDRESS,              0x10000000
.equ LINE_STATUS_REGISTER,      0x5
.equ LINE_CONTROL_REGISTER,     0x3
.equ FIFO_CONTROL_REGISTER,     0x2
.equ INTERRUPT_ENABLE_REGISTER, 0x1
.equ LINE_STATUS_DATA_READY,    0x1
.equ HEAP_SIZE, 0x10000000

#[gi    [macros]
.include "macros.s"
.include "debug.s"

#[yi    [data]
        .section .data
str: .string "NEOH"
hex: .ascii "0123456789abcdef"
HEX: .ascii "0123456789ABCDEF"
.include "data/bios.s"
.include "data/ivshmem.s"
.include "data/machine.s"
.include "data/device_manager.s"
#[yi    [ BSS ]
        .section .bss
        .align 16
.include "bss/pci.s"
.include "bss/uart.s"
.include "bss/ivshmem.s"
.include "bss/bios.s"
.include "bss/device_manager.s"
        .align 16
.include "bss/stack.s"
        .align 16
.include "bss/heap.s"

#[mi    [Program]
        .section .text.start
.include "start.s"
        .section .text.drivers
.include "drivers/pci.s"
.include "drivers/ivshmem.s"
.include "drivers/PLIC.s"

.include "drivers/uart/main.s"
.include "drivers/uart/interrupt.s"
.include "drivers/uart/api.s"
.include "drivers/uart/print.s"
.include "drivers/uart/printf.s"
.include "drivers/uart/print_number.s"

.include "drivers/vga/main.s"
.include "drivers/vga/api.s"

#.include "drivers/usb/xhcl/init.s"
#.include "drivers/usb/xhcl/api.s"

.include "drivers/virtio/pci/transport.s"
.include "drivers/virtio/pci/keyboard.s"
.include "drivers/virtio/input.s"

        .section .text.kernel
.include "kernel/device_manager/main.s"
.include "kernel/device_manager/debug.s"
        .section .text.memory
.include "memory/memcpy.s"
.include "memory/heap.s"
.include "memory/kernel.s"
.include "memory/memset.s"
.include "memory/align.s"
        .section .text.machine
.include "machine.s"
        .section .text.bios
.include "bios.s"
        .section .text.programs
.include "programs/bounce.s"
    .section .text.end
