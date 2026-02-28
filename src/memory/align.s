align:
#[ci [ addr, align ]
        remu t0,a0,a1
        sub a0,a0,t0
        beqz t0,1f
        add a0,a0,a1
1:      ret
