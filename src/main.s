.global _start

#[ci    [CONSTANTS]
.equ UART_ADDRESS,              0x10000000
.equ LINE_STATUS_REGISTER,      0x5
.equ LINE_CONTROL_REGISTER,     0x3
.equ FIFO_CONTROL_REGISTER,     0x2
.equ INTERRUPT_ENABLE_REGISTER, 0x1
.equ LINE_STATUS_DATA_READY,    0x1
.equ HEAP_SIZE, 0x10000000
mtime = 0x0200BFF8
mtime_frec = 10*1000*1000
mtime_64hz = mtime_frec >> 6
.include "const/errors.s"

#[gi    [macros]
.include "macros.s"
.include "debug.s"
.include "error.s"

#[yi    [data]
        .section .data
str: .string "NEOH"
hex: .ascii "0123456789abcdef"
HEX: .ascii "0123456789ABCDEF"
.include "data/bios.s"
.include "data/machine.s"
.include "data/device_manager.s"
.include "data/image.s"
.include "data/vga.s"
.include "data/tests.s"
#[yi    [ BSS ]
        .section .bss
        .align 16
.include "bss/pci.s"
.include "bss/uart.s"
.include "bss/bios.s"
.include "bss/device_manager.s"
.include "bss/filesystem.s"
        .align 16
.include "bss/stack.s"
        .align 16
.include "bss/heap.s"

#[mi    [Program]
        .section .text.start
.include "start.s"
        .section .text.drivers
.include "drivers/pci.s"
.include "drivers/plic.s"

.include "drivers/uart/main.s"
.include "drivers/uart/interrupt.s"
.include "drivers/uart/api.s"
.include "drivers/uart/print.s"
.include "drivers/uart/printf.s"
.include "drivers/uart/print_number.s"

.include "drivers/vga/main.s"

.include "drivers/bochs-display/main.s"
.include "drivers/bochs-display/sprite.s"

#.include "drivers/usb/xhcl/init.s"
#.include "drivers/usb/xhcl/api.s"

.include "drivers/virtio/main.s"
.include "drivers/virtio/pci/transport.s"
.include "drivers/virtio/pci/keyboard.s"
.include "drivers/virtio/pci/block.s"
.include "drivers/virtio/input.s"

        .section .text.kernel
.include "kernel/device_manager/open.s"
.include "kernel/device_manager/main.s"
.include "kernel/device_manager/debug.s"
.include "kernel/device_manager/display.s"
.include "kernel/device_manager/keyboard.s"
.include "kernel/device_manager/blk_dev.s"


.include "kernel/filesystem/mount.s"

.include "kernel/filesystem/ext2/mount.s"
.include "kernel/filesystem/ext2/inode.s"
.include "kernel/filesystem/ext2/read.s"

        .section .text.memory
.include "memory/memcpy.s"
.include "memory/heap.s"
.include "memory/kernel.s"
.include "memory/memset.s"
.include "memory/align.s"
.include "memory/rrip.s"
        .section .text.machine
.include "machine.s"
        .section .text.bios
.include "bios.s"
        .section .text.programs
.include "programs/bounce.s"
.include "tests.s"
    .section .text.end
