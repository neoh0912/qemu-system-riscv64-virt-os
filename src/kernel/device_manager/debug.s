.include "const/device_manager/device_tree_struct.s"
.include "const/device_manager/device_struct.s"
device_manager_print_devices:
_s1 = 0x0
_s2 = 0x8
_s3 = 0x10
_s4 = 0x18
        salloc 0
        sald 4
        sd s1,_s1(sp)
        sd s2,_s2(sp)
        sd s3,_s3(sp)
        sd s4,_s4(sp)

        la a0,devices_str
        call print_string

        ld s1,device_manager_device_tree_root
        addi sp,sp,-0x8*4
        
1:      ld t0,device_tree__device_type(s1)
        sd t0,(sp)
        ld s2,device_tree__start(s1)
2:      beqz s2,2f
        
        ld t0,device__id(s2)
        sd t0,0x8(sp)
        sd s2,0x10(sp)
        ld t0,device__parent(s2)
        sd t0,0x18(sp)
        mv a1,sp
        la a0,device_fstr
        call printf
        
        ld s2,0x30(s2)
        j 2b

2:      ld s1,next(s1)
        bnez s1,1b

        addi sp,sp,0x8*4
        
        ld s1,_s1(sp)
        ld s2,_s2(sp)
        ld s3,_s3(sp)
        ld s4,_s4(sp)
        sfree
        ret
