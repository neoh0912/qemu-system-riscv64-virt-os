.include "const/device_manager/device_tree_struct.s"
.include "const/device_manager/device_struct.s"
device_manager_print_devices:
        save sn=4,dn=4

        la a0,devices_str
        call print_string

        ld s1,device_manager_device_tree_root
        
1:      ld t0,device_tree__device_type(s1)
        sd t0,_d0(sp)
        ld s2,device_tree__start(s1)
2:      beqz s2,2f
        
        ld t0,device__id(s2)
        sd t0,_d1(sp)
        sd s2,_d2(sp)
        ld t0,device__parent(s2)
        sd t0,_d3(sp)
        mv a1,sp
        addi a1,a1,_d0
        la a0,device_fstr
        call printf
        
        ld s2,device__next(s2)
        j 2b

2:      ld s1,device_tree__next(s1)
        bnez s1,1b
        
        restore
        ret
