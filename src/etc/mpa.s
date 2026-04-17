.include "const/mpa.s"
mpa_create:
#[ci [ int_64 ]
        save an=1,sn=1

        li a0,sizeof_MPA
        call malloc
        bnez a0,1f
        ebreak

1:      mv s1,a0

        li t0,MPA_START_SIZE
        sd t0,MPA__size(a0)
        li t1,0x8
        mul a0,t0,t1
        call malloc
        bnez a0,1f
        ebreak

1:      sd a0,s1,MPA__data(s1)
        ld t0,_a0(sp)
        sd t0,0x0(a0)
        beqz t0,1f        
        li t0,0x1
        sd t0,MPA__count(s1)
        j 9f
        
1:      sd zero,MPA__count(s1)

9:      mv a0,s1

        restore
        ret

mpa_copy:
#[ci [ mpa ]
        save an=1,sn=1

        li a0,0x0
        call mpa_create

        mv s1,a0

        ld a0,MPA__data(s1)
        call free

        ld t0,_a0(sp)

        ld t1,MPA__count(t0)
        sd t1,MPA__count(s1)

        ld a0,MPA__size(t0)
        sd a0,MPA__size(s1)
        
        call malloc
        bnez a0,1f
        ebreak

1:      sd a0,MPA__data(s1)

        mv a0,s1

        restore
        ret

mpa_add:
#[ci [ a, b ]
        save an=2,sn=2

        li s1,0x0
        ld t0,MPA__data(a0)
        ld t1,MPA__data(a1)
        li s2,0x0
        ld t2,MPA__count(a0)
        ld t3,MPA__count(a1)
        
        bge s2,t3,2f
1:      ld t4,(t0)
        ld t5,(t1)
        add t6,t4,t5
        add t6,t6,s1
        sd t6,(t0)
        addi t0,t0,0x8
        addi t1,t1,0x8
        addi s2,s2,0x1
        sltu s1,t6,t4

        blt s2,t3,1b
        beqz s1,2f

        bgt t2,t3,3f
        ld t4,MPA__size(a0)
        blt t2,t4,3f

        slli a0,t4,0x4
        call malloc
        bnez a0,1f
        ebreak
        
1:      
        
3:
        
2:
        restore
        ret

mpa_destroy:
#[ci [ mpa ]
        save an=1

        ld a0,MPA__data(a0)
        call free
        ld a0,_a0(sp)
        call free

        restore
        ret
