#ifndef POS_INC_MMU_H
#define POS_INC_MMU_H

#define PTE_P		0x001	// Present
#define PTE_W		0x002	// Writeable

// Page directory and page table constants.
#define NPDENTRIES	1024		// page directory entries per page directory
#define NPTENTRIES	1024		// page table entries per page table

#define PGSIZE		4096		// bytes mapped by a page
#define PGSHIFT		12		// log2(PGSIZE)

#define PTSIZE		(PGSIZE*NPTENTRIES) // bytes mapped by a page directory entry

#define PTXSHIFT	12		// offset of PTX in a linear address
#define PDXSHIFT	22		// offset of PDX in a linear address

// Control Register flags
#define CR0_PE		0x00000001	// Protection Enable
#define CR0_MP		0x00000002	// Monitor coProcessor
#define CR0_WP		0x00010000	// Write Protect
#define CR0_PG		0x80000000	// Paging

// Application segment type bits
#define STA_X		0x8	    // Executable segment
#define STA_W		0x2	    // Writeable (non-executable segments)
#define STA_R		0x2	    // Readable (executable segments)

#ifdef __ASSEMBLER__

/*
 * Macros to build GDT entries in assembly.
 */
#define SEG_NULL						\
	.word 0, 0;						\
	.byte 0, 0, 0, 0
#define SEG(type,base,lim)					\
	.word (((lim) >> 12) & 0xffff), ((base) & 0xffff);	\
	.byte (((base) >> 16) & 0xff), (0x90 | (type)),		\
		(0xC0 | (((lim) >> 28) & 0xf)), (((base) >> 24) & 0xff)

#endif	// not __ASSEMBLER__

#endif /* !POS_INC_MEMLAYOUT_H */