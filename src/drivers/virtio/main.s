.include "const/virtio/virt_queue.s"
virtio_supply_buffer_to_queue:
#[ci [ virt_queue, buffer, len, flag ]
        save
addr = 0x0
len = 0x8
flags = 0xc
next = 0xe
        ld t0,VQ_DESCRIPTOR_TABLE(a0)
        ld t1,VQ_AVAIL_RING(a0)
        ld t3,VQ_SIZE(a0)
        lhu t2,0x2(t1)
        remu t2,t2,t3
        
        slli t3,t2,0x1
        addi t3,t3,0x4
        add t3,t3,t1
        slli t4,t2,0x4
        add t4,t4,t0
        ld t5,addr(t4)
        bnez t5,1f
        sd a1,addr(t4)
        sd a2,len(t4)
        sd a3,flags(t4)
        sd zero,next(t4)
        sh t2,(t3)
        fence rw,rw
        addi t2,t2,0x1
        sh t2,0x2(t1)
        fence rw,rw
        li a0,0x0
        j 2f
1:      li a0,-EAGAIN
2:
        restore
        ret
