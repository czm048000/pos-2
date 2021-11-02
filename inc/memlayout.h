#ifndef POS_INC_MEMLAYOUT_H
#define POS_INC_MEMLAYOUT_H

#ifndef __ASSEMBLER__
#include <inc/types.h>
#include <inc/mmu.h>
#endif /* not __ASSEMBLER__ */


// All physical memory mapped at this address
#define	KERNBASE	0xF0000000

// Kernel stack.
#define KSTACKTOP	KERNBASE
#define KSTKSIZE	(8*PGSIZE)   		// size of a kernel stack

#ifndef __ASSEMBLER__

typedef uint32_t pte_t;
typedef uint32_t pde_t;

#endif /* !__ASSEMBLER__ */

#endif /* !POS_INC_MEMLAYOUT_H */