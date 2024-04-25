/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

// HINT 1 : TRAPHANDLER_NOEC(t_divide, T_DIVIDE);
//          Do something like this if there is no error code for the trap
// HINT 2 : TRAPHANDLER(t_dblflt, T_DBLFLT);
//          Do something like this if the trap includes an error code..
// HINT 3 : READ Intel's manual to check if the trap includes an error code
//          or not...
	TRAPHANDLER_NOEC(entry_div_err, T_DIVIDE);
	TRAPHANDLER_NOEC(entry_deb_exc, T_DEBUG);
	TRAPHANDLER_NOEC(entry_nmi, T_NMI);
	TRAPHANDLER_NOEC(entry_brkpt, T_BRKPT);
	TRAPHANDLER_NOEC(entry_ovflow, T_OFLOW);
	TRAPHANDLER_NOEC(entry_bound, T_BOUND);
	TRAPHANDLER_NOEC(entry_illop, T_ILLOP);
	TRAPHANDLER_NOEC(entry_dev, T_DEVICE);
	TRAPHANDLER(entry_dfault, T_DBLFLT);
	//TRAPHANDLER(entry_copboc, -1); //9
	TRAPHANDLER(entry_tss, T_TSS);
	TRAPHANDLER(entry_segnp, T_SEGNP);
	TRAPHANDLER(entry_stack, T_STACK);
	TRAPHANDLER(entry_gpfault, T_GPFLT);
	TRAPHANDLER(entry_pgfault, T_PGFLT);
	//TRAPHANDLER(entry_res, -1); //15
	TRAPHANDLER_NOEC(entry_fp_err, T_FPERR);
	TRAPHANDLER(entry_align_chk, T_ALIGN);
	TRAPHANDLER_NOEC(entry_mach_chk, T_MCHK);
	TRAPHANDLER_NOEC(entry_simd_fp_err, T_SIMDERR);
	TRAPHANDLER_NOEC(entry_sys_call, T_SYSCALL);
	TRAPHANDLER_NOEC(entry_irq_timer, IRQ_OFFSET+IRQ_TIMER);
	TRAPHANDLER_NOEC(entry_irq_kbd, IRQ_OFFSET+IRQ_KBD);
	TRAPHANDLER_NOEC(entry_irq_serial, IRQ_OFFSET+IRQ_SERIAL);
	TRAPHANDLER_NOEC(entry_irq_spurious, IRQ_OFFSET+IRQ_SPURIOUS);
	TRAPHANDLER_NOEC(entry_irq_ide, IRQ_OFFSET+IRQ_IDE);
	TRAPHANDLER_NOEC(entry_irq_error, IRQ_OFFSET+IRQ_ERROR);

	/*
	#define IRQ_OFFSET	32	// IRQ 0 corresponds to int IRQ_OFFSET

	// Hardware IRQ numbers. We receive these as (IRQ_OFFSET+IRQ_WHATEVER)
	#define IRQ_TIMER        0
	#define IRQ_KBD          1
	#define IRQ_SERIAL       4
	#define IRQ_SPURIOUS     7
	#define IRQ_IDE         14
	#define IRQ_ERROR       19
	*/



/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds;
	pushl %es;
  	pushal;
  	movw $GD_KD, %ax;
  	movw %ax, %ds;
 	movw %ax, %es;
  	pushl %esp;
  	call trap;

