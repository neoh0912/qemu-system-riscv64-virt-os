save_count = 1
restore_count = 1

.macro salloc n=0
        sd   ra,  -8(sp)
        sd   fp, -16(sp)
        mv   fp, sp
        addi sp, sp, (-16 -\n)
.endm
.macro salb n
        addi sp,sp,-(\n)
.endm
.macro salh n
        addi sp,sp,-(2*(\n))
.endm
.macro salw n
        addi sp,sp,-(4*(\n))
.endm
.macro sald n
        addi sp,sp,-(8*(\n))
.endm
.macro sfree
        mv   sp, fp
        ld   fp, -16(sp)        
        ld   ra,  -8(sp)
.endm
.macro save_all
    sd x2,-240(sp)
    addi sp,sp,-248
    sd x1,(sp)
    sd x3,16(sp)
    sd x4,24(sp)
    sd x5,32(sp)
    sd x6,40(sp)
    sd x7,48(sp)
    sd x8,56(sp)
    sd x9,64(sp)
    sd x10,72(sp)
    sd x11,80(sp)
    sd x12,88(sp)
    sd x13,96(sp)
    sd x14,104(sp)
    sd x15,112(sp)
    sd x16,120(sp)
    sd x17,128(sp)
    sd x18,136(sp)
    sd x19,144(sp)
    sd x20,152(sp)
    sd x21,160(sp)
    sd x22,168(sp)
    sd x23,176(sp)
    sd x24,184(sp)
    sd x25,192(sp)
    sd x26,200(sp)
    sd x27,208(sp)
    sd x28,216(sp)
    sd x29,224(sp)
    sd x30,232(sp)
    sd x31,240(sp)
.endm
.macro load_all
    ld x1,(sp)
    ld x3,16(sp)
    ld x4,24(sp)
    ld x5,32(sp)
    ld x6,40(sp)
    ld x7,48(sp)
    ld x8,56(sp)
    ld x9,64(sp)
    ld x10,72(sp)
    ld x11,80(sp)
    ld x12,88(sp)
    ld x13,96(sp)
    ld x14,104(sp)
    ld x15,112(sp)
    ld x16,120(sp)
    ld x17,128(sp)
    ld x18,136(sp)
    ld x19,144(sp)
    ld x20,152(sp)
    ld x21,160(sp)
    ld x22,168(sp)
    ld x23,176(sp)
    ld x24,184(sp)
    ld x25,192(sp)
    ld x26,200(sp)
    ld x27,208(sp)
    ld x28,216(sp)
    ld x29,224(sp)
    ld x30,232(sp)
    ld x31,240(sp)
    ld x2,8(sp)
    
.endm

.macro save an=0 sn=0 dn=0 wn=0 hn=0 bn=0
        sd   ra,  -8(sp)
        sd   fp, -16(sp)
        mv   fp, sp
        addi sp,sp,-(0x10+(\an)*8+(\sn)*8+(\dn)*8+(\wn)*4+(\hn)*2+(\bn))
        
        save_count = save_count+1

_i = 0
_an = (\an)
_sn = (\sn)
_dn = (\dn)
_wn = (\wn)
_hn = (\hn)
_bn = (\bn)

        .rept (\an)
            sd a\\()+,_i(sp)
            _a\\()+ = _i
            _i = _i + 0x8
        .endr
        
        .rept (\sn+1)
        .if \\()+ >= 1
            sd s\\()+,_i(sp)
            _s\\()+ = _i
            _i = _i + 0x8        
        .endif
        .endr

        .rept (\dn)
            _d\\()+ = _i
            _i = _i + 0x8
        .endr
        .rept (\wn)
            _w\\()+ = _i
            _i = _i + 0x4
        .endr
        .rept (\hn)
            _h\\()+ = _i
            _i = _i + 0x2
        .endr
        .rept (\bn)
            _b\\()+ = _i
            _i = _i + 0x1
        .endr
.endm


.macro restore
    restore_count = restore_count+1
    .if restore_count != save_count
        .error "restore"
    .endif

    .rept (_sn+1)
        .if \\()+ >= 1
        ld s\\()+,_s\\()+(sp)
        .endif
    .endr

    mv   sp, fp
    ld   fp, -16(sp)        
    ld   ra,  -8(sp)    
.endm
