.include "const/csr.s"
.include "const/ptrace.s"
.include "const/thread_info.s"
handle_exception:
        csrrw tp,CSR_SCRATCH, tp
        bnez tp,1f

        csrr tp, CSR_SCRATCH
        sd sp, TASK_INFO__KERNEL_SP(tp)
        sd fp, TAST_INFO__KERNEL_FP(tp)

1:      sd sp, TASK_INFO__USER_SP(tp)
        ld sp, TAST_INFO__KERNEL_SP(tp)
        addi sp, sp, -(PTRACE__SIZE_ON_STACK)
        sd x1,PTRACE__RA(sp)
        sd x3,PTRACE__GP(sp)
        sd x5,PTRACE__T0(sp)
        sd x6,PTRACE__T1(sp)
        sd x7,PTRACE__T2(sp)
        sd x8,PTRACE__S0(sp)
        sd x9,PTRACE__S1(sp)
        sd x10,PTRACE__A0(sp)
        sd x11,PTRACE__A1(sp)
        sd x12,PTRACE__A2(sp)
        sd x13,PTRACE__A3(sp)
        sd x14,PTRACE__A4(sp)
        sd x15,PTRACE__A5(sp)
        sd x16,PTRACE__A6(sp)
        sd x17,PTRACE__A7(sp)
        sd x18,PTRACE__S2(sp)
        sd x19,PTRACE__S3(sp)
        sd x20,PTRACE__S4(sp)
        sd x21,PTRACE__S5(sp)
        sd x22,PTRACE__S6(sp)
        sd x23,PTRACE__S7(sp)
        sd x24,PTRACE__S8(sp)
        sd x25,PTRACE__S9(sp)
        sd x26,PTRACE__S10(sp)
        sd x27,PTRACE__S11(sp)
        sd x28,PTRACE__T3(sp)
        sd x29,PTRACE__T4(sp)
        sd x30,PTRACE__T5(sp)
        sd x31,PTRACE__T6(sp)

        li t0, SR_SUM | SR_FS

        ld s0, TASK_INFO__USER_SP(tp)
        csrrc s1, CSR_STATUS, t0
        csrr s2, CSR_EPC
        csrr s3, CSR_TVAL
        csrr s4, CSR_CAUSE
        csrr s5, CSR_SCRATCH
        sd s0, PTRACE__SP(sp)
        sd s1, PTRACE__STATUS(sp)
        sd s2, PTRACE__EPC(sp)
        sd s3, PTRACE__BADADDR(sp)
        sd s4, PTRACE__CAUSE(sp)
        sd s5, PTRACE__TP(sp)

        csrw CSR_SCRATCH, zero

        la ra, ret_from_exception
        
        bge s4,zero,1f

        mv a0,sp
        tail do_IRQ

1:      andi t0,s1,SR_PIE
        beqz t0,1f

        csrs CSR_STATUS, SR_IE

1:      
        li t0, EXC_SYSCALL
        beq s4,t0, handle_syscall

        slli t0,s4,RISCV_LGPTR
        la t1, excp_vect_table
        la t2, excp_vect_table_end
        mv a0,sp
        add t0,t1,t0

        bgeu t0,t2,1f
        ld t0,0(t0)
        jr t0
1:      
        tail do_trap_unknown

handle_syscall:

        sd a0, PTRACE__ORIG_A0(sp)

        addi s2,s2,0x4
        sd s2, PTRACE__EPC(sp)

        ld t0, TASK_INFO__FLAGS(tp)
        andi t0,t0,_TASK_INFO_FLAG__SYSCALL_WORK
        bnez t0, handle_syscall_trace_enter

check_syscall_nr:

        li t0, __NR_syscalls
        la s0, sys_ni_syscall

        bge a7,t0,1f

        li t1,-1
        beq a7,t1,ret_from_syscall_rejected
        blt a7,t1,1f

        la s0,sys_call_table
        slli t0,a7,RISCV_LGPTR
        add s0,s0,t0
        ld s0,0(s0)
1:
        jalr s0

