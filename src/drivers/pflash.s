#[ci    [DEFINES]
    .equ PFLASH_ADDRESS, 0x22000000
    .equ PFLASH_WP,      0x40
    .equ PFLASH_READY,   0x80
    .equ PFLASH_RESET,   0xFF

pflash_



pflash_lbu:
        ret
pflash_lhu:
        ret
pflash_lwu:
        ret
pflash_ld:
        ret
