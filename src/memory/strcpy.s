strcpy:
#[ci [ dest, str ]
        save

1:      lbu t0,(a1)
        beqz t0,1f
        sb t0,(a0)

        addi a0,a0,0x1
        addi a1,a1,0x1
        j 1b

1:      restore
        ret

strcpy_ascii_to_unicode:
#[ci [ dest, str ]
        save

1:      lbu t0,(a1)
        beqz t0,1f
        sh t0,(a0)

        addi a0,a0,0x2
        addi a1,a1,0x1
        j 1b

1:      restore
        ret
