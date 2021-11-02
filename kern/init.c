/* See COPYRIGHT for copyright information. */

#include <inc/stdio.h>
#include <inc/string.h>
// #include <inc/assert.h>

// #include <kern/monitor.h>
#include <kern/console.h>

void
i386_init(void)
{
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();

	cprintf("Hello POS!\n");

	cprintf("    ___    ___     ___   \n");
	cprintf("   | _ \\  / _ \\   / __|  \n");
	cprintf("   |  _/ | (_) |  \\__ \\  \n");
	cprintf("  _|_|_   \\___/   |___/  \n");
	cprintf("_| \"\"\" |_|\"\"\"\"\"|_|\"\"\"\"\"| \n");
	cprintf("\"`-0-0-'\"`-0-0-'\"`-0-0-' \n");

	// cprintf("6828 decimal is %o octal!\n", 6828);

	// Test the stack backtrace function (lab 1 only)
	// test_backtrace(5);

	// Drop into the kernel monitor.
	// while (1)
	// 	monitor(NULL);
}