ret_from_syscall:

        sd a0, PTRACE__A0(sp)

ret_from_syscall_rejected:

        ld t0, TASK_INFO_FLAGS(tp)
        andi t0,t0, _TASK_INFO_FLAG_SYSCALL_WORK
        bnez t0, handle_syscall_trace_exit

ret_from_exception:
        ld s0, PTRACE__STATUS(sp)
        csrc CSR_STATUS, SR_IE
        li t0,SR_MPP
        and s0,s0,t0
        bnez s0, resume_kernel

resume_userspace:

        ld s0, TASK_INFO_FLAGS(tp)
        andi s1,s0, _TASK_INFO_FLAG__WORK_MASK
        bnez s1,work_pending

        addi s0,sp,PTRACE_SIZE_ON_STACK
        sd s0, TASK_INFO_KERNEL_SP(tp)

        csrw CSR_SCRATCH, tp

restore_all:
        ld a0, PTRACE__STATUS(sp)

        csrw CSR_STATUS, a0

        ld x1,PTRACE__RA(sp)
        ld x3,PTRACE__GP(sp)
        ld x5,PTRACE__T0(sp)
        ld x6,PTRACE__T1(sp)
        ld x7,PTRACE__T2(sp)
        ld x8,PTRACE__S0(sp)
        ld x9,PTRACE__S1(sp)
        ld x10,PTRACE__A0(sp)
        ld x11,PTRACE__A1(sp)
        ld x12,PTRACE__A2(sp)
        ld x13,PTRACE__A3(sp)
        ld x14,PTRACE__A4(sp)
        ld x15,PTRACE__A5(sp)
        ld x16,PTRACE__A6(sp)
        ld x17,PTRACE__A7(sp)
        ld x18,PTRACE__S2(sp)
        ld x19,PTRACE__S3(sp)
        ld x20,PTRACE__S4(sp)
        ld x21,PTRACE__S5(sp)
        ld x22,PTRACE__S6(sp)
        ld x23,PTRACE__S7(sp)
        ld x24,PTRACE__S8(sp)
        ld x25,PTRACE__S9(sp)
        ld x26,PTRACE__S10(sp)
        ld x27,PTRACE__S11(sp)
        ld x28,PTRACE__T3(sp)
        ld x29,PTRACE__T4(sp)
        ld x30,PTRACE__T5(sp)
        ld x31,PTRACE__T6(sp)

        ld x2, PTRACE__sp(sp)
        mret

resume_kernel:
        ld s0, TASK_INFO__PREEMPT_COUNT(tp)
        bnez s0, restore_all
        ld s0, TASK_INFO__FLAGS(tp)
        andi s0,s0, _TASK_INFO_FLAGS__NEED_RESCHED
        beqz s0, restore_all
#        call preempt_schedule_irq
        j restore_all

work_pendling:

        la ra,ret_from_exception
        andi s1,s0, _TASK_INFO_FLAG__NEED_RESCHED
        bnez s1, work_resched

work_notifysig:

        csrs CSR_STATUS, SR_IE
        mv a0,sp
        mv a1,s0
        tail do_notify_resume

work_resched:
        tail schedule

handle_syscall_trace_enter:
        mv a0, sp
        call do_syscall_trace_enter
        mv t0,a0
        ld a0,PTRACE__A0(sp)
        ld a1,PTRACE__A1(sp)
        ld a2,PTRACE__A2(sp)
        ld a3,PTRACE__A3(sp)
        ld a4,PTRACE__A4(sp)
        ld a5,PTRACE__A5(sp)
        ld a6,PTRACE__A6(sp)
        ld a7,PTRACE__A7(sp)
        bnez t0, ret_from_syscall_rejected
        j check_syscall_nr

handle_syscall_trace_exit:
        mv a0,sp
        call do_syscall_trace_exit
        j ret_from_exception


ret_from_fork:
        la ra,ret_from_exception
        tail schedule_tail

ret_from_kernel_thread:
        call shedule_tail

        la ra, ret_from_exception
        mv a0,s1
        jr s0

__switch_to:
