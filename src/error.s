.macro break_on_error
        bgeu a0,zero,.L_break_\@_end
        ebreak
.L_break_\@_end:
.endm
        
