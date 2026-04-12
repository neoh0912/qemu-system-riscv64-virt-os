.include "const/char_display.s"
CHAR_DISPLAY_PARSER_STATE_TABLE:

sg = PARSER_STATE__ground
se = PARSER_STATE__escape
sce = PARSER_STATE__csi_entry
scig = PARSER_STATE__csi_ignore
sci = PARSER_STATE__csi_intermediate
scp = PARSER_STATE__csi_param
sei = PARSER_STATE__escape_intermediate

ae = TRANSITION_ACTION__execute
an = TRANSITION_ACTION__none
ai = TRANSITION_ACTION__ignore
ap = TRANSITION_ACTION__print
aed = TRANSITION_ACTION__esc_dispatch
acd = TRANSITION_ACTION__csi_dispatch
ac = TRANSITION_ACTION__collect
aparam = TRANSITION_ACTION__param


_0x0_0x17:
.rept (0x18) # 0x0-0x17
    .byte sg,ae
    .byte se,ae
    .byte sei,ae
    .byte sce,ae
    .byte scp,ae
    .byte scig,ae
    .byte sci,ae
.endr
_0x18:
.rept 7 # 0x18
    .byte sg,ae
.endr
_0x19:
#[ri 0x19
    .byte sg,ae
    .byte se,ae
    .byte sei,ae
    .byte sce,ae
    .byte scp,ae
    .byte scig,ae
    .byte sci,ae
_0x1A:
.rept 7 # 0x1A
    .byte sg,ae
.endr
_0x1B:
.rept 7 # 0x1B
    .byte se,an
.endr
_0x1C_0x1F:
.rept (0x4) # 0x1C - 0x1F
    .byte sg,ae
    .byte se,ae
    .byte sei,ae
    .byte sce,ae
    .byte scp,ae
    .byte scig,ae
    .byte sci,ae
.endr
_0x20_0x2F:
.rept (0x10) # 0x20-0x2F
    .byte sg,ap
    .byte sei,ac
    .byte sei,ac
    .byte sci,ac
    .byte sci,ac
    .byte scig,ai
    .byte sci,ac
.endr
_0x30_0x39:
.rept (0xa) # 0x30-0x39
    .byte sg,ap
    .byte sg,aed
    .byte sg,aed
    .byte scp,aparam
    .byte scp,aparam
    .byte scig,ai
    .byte scig,an
.endr
_0x3A:
#[ri 0x3A
    .byte sg,ap
    .byte sg,aed
    .byte sg,aed
    .byte scig,an
    .byte scp,aparam
    .byte scig,ai
    .byte scig,an
_0x3B:
#[ri 0x3B
    .byte sg,ap
    .byte sg,aed
    .byte sg,aed
    .byte scp,aparam
    .byte scp,aparam
    .byte scig,ai
    .byte scig,an
_0x3C_0x3F:
.rept (0x4) # 0x3C-0x3F
    .byte sg,ap
    .byte sg,aed
    .byte sg,aed
    .byte scp,ac
    .byte scig,an
    .byte scig,ai
    .byte scig,an
.endr
_0x40_0x4F:
.rept (0x10) # 0x40-0x4F
    .byte sg,ap
    .byte sg,aed
    .byte sg,aed
    .byte sg,acd
    .byte sg,acd
    .byte sg,an
    .byte sg,acd
.endr
_0x50:
#[ri 0x50
    .byte sg,ap
    .byte sg,an
    .byte sg,aed
    .byte sg,acd
    .byte sg,acd
    .byte sg,an
    .byte sg,acd
_0x51_0x57:
.rept (0x7) # 0x51-0x57
    .byte sg,ap
    .byte sg,aed
    .byte sg,aed
    .byte sg,acd
    .byte sg,acd
    .byte sg,an
    .byte sg,acd
.endr
_0x58:
#[ri 0x58
    .byte sg,ap
    .byte sg,an
    .byte sg,aed
    .byte sg,acd
    .byte sg,acd
    .byte sg,an
    .byte sg,acd
_0x59:
#[ri 0x59
    .byte sg,ap
    .byte sg,aed
    .byte sg,aed
    .byte sg,acd
    .byte sg,acd
    .byte sg,an
    .byte sg,acd
_0x5A:
#[ri 0x5A
    .byte sg,ap
    .byte sg,aed
    .byte sg,aed
    .byte sg,acd
    .byte sg,acd
    .byte sg,an
    .byte sg,acd
_0x5B:
#[ri 0x5B
    .byte sg,ap
    .byte sce,an
    .byte sg,aed
    .byte sg,acd
    .byte sg,acd
    .byte sg,an
    .byte sg,acd
_0x5C:
#[ri 0x5C
    .byte sg,ap
    .byte sg,aed
    .byte sg,aed
    .byte sg,acd
    .byte sg,acd
    .byte sg,an
    .byte sg,acd
_0x5D:
#[ri 0x5D
    .byte sg,ap
    .byte sce,an
    .byte sg,aed
    .byte sg,acd
    .byte sg,acd
    .byte sg,an
    .byte sg,acd
_0x5E:
#[ri 0x5E
    .byte sg,ap
    .byte sg,an
    .byte sg,aed
    .byte sg,acd
    .byte sg,acd
    .byte sg,an
    .byte sg,acd
_0x5F:
#[ri 0x5F
    .byte sg,ap
    .byte sg,an
    .byte sg,aed
    .byte sg,acd
    .byte sg,acd
    .byte sg,an
    .byte sg,acd
_0x60_0x7E:
.rept (0x1F) # 0x60-0x7E
    .byte sg,ap
    .byte sg,aed
    .byte sg,aed
    .byte sg,acd
    .byte sg,acd
    .byte sg,an
    .byte sg,acd
.endr
_0x7F:
#[ri 0x7F
    .byte sg,ap
    .byte se,ai
    .byte sei,ai
    .byte sce,ai
    .byte scp,ai
    .byte scig,ai
    .byte sci,ai
_0x80_0x8F:
.rept (7*0x10) # 0x80-0x8F
    .byte sg,ae
.endr
_0x90:
.rept 7 # 0x90
    .byte sg,an
.endr
_0x91_0x97:
.rept (7*7) # 0x91-0x97
    .byte sg,ae
.endr
_0x98:
.rept 7 # 0x98
    .byte sg,an
.endr
_0x99_0x9A:
.rept (7*2) # 0x99-0x9A
    .byte sg,ae
.endr
_0x9B:
.rept (7) # 0x9B
    .byte sce,an
.endr
_0x9C_0x9F:
.rept (7*4) # 0x9C-0x9F
    .byte sg,an
.endr
_end:
