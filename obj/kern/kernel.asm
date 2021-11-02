
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 e0 10 f0       	mov    $0xf010e000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
// #include <kern/monitor.h>
#include <kern/console.h>

void
i386_init(void)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	53                   	push   %ebx
f0100048:	83 ec 08             	sub    $0x8,%esp
f010004b:	e8 8c 00 00 00       	call   f01000dc <__x86.get_pc_thunk.bx>
f0100050:	81 c3 b0 f2 00 00    	add    $0xf2b0,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100056:	c7 c0 80 16 11 f0    	mov    $0xf0111680,%eax
f010005c:	c7 c2 40 10 11 f0    	mov    $0xf0111040,%edx
f0100062:	29 d0                	sub    %edx,%eax
f0100064:	50                   	push   %eax
f0100065:	6a 00                	push   $0x0
f0100067:	52                   	push   %edx
f0100068:	e8 5c 0f 00 00       	call   f0100fc9 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010006d:	e8 c5 04 00 00       	call   f0100537 <cons_init>

	cprintf("Hello POS!\n");
f0100072:	8d 83 40 21 ff ff    	lea    -0xdec0(%ebx),%eax
f0100078:	89 04 24             	mov    %eax,(%esp)
f010007b:	e8 79 06 00 00       	call   f01006f9 <cprintf>

	cprintf("    ___    ___     ___   \n");
f0100080:	8d 83 4c 21 ff ff    	lea    -0xdeb4(%ebx),%eax
f0100086:	89 04 24             	mov    %eax,(%esp)
f0100089:	e8 6b 06 00 00       	call   f01006f9 <cprintf>
	cprintf("   | _ \\  / _ \\   / __|  \n");
f010008e:	8d 83 67 21 ff ff    	lea    -0xde99(%ebx),%eax
f0100094:	89 04 24             	mov    %eax,(%esp)
f0100097:	e8 5d 06 00 00       	call   f01006f9 <cprintf>
	cprintf("   |  _/ | (_) |  \\__ \\  \n");
f010009c:	8d 83 82 21 ff ff    	lea    -0xde7e(%ebx),%eax
f01000a2:	89 04 24             	mov    %eax,(%esp)
f01000a5:	e8 4f 06 00 00       	call   f01006f9 <cprintf>
	cprintf("  _|_|_   \\___/   |___/  \n");
f01000aa:	8d 83 9d 21 ff ff    	lea    -0xde63(%ebx),%eax
f01000b0:	89 04 24             	mov    %eax,(%esp)
f01000b3:	e8 41 06 00 00       	call   f01006f9 <cprintf>
	cprintf("_| \"\"\" |_|\"\"\"\"\"|_|\"\"\"\"\"| \n");
f01000b8:	8d 83 b8 21 ff ff    	lea    -0xde48(%ebx),%eax
f01000be:	89 04 24             	mov    %eax,(%esp)
f01000c1:	e8 33 06 00 00       	call   f01006f9 <cprintf>
	cprintf("\"`-0-0-'\"`-0-0-'\"`-0-0-' \n");
f01000c6:	8d 83 d3 21 ff ff    	lea    -0xde2d(%ebx),%eax
f01000cc:	89 04 24             	mov    %eax,(%esp)
f01000cf:	e8 25 06 00 00       	call   f01006f9 <cprintf>
	// test_backtrace(5);

	// Drop into the kernel monitor.
	// while (1)
	// 	monitor(NULL);
f01000d4:	83 c4 10             	add    $0x10,%esp
f01000d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01000da:	c9                   	leave  
f01000db:	c3                   	ret    

f01000dc <__x86.get_pc_thunk.bx>:
f01000dc:	8b 1c 24             	mov    (%esp),%ebx
f01000df:	c3                   	ret    

f01000e0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01000e0:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01000e4:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01000e9:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01000ea:	a8 01                	test   $0x1,%al
f01000ec:	74 0a                	je     f01000f8 <serial_proc_data+0x18>
f01000ee:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01000f3:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01000f4:	0f b6 c0             	movzbl %al,%eax
f01000f7:	c3                   	ret    
		return -1;
f01000f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01000fd:	c3                   	ret    

f01000fe <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01000fe:	55                   	push   %ebp
f01000ff:	89 e5                	mov    %esp,%ebp
f0100101:	57                   	push   %edi
f0100102:	56                   	push   %esi
f0100103:	53                   	push   %ebx
f0100104:	83 ec 1c             	sub    $0x1c,%esp
f0100107:	e8 88 05 00 00       	call   f0100694 <__x86.get_pc_thunk.si>
f010010c:	81 c6 f4 f1 00 00    	add    $0xf1f4,%esi
f0100112:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100114:	8d 1d 60 1d 00 00    	lea    0x1d60,%ebx
f010011a:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f010011d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100120:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f0100123:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100126:	ff d0                	call   *%eax
f0100128:	83 f8 ff             	cmp    $0xffffffff,%eax
f010012b:	74 2b                	je     f0100158 <cons_intr+0x5a>
		if (c == 0)
f010012d:	85 c0                	test   %eax,%eax
f010012f:	74 f2                	je     f0100123 <cons_intr+0x25>
		cons.buf[cons.wpos++] = c;
f0100131:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f0100138:	8d 51 01             	lea    0x1(%ecx),%edx
f010013b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010013e:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100141:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100147:	b8 00 00 00 00       	mov    $0x0,%eax
f010014c:	0f 44 d0             	cmove  %eax,%edx
f010014f:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
f0100156:	eb cb                	jmp    f0100123 <cons_intr+0x25>
	}
}
f0100158:	83 c4 1c             	add    $0x1c,%esp
f010015b:	5b                   	pop    %ebx
f010015c:	5e                   	pop    %esi
f010015d:	5f                   	pop    %edi
f010015e:	5d                   	pop    %ebp
f010015f:	c3                   	ret    

f0100160 <kbd_proc_data>:
{
f0100160:	f3 0f 1e fb          	endbr32 
f0100164:	55                   	push   %ebp
f0100165:	89 e5                	mov    %esp,%ebp
f0100167:	56                   	push   %esi
f0100168:	53                   	push   %ebx
f0100169:	e8 6e ff ff ff       	call   f01000dc <__x86.get_pc_thunk.bx>
f010016e:	81 c3 92 f1 00 00    	add    $0xf192,%ebx
f0100174:	ba 64 00 00 00       	mov    $0x64,%edx
f0100179:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f010017a:	a8 01                	test   $0x1,%al
f010017c:	0f 84 fb 00 00 00    	je     f010027d <kbd_proc_data+0x11d>
	if (stat & KBS_TERR)
f0100182:	a8 20                	test   $0x20,%al
f0100184:	0f 85 fa 00 00 00    	jne    f0100284 <kbd_proc_data+0x124>
f010018a:	ba 60 00 00 00       	mov    $0x60,%edx
f010018f:	ec                   	in     (%dx),%al
f0100190:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100192:	3c e0                	cmp    $0xe0,%al
f0100194:	74 64                	je     f01001fa <kbd_proc_data+0x9a>
	} else if (data & 0x80) {
f0100196:	84 c0                	test   %al,%al
f0100198:	78 75                	js     f010020f <kbd_proc_data+0xaf>
	} else if (shift & E0ESC) {
f010019a:	8b 8b 40 1d 00 00    	mov    0x1d40(%ebx),%ecx
f01001a0:	f6 c1 40             	test   $0x40,%cl
f01001a3:	74 0e                	je     f01001b3 <kbd_proc_data+0x53>
		data |= 0x80;
f01001a5:	83 c8 80             	or     $0xffffff80,%eax
f01001a8:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001aa:	83 e1 bf             	and    $0xffffffbf,%ecx
f01001ad:	89 8b 40 1d 00 00    	mov    %ecx,0x1d40(%ebx)
	shift |= shiftcode[data];
f01001b3:	0f b6 d2             	movzbl %dl,%edx
f01001b6:	0f b6 84 13 20 23 ff 	movzbl -0xdce0(%ebx,%edx,1),%eax
f01001bd:	ff 
f01001be:	0b 83 40 1d 00 00    	or     0x1d40(%ebx),%eax
	shift ^= togglecode[data];
f01001c4:	0f b6 8c 13 20 22 ff 	movzbl -0xdde0(%ebx,%edx,1),%ecx
f01001cb:	ff 
f01001cc:	31 c8                	xor    %ecx,%eax
f01001ce:	89 83 40 1d 00 00    	mov    %eax,0x1d40(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01001d4:	89 c1                	mov    %eax,%ecx
f01001d6:	83 e1 03             	and    $0x3,%ecx
f01001d9:	8b 8c 8b 00 1d 00 00 	mov    0x1d00(%ebx,%ecx,4),%ecx
f01001e0:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01001e4:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01001e7:	a8 08                	test   $0x8,%al
f01001e9:	74 65                	je     f0100250 <kbd_proc_data+0xf0>
		if ('a' <= c && c <= 'z')
f01001eb:	89 f2                	mov    %esi,%edx
f01001ed:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01001f0:	83 f9 19             	cmp    $0x19,%ecx
f01001f3:	77 4f                	ja     f0100244 <kbd_proc_data+0xe4>
			c += 'A' - 'a';
f01001f5:	83 ee 20             	sub    $0x20,%esi
f01001f8:	eb 0c                	jmp    f0100206 <kbd_proc_data+0xa6>
		shift |= E0ESC;
f01001fa:	83 8b 40 1d 00 00 40 	orl    $0x40,0x1d40(%ebx)
		return 0;
f0100201:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100206:	89 f0                	mov    %esi,%eax
f0100208:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010020b:	5b                   	pop    %ebx
f010020c:	5e                   	pop    %esi
f010020d:	5d                   	pop    %ebp
f010020e:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010020f:	8b 8b 40 1d 00 00    	mov    0x1d40(%ebx),%ecx
f0100215:	89 ce                	mov    %ecx,%esi
f0100217:	83 e6 40             	and    $0x40,%esi
f010021a:	83 e0 7f             	and    $0x7f,%eax
f010021d:	85 f6                	test   %esi,%esi
f010021f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100222:	0f b6 d2             	movzbl %dl,%edx
f0100225:	0f b6 84 13 20 23 ff 	movzbl -0xdce0(%ebx,%edx,1),%eax
f010022c:	ff 
f010022d:	83 c8 40             	or     $0x40,%eax
f0100230:	0f b6 c0             	movzbl %al,%eax
f0100233:	f7 d0                	not    %eax
f0100235:	21 c8                	and    %ecx,%eax
f0100237:	89 83 40 1d 00 00    	mov    %eax,0x1d40(%ebx)
		return 0;
f010023d:	be 00 00 00 00       	mov    $0x0,%esi
f0100242:	eb c2                	jmp    f0100206 <kbd_proc_data+0xa6>
		else if ('A' <= c && c <= 'Z')
f0100244:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100247:	8d 4e 20             	lea    0x20(%esi),%ecx
f010024a:	83 fa 1a             	cmp    $0x1a,%edx
f010024d:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100250:	f7 d0                	not    %eax
f0100252:	a8 06                	test   $0x6,%al
f0100254:	75 b0                	jne    f0100206 <kbd_proc_data+0xa6>
f0100256:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010025c:	75 a8                	jne    f0100206 <kbd_proc_data+0xa6>
		cprintf("Rebooting!\n");
f010025e:	83 ec 0c             	sub    $0xc,%esp
f0100261:	8d 83 ee 21 ff ff    	lea    -0xde12(%ebx),%eax
f0100267:	50                   	push   %eax
f0100268:	e8 8c 04 00 00       	call   f01006f9 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010026d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100272:	ba 92 00 00 00       	mov    $0x92,%edx
f0100277:	ee                   	out    %al,(%dx)
}
f0100278:	83 c4 10             	add    $0x10,%esp
f010027b:	eb 89                	jmp    f0100206 <kbd_proc_data+0xa6>
		return -1;
f010027d:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100282:	eb 82                	jmp    f0100206 <kbd_proc_data+0xa6>
		return -1;
f0100284:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100289:	e9 78 ff ff ff       	jmp    f0100206 <kbd_proc_data+0xa6>

f010028e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010028e:	55                   	push   %ebp
f010028f:	89 e5                	mov    %esp,%ebp
f0100291:	57                   	push   %edi
f0100292:	56                   	push   %esi
f0100293:	53                   	push   %ebx
f0100294:	83 ec 1c             	sub    $0x1c,%esp
f0100297:	e8 40 fe ff ff       	call   f01000dc <__x86.get_pc_thunk.bx>
f010029c:	81 c3 64 f0 00 00    	add    $0xf064,%ebx
f01002a2:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01002a4:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002a9:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002ae:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002b3:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002b4:	a8 20                	test   $0x20,%al
f01002b6:	75 13                	jne    f01002cb <cons_putc+0x3d>
f01002b8:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01002be:	7f 0b                	jg     f01002cb <cons_putc+0x3d>
f01002c0:	89 ca                	mov    %ecx,%edx
f01002c2:	ec                   	in     (%dx),%al
f01002c3:	ec                   	in     (%dx),%al
f01002c4:	ec                   	in     (%dx),%al
f01002c5:	ec                   	in     (%dx),%al
	     i++)
f01002c6:	83 c6 01             	add    $0x1,%esi
f01002c9:	eb e3                	jmp    f01002ae <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f01002cb:	89 f8                	mov    %edi,%eax
f01002cd:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002d5:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002d6:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002db:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002e0:	ba 79 03 00 00       	mov    $0x379,%edx
f01002e5:	ec                   	in     (%dx),%al
f01002e6:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01002ec:	7f 0f                	jg     f01002fd <cons_putc+0x6f>
f01002ee:	84 c0                	test   %al,%al
f01002f0:	78 0b                	js     f01002fd <cons_putc+0x6f>
f01002f2:	89 ca                	mov    %ecx,%edx
f01002f4:	ec                   	in     (%dx),%al
f01002f5:	ec                   	in     (%dx),%al
f01002f6:	ec                   	in     (%dx),%al
f01002f7:	ec                   	in     (%dx),%al
f01002f8:	83 c6 01             	add    $0x1,%esi
f01002fb:	eb e3                	jmp    f01002e0 <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002fd:	ba 78 03 00 00       	mov    $0x378,%edx
f0100302:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100306:	ee                   	out    %al,(%dx)
f0100307:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010030c:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100311:	ee                   	out    %al,(%dx)
f0100312:	b8 08 00 00 00       	mov    $0x8,%eax
f0100317:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f0100318:	89 f8                	mov    %edi,%eax
f010031a:	80 cc 07             	or     $0x7,%ah
f010031d:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100323:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100326:	89 f8                	mov    %edi,%eax
f0100328:	0f b6 c0             	movzbl %al,%eax
f010032b:	89 f9                	mov    %edi,%ecx
f010032d:	80 f9 0a             	cmp    $0xa,%cl
f0100330:	0f 84 e2 00 00 00    	je     f0100418 <cons_putc+0x18a>
f0100336:	83 f8 0a             	cmp    $0xa,%eax
f0100339:	7f 46                	jg     f0100381 <cons_putc+0xf3>
f010033b:	83 f8 08             	cmp    $0x8,%eax
f010033e:	0f 84 a8 00 00 00    	je     f01003ec <cons_putc+0x15e>
f0100344:	83 f8 09             	cmp    $0x9,%eax
f0100347:	0f 85 d8 00 00 00    	jne    f0100425 <cons_putc+0x197>
		cons_putc(' ');
f010034d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100352:	e8 37 ff ff ff       	call   f010028e <cons_putc>
		cons_putc(' ');
f0100357:	b8 20 00 00 00       	mov    $0x20,%eax
f010035c:	e8 2d ff ff ff       	call   f010028e <cons_putc>
		cons_putc(' ');
f0100361:	b8 20 00 00 00       	mov    $0x20,%eax
f0100366:	e8 23 ff ff ff       	call   f010028e <cons_putc>
		cons_putc(' ');
f010036b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100370:	e8 19 ff ff ff       	call   f010028e <cons_putc>
		cons_putc(' ');
f0100375:	b8 20 00 00 00       	mov    $0x20,%eax
f010037a:	e8 0f ff ff ff       	call   f010028e <cons_putc>
		break;
f010037f:	eb 26                	jmp    f01003a7 <cons_putc+0x119>
	switch (c & 0xff) {
f0100381:	83 f8 0d             	cmp    $0xd,%eax
f0100384:	0f 85 9b 00 00 00    	jne    f0100425 <cons_putc+0x197>
		crt_pos -= (crt_pos % CRT_COLS);
f010038a:	0f b7 83 68 1f 00 00 	movzwl 0x1f68(%ebx),%eax
f0100391:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100397:	c1 e8 16             	shr    $0x16,%eax
f010039a:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010039d:	c1 e0 04             	shl    $0x4,%eax
f01003a0:	66 89 83 68 1f 00 00 	mov    %ax,0x1f68(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01003a7:	66 81 bb 68 1f 00 00 	cmpw   $0x7cf,0x1f68(%ebx)
f01003ae:	cf 07 
f01003b0:	0f 87 92 00 00 00    	ja     f0100448 <cons_putc+0x1ba>
	outb(addr_6845, 14);
f01003b6:	8b 8b 70 1f 00 00    	mov    0x1f70(%ebx),%ecx
f01003bc:	b8 0e 00 00 00       	mov    $0xe,%eax
f01003c1:	89 ca                	mov    %ecx,%edx
f01003c3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003c4:	0f b7 9b 68 1f 00 00 	movzwl 0x1f68(%ebx),%ebx
f01003cb:	8d 71 01             	lea    0x1(%ecx),%esi
f01003ce:	89 d8                	mov    %ebx,%eax
f01003d0:	66 c1 e8 08          	shr    $0x8,%ax
f01003d4:	89 f2                	mov    %esi,%edx
f01003d6:	ee                   	out    %al,(%dx)
f01003d7:	b8 0f 00 00 00       	mov    $0xf,%eax
f01003dc:	89 ca                	mov    %ecx,%edx
f01003de:	ee                   	out    %al,(%dx)
f01003df:	89 d8                	mov    %ebx,%eax
f01003e1:	89 f2                	mov    %esi,%edx
f01003e3:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01003e7:	5b                   	pop    %ebx
f01003e8:	5e                   	pop    %esi
f01003e9:	5f                   	pop    %edi
f01003ea:	5d                   	pop    %ebp
f01003eb:	c3                   	ret    
		if (crt_pos > 0) {
f01003ec:	0f b7 83 68 1f 00 00 	movzwl 0x1f68(%ebx),%eax
f01003f3:	66 85 c0             	test   %ax,%ax
f01003f6:	74 be                	je     f01003b6 <cons_putc+0x128>
			crt_pos--;
f01003f8:	83 e8 01             	sub    $0x1,%eax
f01003fb:	66 89 83 68 1f 00 00 	mov    %ax,0x1f68(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100402:	0f b7 c0             	movzwl %ax,%eax
f0100405:	89 fa                	mov    %edi,%edx
f0100407:	b2 00                	mov    $0x0,%dl
f0100409:	83 ca 20             	or     $0x20,%edx
f010040c:	8b 8b 6c 1f 00 00    	mov    0x1f6c(%ebx),%ecx
f0100412:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f0100416:	eb 8f                	jmp    f01003a7 <cons_putc+0x119>
		crt_pos += CRT_COLS;
f0100418:	66 83 83 68 1f 00 00 	addw   $0x50,0x1f68(%ebx)
f010041f:	50 
f0100420:	e9 65 ff ff ff       	jmp    f010038a <cons_putc+0xfc>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100425:	0f b7 83 68 1f 00 00 	movzwl 0x1f68(%ebx),%eax
f010042c:	8d 50 01             	lea    0x1(%eax),%edx
f010042f:	66 89 93 68 1f 00 00 	mov    %dx,0x1f68(%ebx)
f0100436:	0f b7 c0             	movzwl %ax,%eax
f0100439:	8b 93 6c 1f 00 00    	mov    0x1f6c(%ebx),%edx
f010043f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100443:	e9 5f ff ff ff       	jmp    f01003a7 <cons_putc+0x119>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100448:	8b 83 6c 1f 00 00    	mov    0x1f6c(%ebx),%eax
f010044e:	83 ec 04             	sub    $0x4,%esp
f0100451:	68 00 0f 00 00       	push   $0xf00
f0100456:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010045c:	52                   	push   %edx
f010045d:	50                   	push   %eax
f010045e:	e8 b2 0b 00 00       	call   f0101015 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100463:	8b 93 6c 1f 00 00    	mov    0x1f6c(%ebx),%edx
f0100469:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010046f:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100475:	83 c4 10             	add    $0x10,%esp
f0100478:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010047d:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100480:	39 d0                	cmp    %edx,%eax
f0100482:	75 f4                	jne    f0100478 <cons_putc+0x1ea>
		crt_pos -= CRT_COLS;
f0100484:	66 83 ab 68 1f 00 00 	subw   $0x50,0x1f68(%ebx)
f010048b:	50 
f010048c:	e9 25 ff ff ff       	jmp    f01003b6 <cons_putc+0x128>

f0100491 <serial_intr>:
{
f0100491:	f3 0f 1e fb          	endbr32 
f0100495:	e8 f6 01 00 00       	call   f0100690 <__x86.get_pc_thunk.ax>
f010049a:	05 66 ee 00 00       	add    $0xee66,%eax
	if (serial_exists)
f010049f:	80 b8 74 1f 00 00 00 	cmpb   $0x0,0x1f74(%eax)
f01004a6:	75 01                	jne    f01004a9 <serial_intr+0x18>
f01004a8:	c3                   	ret    
{
f01004a9:	55                   	push   %ebp
f01004aa:	89 e5                	mov    %esp,%ebp
f01004ac:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01004af:	8d 80 e0 0d ff ff    	lea    -0xf220(%eax),%eax
f01004b5:	e8 44 fc ff ff       	call   f01000fe <cons_intr>
}
f01004ba:	c9                   	leave  
f01004bb:	c3                   	ret    

f01004bc <kbd_intr>:
{
f01004bc:	f3 0f 1e fb          	endbr32 
f01004c0:	55                   	push   %ebp
f01004c1:	89 e5                	mov    %esp,%ebp
f01004c3:	83 ec 08             	sub    $0x8,%esp
f01004c6:	e8 c5 01 00 00       	call   f0100690 <__x86.get_pc_thunk.ax>
f01004cb:	05 35 ee 00 00       	add    $0xee35,%eax
	cons_intr(kbd_proc_data);
f01004d0:	8d 80 60 0e ff ff    	lea    -0xf1a0(%eax),%eax
f01004d6:	e8 23 fc ff ff       	call   f01000fe <cons_intr>
}
f01004db:	c9                   	leave  
f01004dc:	c3                   	ret    

f01004dd <cons_getc>:
{
f01004dd:	f3 0f 1e fb          	endbr32 
f01004e1:	55                   	push   %ebp
f01004e2:	89 e5                	mov    %esp,%ebp
f01004e4:	53                   	push   %ebx
f01004e5:	83 ec 04             	sub    $0x4,%esp
f01004e8:	e8 ef fb ff ff       	call   f01000dc <__x86.get_pc_thunk.bx>
f01004ed:	81 c3 13 ee 00 00    	add    $0xee13,%ebx
	serial_intr();
f01004f3:	e8 99 ff ff ff       	call   f0100491 <serial_intr>
	kbd_intr();
f01004f8:	e8 bf ff ff ff       	call   f01004bc <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01004fd:	8b 83 60 1f 00 00    	mov    0x1f60(%ebx),%eax
	return 0;
f0100503:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f0100508:	3b 83 64 1f 00 00    	cmp    0x1f64(%ebx),%eax
f010050e:	74 1f                	je     f010052f <cons_getc+0x52>
		c = cons.buf[cons.rpos++];
f0100510:	8d 48 01             	lea    0x1(%eax),%ecx
f0100513:	0f b6 94 03 60 1d 00 	movzbl 0x1d60(%ebx,%eax,1),%edx
f010051a:	00 
			cons.rpos = 0;
f010051b:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100521:	b8 00 00 00 00       	mov    $0x0,%eax
f0100526:	0f 44 c8             	cmove  %eax,%ecx
f0100529:	89 8b 60 1f 00 00    	mov    %ecx,0x1f60(%ebx)
}
f010052f:	89 d0                	mov    %edx,%eax
f0100531:	83 c4 04             	add    $0x4,%esp
f0100534:	5b                   	pop    %ebx
f0100535:	5d                   	pop    %ebp
f0100536:	c3                   	ret    

f0100537 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100537:	f3 0f 1e fb          	endbr32 
f010053b:	55                   	push   %ebp
f010053c:	89 e5                	mov    %esp,%ebp
f010053e:	57                   	push   %edi
f010053f:	56                   	push   %esi
f0100540:	53                   	push   %ebx
f0100541:	83 ec 1c             	sub    $0x1c,%esp
f0100544:	e8 93 fb ff ff       	call   f01000dc <__x86.get_pc_thunk.bx>
f0100549:	81 c3 b7 ed 00 00    	add    $0xedb7,%ebx
	was = *cp;
f010054f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100556:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010055d:	5a a5 
	if (*cp != 0xA55A) {
f010055f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100566:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010056a:	0f 84 bc 00 00 00    	je     f010062c <cons_init+0xf5>
		addr_6845 = MONO_BASE;
f0100570:	c7 83 70 1f 00 00 b4 	movl   $0x3b4,0x1f70(%ebx)
f0100577:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010057a:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100581:	8b bb 70 1f 00 00    	mov    0x1f70(%ebx),%edi
f0100587:	b8 0e 00 00 00       	mov    $0xe,%eax
f010058c:	89 fa                	mov    %edi,%edx
f010058e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010058f:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100592:	89 ca                	mov    %ecx,%edx
f0100594:	ec                   	in     (%dx),%al
f0100595:	0f b6 f0             	movzbl %al,%esi
f0100598:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010059b:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005a0:	89 fa                	mov    %edi,%edx
f01005a2:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a3:	89 ca                	mov    %ecx,%edx
f01005a5:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01005a9:	89 bb 6c 1f 00 00    	mov    %edi,0x1f6c(%ebx)
	pos |= inb(addr_6845 + 1);
f01005af:	0f b6 c0             	movzbl %al,%eax
f01005b2:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f01005b4:	66 89 b3 68 1f 00 00 	mov    %si,0x1f68(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005bb:	b9 00 00 00 00       	mov    $0x0,%ecx
f01005c0:	89 c8                	mov    %ecx,%eax
f01005c2:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01005c7:	ee                   	out    %al,(%dx)
f01005c8:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01005cd:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005d2:	89 fa                	mov    %edi,%edx
f01005d4:	ee                   	out    %al,(%dx)
f01005d5:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005da:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005df:	ee                   	out    %al,(%dx)
f01005e0:	be f9 03 00 00       	mov    $0x3f9,%esi
f01005e5:	89 c8                	mov    %ecx,%eax
f01005e7:	89 f2                	mov    %esi,%edx
f01005e9:	ee                   	out    %al,(%dx)
f01005ea:	b8 03 00 00 00       	mov    $0x3,%eax
f01005ef:	89 fa                	mov    %edi,%edx
f01005f1:	ee                   	out    %al,(%dx)
f01005f2:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005f7:	89 c8                	mov    %ecx,%eax
f01005f9:	ee                   	out    %al,(%dx)
f01005fa:	b8 01 00 00 00       	mov    $0x1,%eax
f01005ff:	89 f2                	mov    %esi,%edx
f0100601:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100602:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100607:	ec                   	in     (%dx),%al
f0100608:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010060a:	3c ff                	cmp    $0xff,%al
f010060c:	0f 95 83 74 1f 00 00 	setne  0x1f74(%ebx)
f0100613:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100618:	ec                   	in     (%dx),%al
f0100619:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010061e:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010061f:	80 f9 ff             	cmp    $0xff,%cl
f0100622:	74 25                	je     f0100649 <cons_init+0x112>
		cprintf("Serial port does not exist!\n");
}
f0100624:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100627:	5b                   	pop    %ebx
f0100628:	5e                   	pop    %esi
f0100629:	5f                   	pop    %edi
f010062a:	5d                   	pop    %ebp
f010062b:	c3                   	ret    
		*cp = was;
f010062c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100633:	c7 83 70 1f 00 00 d4 	movl   $0x3d4,0x1f70(%ebx)
f010063a:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010063d:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100644:	e9 38 ff ff ff       	jmp    f0100581 <cons_init+0x4a>
		cprintf("Serial port does not exist!\n");
f0100649:	83 ec 0c             	sub    $0xc,%esp
f010064c:	8d 83 fa 21 ff ff    	lea    -0xde06(%ebx),%eax
f0100652:	50                   	push   %eax
f0100653:	e8 a1 00 00 00       	call   f01006f9 <cprintf>
f0100658:	83 c4 10             	add    $0x10,%esp
}
f010065b:	eb c7                	jmp    f0100624 <cons_init+0xed>

f010065d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010065d:	f3 0f 1e fb          	endbr32 
f0100661:	55                   	push   %ebp
f0100662:	89 e5                	mov    %esp,%ebp
f0100664:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100667:	8b 45 08             	mov    0x8(%ebp),%eax
f010066a:	e8 1f fc ff ff       	call   f010028e <cons_putc>
}
f010066f:	c9                   	leave  
f0100670:	c3                   	ret    

f0100671 <getchar>:

int
getchar(void)
{
f0100671:	f3 0f 1e fb          	endbr32 
f0100675:	55                   	push   %ebp
f0100676:	89 e5                	mov    %esp,%ebp
f0100678:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010067b:	e8 5d fe ff ff       	call   f01004dd <cons_getc>
f0100680:	85 c0                	test   %eax,%eax
f0100682:	74 f7                	je     f010067b <getchar+0xa>
		/* do nothing */;
	return c;
}
f0100684:	c9                   	leave  
f0100685:	c3                   	ret    

f0100686 <iscons>:

int
iscons(int fdnum)
{
f0100686:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f010068a:	b8 01 00 00 00       	mov    $0x1,%eax
f010068f:	c3                   	ret    

f0100690 <__x86.get_pc_thunk.ax>:
f0100690:	8b 04 24             	mov    (%esp),%eax
f0100693:	c3                   	ret    

f0100694 <__x86.get_pc_thunk.si>:
f0100694:	8b 34 24             	mov    (%esp),%esi
f0100697:	c3                   	ret    

f0100698 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100698:	f3 0f 1e fb          	endbr32 
f010069c:	55                   	push   %ebp
f010069d:	89 e5                	mov    %esp,%ebp
f010069f:	53                   	push   %ebx
f01006a0:	83 ec 10             	sub    $0x10,%esp
f01006a3:	e8 34 fa ff ff       	call   f01000dc <__x86.get_pc_thunk.bx>
f01006a8:	81 c3 58 ec 00 00    	add    $0xec58,%ebx
	cputchar(ch);
f01006ae:	ff 75 08             	pushl  0x8(%ebp)
f01006b1:	e8 a7 ff ff ff       	call   f010065d <cputchar>
	*cnt++;
}
f01006b6:	83 c4 10             	add    $0x10,%esp
f01006b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01006bc:	c9                   	leave  
f01006bd:	c3                   	ret    

f01006be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01006be:	f3 0f 1e fb          	endbr32 
f01006c2:	55                   	push   %ebp
f01006c3:	89 e5                	mov    %esp,%ebp
f01006c5:	53                   	push   %ebx
f01006c6:	83 ec 14             	sub    $0x14,%esp
f01006c9:	e8 0e fa ff ff       	call   f01000dc <__x86.get_pc_thunk.bx>
f01006ce:	81 c3 32 ec 00 00    	add    $0xec32,%ebx
	int cnt = 0;
f01006d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01006db:	ff 75 0c             	pushl  0xc(%ebp)
f01006de:	ff 75 08             	pushl  0x8(%ebp)
f01006e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01006e4:	50                   	push   %eax
f01006e5:	8d 83 98 13 ff ff    	lea    -0xec68(%ebx),%eax
f01006eb:	50                   	push   %eax
f01006ec:	e8 20 01 00 00       	call   f0100811 <vprintfmt>
	return cnt;
}
f01006f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01006f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01006f7:	c9                   	leave  
f01006f8:	c3                   	ret    

f01006f9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01006f9:	f3 0f 1e fb          	endbr32 
f01006fd:	55                   	push   %ebp
f01006fe:	89 e5                	mov    %esp,%ebp
f0100700:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100703:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100706:	50                   	push   %eax
f0100707:	ff 75 08             	pushl  0x8(%ebp)
f010070a:	e8 af ff ff ff       	call   f01006be <vcprintf>
	va_end(ap);

	return cnt;
}
f010070f:	c9                   	leave  
f0100710:	c3                   	ret    

f0100711 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100711:	55                   	push   %ebp
f0100712:	89 e5                	mov    %esp,%ebp
f0100714:	57                   	push   %edi
f0100715:	56                   	push   %esi
f0100716:	53                   	push   %ebx
f0100717:	83 ec 2c             	sub    $0x2c,%esp
f010071a:	e8 f0 05 00 00       	call   f0100d0f <__x86.get_pc_thunk.cx>
f010071f:	81 c1 e1 eb 00 00    	add    $0xebe1,%ecx
f0100725:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100728:	89 c7                	mov    %eax,%edi
f010072a:	89 d6                	mov    %edx,%esi
f010072c:	8b 45 08             	mov    0x8(%ebp),%eax
f010072f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100732:	89 d1                	mov    %edx,%ecx
f0100734:	89 c2                	mov    %eax,%edx
f0100736:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100739:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f010073c:	8b 45 10             	mov    0x10(%ebp),%eax
f010073f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100742:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100745:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010074c:	39 c2                	cmp    %eax,%edx
f010074e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100751:	72 41                	jb     f0100794 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100753:	83 ec 0c             	sub    $0xc,%esp
f0100756:	ff 75 18             	pushl  0x18(%ebp)
f0100759:	83 eb 01             	sub    $0x1,%ebx
f010075c:	53                   	push   %ebx
f010075d:	50                   	push   %eax
f010075e:	83 ec 08             	sub    $0x8,%esp
f0100761:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100764:	ff 75 e0             	pushl  -0x20(%ebp)
f0100767:	ff 75 d4             	pushl  -0x2c(%ebp)
f010076a:	ff 75 d0             	pushl  -0x30(%ebp)
f010076d:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100770:	e8 6b 0a 00 00       	call   f01011e0 <__udivdi3>
f0100775:	83 c4 18             	add    $0x18,%esp
f0100778:	52                   	push   %edx
f0100779:	50                   	push   %eax
f010077a:	89 f2                	mov    %esi,%edx
f010077c:	89 f8                	mov    %edi,%eax
f010077e:	e8 8e ff ff ff       	call   f0100711 <printnum>
f0100783:	83 c4 20             	add    $0x20,%esp
f0100786:	eb 13                	jmp    f010079b <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100788:	83 ec 08             	sub    $0x8,%esp
f010078b:	56                   	push   %esi
f010078c:	ff 75 18             	pushl  0x18(%ebp)
f010078f:	ff d7                	call   *%edi
f0100791:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100794:	83 eb 01             	sub    $0x1,%ebx
f0100797:	85 db                	test   %ebx,%ebx
f0100799:	7f ed                	jg     f0100788 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010079b:	83 ec 08             	sub    $0x8,%esp
f010079e:	56                   	push   %esi
f010079f:	83 ec 04             	sub    $0x4,%esp
f01007a2:	ff 75 e4             	pushl  -0x1c(%ebp)
f01007a5:	ff 75 e0             	pushl  -0x20(%ebp)
f01007a8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007ab:	ff 75 d0             	pushl  -0x30(%ebp)
f01007ae:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01007b1:	e8 3a 0b 00 00       	call   f01012f0 <__umoddi3>
f01007b6:	83 c4 14             	add    $0x14,%esp
f01007b9:	0f be 84 03 20 24 ff 	movsbl -0xdbe0(%ebx,%eax,1),%eax
f01007c0:	ff 
f01007c1:	50                   	push   %eax
f01007c2:	ff d7                	call   *%edi
}
f01007c4:	83 c4 10             	add    $0x10,%esp
f01007c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007ca:	5b                   	pop    %ebx
f01007cb:	5e                   	pop    %esi
f01007cc:	5f                   	pop    %edi
f01007cd:	5d                   	pop    %ebp
f01007ce:	c3                   	ret    

f01007cf <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01007cf:	f3 0f 1e fb          	endbr32 
f01007d3:	55                   	push   %ebp
f01007d4:	89 e5                	mov    %esp,%ebp
f01007d6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01007d9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01007dd:	8b 10                	mov    (%eax),%edx
f01007df:	3b 50 04             	cmp    0x4(%eax),%edx
f01007e2:	73 0a                	jae    f01007ee <sprintputch+0x1f>
		*b->buf++ = ch;
f01007e4:	8d 4a 01             	lea    0x1(%edx),%ecx
f01007e7:	89 08                	mov    %ecx,(%eax)
f01007e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01007ec:	88 02                	mov    %al,(%edx)
}
f01007ee:	5d                   	pop    %ebp
f01007ef:	c3                   	ret    

f01007f0 <printfmt>:
{
f01007f0:	f3 0f 1e fb          	endbr32 
f01007f4:	55                   	push   %ebp
f01007f5:	89 e5                	mov    %esp,%ebp
f01007f7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01007fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01007fd:	50                   	push   %eax
f01007fe:	ff 75 10             	pushl  0x10(%ebp)
f0100801:	ff 75 0c             	pushl  0xc(%ebp)
f0100804:	ff 75 08             	pushl  0x8(%ebp)
f0100807:	e8 05 00 00 00       	call   f0100811 <vprintfmt>
}
f010080c:	83 c4 10             	add    $0x10,%esp
f010080f:	c9                   	leave  
f0100810:	c3                   	ret    

f0100811 <vprintfmt>:
{
f0100811:	f3 0f 1e fb          	endbr32 
f0100815:	55                   	push   %ebp
f0100816:	89 e5                	mov    %esp,%ebp
f0100818:	57                   	push   %edi
f0100819:	56                   	push   %esi
f010081a:	53                   	push   %ebx
f010081b:	83 ec 3c             	sub    $0x3c,%esp
f010081e:	e8 6d fe ff ff       	call   f0100690 <__x86.get_pc_thunk.ax>
f0100823:	05 dd ea 00 00       	add    $0xeadd,%eax
f0100828:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010082b:	8b 75 08             	mov    0x8(%ebp),%esi
f010082e:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0100831:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100834:	8d 80 10 1d 00 00    	lea    0x1d10(%eax),%eax
f010083a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010083d:	e9 95 03 00 00       	jmp    f0100bd7 <.L25+0x48>
		padc = ' ';
f0100842:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f0100846:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f010084d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0100854:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
f010085b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100860:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0100863:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100866:	8d 43 01             	lea    0x1(%ebx),%eax
f0100869:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010086c:	0f b6 13             	movzbl (%ebx),%edx
f010086f:	8d 42 dd             	lea    -0x23(%edx),%eax
f0100872:	3c 55                	cmp    $0x55,%al
f0100874:	0f 87 e9 03 00 00    	ja     f0100c63 <.L20>
f010087a:	0f b6 c0             	movzbl %al,%eax
f010087d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100880:	89 ce                	mov    %ecx,%esi
f0100882:	03 b4 81 b0 24 ff ff 	add    -0xdb50(%ecx,%eax,4),%esi
f0100889:	3e ff e6             	notrack jmp *%esi

f010088c <.L66>:
f010088c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f010088f:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f0100893:	eb d1                	jmp    f0100866 <vprintfmt+0x55>

f0100895 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0100895:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100898:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f010089c:	eb c8                	jmp    f0100866 <vprintfmt+0x55>

f010089e <.L31>:
f010089e:	0f b6 d2             	movzbl %dl,%edx
f01008a1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f01008a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01008a9:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f01008ac:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01008af:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01008b3:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01008b6:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01008b9:	83 f9 09             	cmp    $0x9,%ecx
f01008bc:	77 58                	ja     f0100916 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f01008be:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01008c1:	eb e9                	jmp    f01008ac <.L31+0xe>

f01008c3 <.L34>:
			precision = va_arg(ap, int);
f01008c3:	8b 45 14             	mov    0x14(%ebp),%eax
f01008c6:	8b 00                	mov    (%eax),%eax
f01008c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01008cb:	8b 45 14             	mov    0x14(%ebp),%eax
f01008ce:	8d 40 04             	lea    0x4(%eax),%eax
f01008d1:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01008d4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01008d7:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01008db:	79 89                	jns    f0100866 <vprintfmt+0x55>
				width = precision, precision = -1;
f01008dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01008e0:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01008e3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01008ea:	e9 77 ff ff ff       	jmp    f0100866 <vprintfmt+0x55>

f01008ef <.L33>:
f01008ef:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01008f2:	85 c0                	test   %eax,%eax
f01008f4:	ba 00 00 00 00       	mov    $0x0,%edx
f01008f9:	0f 49 d0             	cmovns %eax,%edx
f01008fc:	89 55 d0             	mov    %edx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01008ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0100902:	e9 5f ff ff ff       	jmp    f0100866 <vprintfmt+0x55>

f0100907 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f0100907:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f010090a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0100911:	e9 50 ff ff ff       	jmp    f0100866 <vprintfmt+0x55>
f0100916:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100919:	89 75 08             	mov    %esi,0x8(%ebp)
f010091c:	eb b9                	jmp    f01008d7 <.L34+0x14>

f010091e <.L27>:
			lflag++;
f010091e:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100922:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0100925:	e9 3c ff ff ff       	jmp    f0100866 <vprintfmt+0x55>

f010092a <.L30>:
f010092a:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f010092d:	8b 45 14             	mov    0x14(%ebp),%eax
f0100930:	8d 58 04             	lea    0x4(%eax),%ebx
f0100933:	83 ec 08             	sub    $0x8,%esp
f0100936:	57                   	push   %edi
f0100937:	ff 30                	pushl  (%eax)
f0100939:	ff d6                	call   *%esi
			break;
f010093b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010093e:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0100941:	e9 8e 02 00 00       	jmp    f0100bd4 <.L25+0x45>

f0100946 <.L28>:
f0100946:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f0100949:	8b 45 14             	mov    0x14(%ebp),%eax
f010094c:	8d 58 04             	lea    0x4(%eax),%ebx
f010094f:	8b 00                	mov    (%eax),%eax
f0100951:	99                   	cltd   
f0100952:	31 d0                	xor    %edx,%eax
f0100954:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100956:	83 f8 06             	cmp    $0x6,%eax
f0100959:	7f 27                	jg     f0100982 <.L28+0x3c>
f010095b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010095e:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0100961:	85 d2                	test   %edx,%edx
f0100963:	74 1d                	je     f0100982 <.L28+0x3c>
				printfmt(putch, putdat, "%s", p);
f0100965:	52                   	push   %edx
f0100966:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100969:	8d 80 41 24 ff ff    	lea    -0xdbbf(%eax),%eax
f010096f:	50                   	push   %eax
f0100970:	57                   	push   %edi
f0100971:	56                   	push   %esi
f0100972:	e8 79 fe ff ff       	call   f01007f0 <printfmt>
f0100977:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010097a:	89 5d 14             	mov    %ebx,0x14(%ebp)
f010097d:	e9 52 02 00 00       	jmp    f0100bd4 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f0100982:	50                   	push   %eax
f0100983:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100986:	8d 80 38 24 ff ff    	lea    -0xdbc8(%eax),%eax
f010098c:	50                   	push   %eax
f010098d:	57                   	push   %edi
f010098e:	56                   	push   %esi
f010098f:	e8 5c fe ff ff       	call   f01007f0 <printfmt>
f0100994:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100997:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010099a:	e9 35 02 00 00       	jmp    f0100bd4 <.L25+0x45>

f010099f <.L24>:
f010099f:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f01009a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01009a5:	83 c0 04             	add    $0x4,%eax
f01009a8:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01009ab:	8b 45 14             	mov    0x14(%ebp),%eax
f01009ae:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01009b0:	85 d2                	test   %edx,%edx
f01009b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01009b5:	8d 80 31 24 ff ff    	lea    -0xdbcf(%eax),%eax
f01009bb:	0f 45 c2             	cmovne %edx,%eax
f01009be:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01009c1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01009c5:	7e 06                	jle    f01009cd <.L24+0x2e>
f01009c7:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01009cb:	75 0d                	jne    f01009da <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01009cd:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01009d0:	89 c3                	mov    %eax,%ebx
f01009d2:	03 45 d0             	add    -0x30(%ebp),%eax
f01009d5:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01009d8:	eb 58                	jmp    f0100a32 <.L24+0x93>
f01009da:	83 ec 08             	sub    $0x8,%esp
f01009dd:	ff 75 d8             	pushl  -0x28(%ebp)
f01009e0:	ff 75 c8             	pushl  -0x38(%ebp)
f01009e3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01009e6:	e8 4d 04 00 00       	call   f0100e38 <strnlen>
f01009eb:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01009ee:	29 c2                	sub    %eax,%edx
f01009f0:	89 55 bc             	mov    %edx,-0x44(%ebp)
f01009f3:	83 c4 10             	add    $0x10,%esp
f01009f6:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f01009f8:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01009fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01009ff:	85 db                	test   %ebx,%ebx
f0100a01:	7e 11                	jle    f0100a14 <.L24+0x75>
					putch(padc, putdat);
f0100a03:	83 ec 08             	sub    $0x8,%esp
f0100a06:	57                   	push   %edi
f0100a07:	ff 75 d0             	pushl  -0x30(%ebp)
f0100a0a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0100a0c:	83 eb 01             	sub    $0x1,%ebx
f0100a0f:	83 c4 10             	add    $0x10,%esp
f0100a12:	eb eb                	jmp    f01009ff <.L24+0x60>
f0100a14:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0100a17:	85 d2                	test   %edx,%edx
f0100a19:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a1e:	0f 49 c2             	cmovns %edx,%eax
f0100a21:	29 c2                	sub    %eax,%edx
f0100a23:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100a26:	eb a5                	jmp    f01009cd <.L24+0x2e>
					putch(ch, putdat);
f0100a28:	83 ec 08             	sub    $0x8,%esp
f0100a2b:	57                   	push   %edi
f0100a2c:	52                   	push   %edx
f0100a2d:	ff d6                	call   *%esi
f0100a2f:	83 c4 10             	add    $0x10,%esp
f0100a32:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100a35:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100a37:	83 c3 01             	add    $0x1,%ebx
f0100a3a:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0100a3e:	0f be d0             	movsbl %al,%edx
f0100a41:	85 d2                	test   %edx,%edx
f0100a43:	74 4b                	je     f0100a90 <.L24+0xf1>
f0100a45:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100a49:	78 06                	js     f0100a51 <.L24+0xb2>
f0100a4b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0100a4f:	78 1e                	js     f0100a6f <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0100a51:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100a55:	74 d1                	je     f0100a28 <.L24+0x89>
f0100a57:	0f be c0             	movsbl %al,%eax
f0100a5a:	83 e8 20             	sub    $0x20,%eax
f0100a5d:	83 f8 5e             	cmp    $0x5e,%eax
f0100a60:	76 c6                	jbe    f0100a28 <.L24+0x89>
					putch('?', putdat);
f0100a62:	83 ec 08             	sub    $0x8,%esp
f0100a65:	57                   	push   %edi
f0100a66:	6a 3f                	push   $0x3f
f0100a68:	ff d6                	call   *%esi
f0100a6a:	83 c4 10             	add    $0x10,%esp
f0100a6d:	eb c3                	jmp    f0100a32 <.L24+0x93>
f0100a6f:	89 cb                	mov    %ecx,%ebx
f0100a71:	eb 0e                	jmp    f0100a81 <.L24+0xe2>
				putch(' ', putdat);
f0100a73:	83 ec 08             	sub    $0x8,%esp
f0100a76:	57                   	push   %edi
f0100a77:	6a 20                	push   $0x20
f0100a79:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0100a7b:	83 eb 01             	sub    $0x1,%ebx
f0100a7e:	83 c4 10             	add    $0x10,%esp
f0100a81:	85 db                	test   %ebx,%ebx
f0100a83:	7f ee                	jg     f0100a73 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f0100a85:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100a88:	89 45 14             	mov    %eax,0x14(%ebp)
f0100a8b:	e9 44 01 00 00       	jmp    f0100bd4 <.L25+0x45>
f0100a90:	89 cb                	mov    %ecx,%ebx
f0100a92:	eb ed                	jmp    f0100a81 <.L24+0xe2>

f0100a94 <.L29>:
f0100a94:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100a97:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0100a9a:	83 f9 01             	cmp    $0x1,%ecx
f0100a9d:	7f 1b                	jg     f0100aba <.L29+0x26>
	else if (lflag)
f0100a9f:	85 c9                	test   %ecx,%ecx
f0100aa1:	74 63                	je     f0100b06 <.L29+0x72>
		return va_arg(*ap, long);
f0100aa3:	8b 45 14             	mov    0x14(%ebp),%eax
f0100aa6:	8b 00                	mov    (%eax),%eax
f0100aa8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100aab:	99                   	cltd   
f0100aac:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100aaf:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ab2:	8d 40 04             	lea    0x4(%eax),%eax
f0100ab5:	89 45 14             	mov    %eax,0x14(%ebp)
f0100ab8:	eb 17                	jmp    f0100ad1 <.L29+0x3d>
		return va_arg(*ap, long long);
f0100aba:	8b 45 14             	mov    0x14(%ebp),%eax
f0100abd:	8b 50 04             	mov    0x4(%eax),%edx
f0100ac0:	8b 00                	mov    (%eax),%eax
f0100ac2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100ac5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100ac8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100acb:	8d 40 08             	lea    0x8(%eax),%eax
f0100ace:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0100ad1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100ad4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0100ad7:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0100adc:	85 c9                	test   %ecx,%ecx
f0100ade:	0f 89 d6 00 00 00    	jns    f0100bba <.L25+0x2b>
				putch('-', putdat);
f0100ae4:	83 ec 08             	sub    $0x8,%esp
f0100ae7:	57                   	push   %edi
f0100ae8:	6a 2d                	push   $0x2d
f0100aea:	ff d6                	call   *%esi
				num = -(long long) num;
f0100aec:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100aef:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100af2:	f7 da                	neg    %edx
f0100af4:	83 d1 00             	adc    $0x0,%ecx
f0100af7:	f7 d9                	neg    %ecx
f0100af9:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0100afc:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100b01:	e9 b4 00 00 00       	jmp    f0100bba <.L25+0x2b>
		return va_arg(*ap, int);
f0100b06:	8b 45 14             	mov    0x14(%ebp),%eax
f0100b09:	8b 00                	mov    (%eax),%eax
f0100b0b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100b0e:	99                   	cltd   
f0100b0f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100b12:	8b 45 14             	mov    0x14(%ebp),%eax
f0100b15:	8d 40 04             	lea    0x4(%eax),%eax
f0100b18:	89 45 14             	mov    %eax,0x14(%ebp)
f0100b1b:	eb b4                	jmp    f0100ad1 <.L29+0x3d>

f0100b1d <.L23>:
f0100b1d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100b20:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0100b23:	83 f9 01             	cmp    $0x1,%ecx
f0100b26:	7f 1b                	jg     f0100b43 <.L23+0x26>
	else if (lflag)
f0100b28:	85 c9                	test   %ecx,%ecx
f0100b2a:	74 2c                	je     f0100b58 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
f0100b2c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100b2f:	8b 10                	mov    (%eax),%edx
f0100b31:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100b36:	8d 40 04             	lea    0x4(%eax),%eax
f0100b39:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0100b3c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f0100b41:	eb 77                	jmp    f0100bba <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0100b43:	8b 45 14             	mov    0x14(%ebp),%eax
f0100b46:	8b 10                	mov    (%eax),%edx
f0100b48:	8b 48 04             	mov    0x4(%eax),%ecx
f0100b4b:	8d 40 08             	lea    0x8(%eax),%eax
f0100b4e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0100b51:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f0100b56:	eb 62                	jmp    f0100bba <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0100b58:	8b 45 14             	mov    0x14(%ebp),%eax
f0100b5b:	8b 10                	mov    (%eax),%edx
f0100b5d:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100b62:	8d 40 04             	lea    0x4(%eax),%eax
f0100b65:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0100b68:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f0100b6d:	eb 4b                	jmp    f0100bba <.L25+0x2b>

f0100b6f <.L26>:
f0100b6f:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('X', putdat);
f0100b72:	83 ec 08             	sub    $0x8,%esp
f0100b75:	57                   	push   %edi
f0100b76:	6a 58                	push   $0x58
f0100b78:	ff d6                	call   *%esi
			putch('X', putdat);
f0100b7a:	83 c4 08             	add    $0x8,%esp
f0100b7d:	57                   	push   %edi
f0100b7e:	6a 58                	push   $0x58
f0100b80:	ff d6                	call   *%esi
			putch('X', putdat);
f0100b82:	83 c4 08             	add    $0x8,%esp
f0100b85:	57                   	push   %edi
f0100b86:	6a 58                	push   $0x58
f0100b88:	ff d6                	call   *%esi
			break;
f0100b8a:	83 c4 10             	add    $0x10,%esp
f0100b8d:	eb 45                	jmp    f0100bd4 <.L25+0x45>

f0100b8f <.L25>:
f0100b8f:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f0100b92:	83 ec 08             	sub    $0x8,%esp
f0100b95:	57                   	push   %edi
f0100b96:	6a 30                	push   $0x30
f0100b98:	ff d6                	call   *%esi
			putch('x', putdat);
f0100b9a:	83 c4 08             	add    $0x8,%esp
f0100b9d:	57                   	push   %edi
f0100b9e:	6a 78                	push   $0x78
f0100ba0:	ff d6                	call   *%esi
			num = (unsigned long long)
f0100ba2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ba5:	8b 10                	mov    (%eax),%edx
f0100ba7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0100bac:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0100baf:	8d 40 04             	lea    0x4(%eax),%eax
f0100bb2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0100bb5:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0100bba:	83 ec 0c             	sub    $0xc,%esp
f0100bbd:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f0100bc1:	53                   	push   %ebx
f0100bc2:	ff 75 d0             	pushl  -0x30(%ebp)
f0100bc5:	50                   	push   %eax
f0100bc6:	51                   	push   %ecx
f0100bc7:	52                   	push   %edx
f0100bc8:	89 fa                	mov    %edi,%edx
f0100bca:	89 f0                	mov    %esi,%eax
f0100bcc:	e8 40 fb ff ff       	call   f0100711 <printnum>
			break;
f0100bd1:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0100bd4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100bd7:	83 c3 01             	add    $0x1,%ebx
f0100bda:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0100bde:	83 f8 25             	cmp    $0x25,%eax
f0100be1:	0f 84 5b fc ff ff    	je     f0100842 <vprintfmt+0x31>
			if (ch == '\0')
f0100be7:	85 c0                	test   %eax,%eax
f0100be9:	0f 84 97 00 00 00    	je     f0100c86 <.L20+0x23>
			putch(ch, putdat);
f0100bef:	83 ec 08             	sub    $0x8,%esp
f0100bf2:	57                   	push   %edi
f0100bf3:	50                   	push   %eax
f0100bf4:	ff d6                	call   *%esi
f0100bf6:	83 c4 10             	add    $0x10,%esp
f0100bf9:	eb dc                	jmp    f0100bd7 <.L25+0x48>

f0100bfb <.L21>:
f0100bfb:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100bfe:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0100c01:	83 f9 01             	cmp    $0x1,%ecx
f0100c04:	7f 1b                	jg     f0100c21 <.L21+0x26>
	else if (lflag)
f0100c06:	85 c9                	test   %ecx,%ecx
f0100c08:	74 2c                	je     f0100c36 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0100c0a:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c0d:	8b 10                	mov    (%eax),%edx
f0100c0f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100c14:	8d 40 04             	lea    0x4(%eax),%eax
f0100c17:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0100c1a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f0100c1f:	eb 99                	jmp    f0100bba <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0100c21:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c24:	8b 10                	mov    (%eax),%edx
f0100c26:	8b 48 04             	mov    0x4(%eax),%ecx
f0100c29:	8d 40 08             	lea    0x8(%eax),%eax
f0100c2c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0100c2f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0100c34:	eb 84                	jmp    f0100bba <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0100c36:	8b 45 14             	mov    0x14(%ebp),%eax
f0100c39:	8b 10                	mov    (%eax),%edx
f0100c3b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100c40:	8d 40 04             	lea    0x4(%eax),%eax
f0100c43:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0100c46:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0100c4b:	e9 6a ff ff ff       	jmp    f0100bba <.L25+0x2b>

f0100c50 <.L35>:
f0100c50:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f0100c53:	83 ec 08             	sub    $0x8,%esp
f0100c56:	57                   	push   %edi
f0100c57:	6a 25                	push   $0x25
f0100c59:	ff d6                	call   *%esi
			break;
f0100c5b:	83 c4 10             	add    $0x10,%esp
f0100c5e:	e9 71 ff ff ff       	jmp    f0100bd4 <.L25+0x45>

f0100c63 <.L20>:
f0100c63:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f0100c66:	83 ec 08             	sub    $0x8,%esp
f0100c69:	57                   	push   %edi
f0100c6a:	6a 25                	push   $0x25
f0100c6c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0100c6e:	83 c4 10             	add    $0x10,%esp
f0100c71:	89 d8                	mov    %ebx,%eax
f0100c73:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0100c77:	74 05                	je     f0100c7e <.L20+0x1b>
f0100c79:	83 e8 01             	sub    $0x1,%eax
f0100c7c:	eb f5                	jmp    f0100c73 <.L20+0x10>
f0100c7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100c81:	e9 4e ff ff ff       	jmp    f0100bd4 <.L25+0x45>
}
f0100c86:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c89:	5b                   	pop    %ebx
f0100c8a:	5e                   	pop    %esi
f0100c8b:	5f                   	pop    %edi
f0100c8c:	5d                   	pop    %ebp
f0100c8d:	c3                   	ret    

f0100c8e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0100c8e:	f3 0f 1e fb          	endbr32 
f0100c92:	55                   	push   %ebp
f0100c93:	89 e5                	mov    %esp,%ebp
f0100c95:	53                   	push   %ebx
f0100c96:	83 ec 14             	sub    $0x14,%esp
f0100c99:	e8 3e f4 ff ff       	call   f01000dc <__x86.get_pc_thunk.bx>
f0100c9e:	81 c3 62 e6 00 00    	add    $0xe662,%ebx
f0100ca4:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ca7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0100caa:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100cad:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0100cb1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0100cb4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0100cbb:	85 c0                	test   %eax,%eax
f0100cbd:	74 2b                	je     f0100cea <vsnprintf+0x5c>
f0100cbf:	85 d2                	test   %edx,%edx
f0100cc1:	7e 27                	jle    f0100cea <vsnprintf+0x5c>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0100cc3:	ff 75 14             	pushl  0x14(%ebp)
f0100cc6:	ff 75 10             	pushl  0x10(%ebp)
f0100cc9:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0100ccc:	50                   	push   %eax
f0100ccd:	8d 83 cf 14 ff ff    	lea    -0xeb31(%ebx),%eax
f0100cd3:	50                   	push   %eax
f0100cd4:	e8 38 fb ff ff       	call   f0100811 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0100cd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100cdc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0100cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100ce2:	83 c4 10             	add    $0x10,%esp
}
f0100ce5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ce8:	c9                   	leave  
f0100ce9:	c3                   	ret    
		return -E_INVAL;
f0100cea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0100cef:	eb f4                	jmp    f0100ce5 <vsnprintf+0x57>

f0100cf1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0100cf1:	f3 0f 1e fb          	endbr32 
f0100cf5:	55                   	push   %ebp
f0100cf6:	89 e5                	mov    %esp,%ebp
f0100cf8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0100cfb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0100cfe:	50                   	push   %eax
f0100cff:	ff 75 10             	pushl  0x10(%ebp)
f0100d02:	ff 75 0c             	pushl  0xc(%ebp)
f0100d05:	ff 75 08             	pushl  0x8(%ebp)
f0100d08:	e8 81 ff ff ff       	call   f0100c8e <vsnprintf>
	va_end(ap);

	return rc;
}
f0100d0d:	c9                   	leave  
f0100d0e:	c3                   	ret    

f0100d0f <__x86.get_pc_thunk.cx>:
f0100d0f:	8b 0c 24             	mov    (%esp),%ecx
f0100d12:	c3                   	ret    

f0100d13 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0100d13:	f3 0f 1e fb          	endbr32 
f0100d17:	55                   	push   %ebp
f0100d18:	89 e5                	mov    %esp,%ebp
f0100d1a:	57                   	push   %edi
f0100d1b:	56                   	push   %esi
f0100d1c:	53                   	push   %ebx
f0100d1d:	83 ec 1c             	sub    $0x1c,%esp
f0100d20:	e8 b7 f3 ff ff       	call   f01000dc <__x86.get_pc_thunk.bx>
f0100d25:	81 c3 db e5 00 00    	add    $0xe5db,%ebx
f0100d2b:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0100d2e:	85 c0                	test   %eax,%eax
f0100d30:	74 13                	je     f0100d45 <readline+0x32>
		cprintf("%s", prompt);
f0100d32:	83 ec 08             	sub    $0x8,%esp
f0100d35:	50                   	push   %eax
f0100d36:	8d 83 41 24 ff ff    	lea    -0xdbbf(%ebx),%eax
f0100d3c:	50                   	push   %eax
f0100d3d:	e8 b7 f9 ff ff       	call   f01006f9 <cprintf>
f0100d42:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0100d45:	83 ec 0c             	sub    $0xc,%esp
f0100d48:	6a 00                	push   $0x0
f0100d4a:	e8 37 f9 ff ff       	call   f0100686 <iscons>
f0100d4f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100d52:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0100d55:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0100d5a:	8d 83 80 1f 00 00    	lea    0x1f80(%ebx),%eax
f0100d60:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d63:	eb 51                	jmp    f0100db6 <readline+0xa3>
			cprintf("read error: %e\n", c);
f0100d65:	83 ec 08             	sub    $0x8,%esp
f0100d68:	50                   	push   %eax
f0100d69:	8d 83 08 26 ff ff    	lea    -0xd9f8(%ebx),%eax
f0100d6f:	50                   	push   %eax
f0100d70:	e8 84 f9 ff ff       	call   f01006f9 <cprintf>
			return NULL;
f0100d75:	83 c4 10             	add    $0x10,%esp
f0100d78:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0100d7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d80:	5b                   	pop    %ebx
f0100d81:	5e                   	pop    %esi
f0100d82:	5f                   	pop    %edi
f0100d83:	5d                   	pop    %ebp
f0100d84:	c3                   	ret    
			if (echoing)
f0100d85:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100d89:	75 05                	jne    f0100d90 <readline+0x7d>
			i--;
f0100d8b:	83 ef 01             	sub    $0x1,%edi
f0100d8e:	eb 26                	jmp    f0100db6 <readline+0xa3>
				cputchar('\b');
f0100d90:	83 ec 0c             	sub    $0xc,%esp
f0100d93:	6a 08                	push   $0x8
f0100d95:	e8 c3 f8 ff ff       	call   f010065d <cputchar>
f0100d9a:	83 c4 10             	add    $0x10,%esp
f0100d9d:	eb ec                	jmp    f0100d8b <readline+0x78>
				cputchar(c);
f0100d9f:	83 ec 0c             	sub    $0xc,%esp
f0100da2:	56                   	push   %esi
f0100da3:	e8 b5 f8 ff ff       	call   f010065d <cputchar>
f0100da8:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0100dab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100dae:	89 f0                	mov    %esi,%eax
f0100db0:	88 04 39             	mov    %al,(%ecx,%edi,1)
f0100db3:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0100db6:	e8 b6 f8 ff ff       	call   f0100671 <getchar>
f0100dbb:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0100dbd:	85 c0                	test   %eax,%eax
f0100dbf:	78 a4                	js     f0100d65 <readline+0x52>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0100dc1:	83 f8 08             	cmp    $0x8,%eax
f0100dc4:	0f 94 c2             	sete   %dl
f0100dc7:	83 f8 7f             	cmp    $0x7f,%eax
f0100dca:	0f 94 c0             	sete   %al
f0100dcd:	08 c2                	or     %al,%dl
f0100dcf:	74 04                	je     f0100dd5 <readline+0xc2>
f0100dd1:	85 ff                	test   %edi,%edi
f0100dd3:	7f b0                	jg     f0100d85 <readline+0x72>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0100dd5:	83 fe 1f             	cmp    $0x1f,%esi
f0100dd8:	7e 10                	jle    f0100dea <readline+0xd7>
f0100dda:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0100de0:	7f 08                	jg     f0100dea <readline+0xd7>
			if (echoing)
f0100de2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100de6:	74 c3                	je     f0100dab <readline+0x98>
f0100de8:	eb b5                	jmp    f0100d9f <readline+0x8c>
		} else if (c == '\n' || c == '\r') {
f0100dea:	83 fe 0a             	cmp    $0xa,%esi
f0100ded:	74 05                	je     f0100df4 <readline+0xe1>
f0100def:	83 fe 0d             	cmp    $0xd,%esi
f0100df2:	75 c2                	jne    f0100db6 <readline+0xa3>
			if (echoing)
f0100df4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100df8:	75 13                	jne    f0100e0d <readline+0xfa>
			buf[i] = 0;
f0100dfa:	c6 84 3b 80 1f 00 00 	movb   $0x0,0x1f80(%ebx,%edi,1)
f0100e01:	00 
			return buf;
f0100e02:	8d 83 80 1f 00 00    	lea    0x1f80(%ebx),%eax
f0100e08:	e9 70 ff ff ff       	jmp    f0100d7d <readline+0x6a>
				cputchar('\n');
f0100e0d:	83 ec 0c             	sub    $0xc,%esp
f0100e10:	6a 0a                	push   $0xa
f0100e12:	e8 46 f8 ff ff       	call   f010065d <cputchar>
f0100e17:	83 c4 10             	add    $0x10,%esp
f0100e1a:	eb de                	jmp    f0100dfa <readline+0xe7>

f0100e1c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0100e1c:	f3 0f 1e fb          	endbr32 
f0100e20:	55                   	push   %ebp
f0100e21:	89 e5                	mov    %esp,%ebp
f0100e23:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0100e26:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e2b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0100e2f:	74 05                	je     f0100e36 <strlen+0x1a>
		n++;
f0100e31:	83 c0 01             	add    $0x1,%eax
f0100e34:	eb f5                	jmp    f0100e2b <strlen+0xf>
	return n;
}
f0100e36:	5d                   	pop    %ebp
f0100e37:	c3                   	ret    

f0100e38 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0100e38:	f3 0f 1e fb          	endbr32 
f0100e3c:	55                   	push   %ebp
f0100e3d:	89 e5                	mov    %esp,%ebp
f0100e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100e42:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0100e45:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e4a:	39 d0                	cmp    %edx,%eax
f0100e4c:	74 0d                	je     f0100e5b <strnlen+0x23>
f0100e4e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0100e52:	74 05                	je     f0100e59 <strnlen+0x21>
		n++;
f0100e54:	83 c0 01             	add    $0x1,%eax
f0100e57:	eb f1                	jmp    f0100e4a <strnlen+0x12>
f0100e59:	89 c2                	mov    %eax,%edx
	return n;
}
f0100e5b:	89 d0                	mov    %edx,%eax
f0100e5d:	5d                   	pop    %ebp
f0100e5e:	c3                   	ret    

f0100e5f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0100e5f:	f3 0f 1e fb          	endbr32 
f0100e63:	55                   	push   %ebp
f0100e64:	89 e5                	mov    %esp,%ebp
f0100e66:	53                   	push   %ebx
f0100e67:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100e6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0100e6d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e72:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0100e76:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0100e79:	83 c0 01             	add    $0x1,%eax
f0100e7c:	84 d2                	test   %dl,%dl
f0100e7e:	75 f2                	jne    f0100e72 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0100e80:	89 c8                	mov    %ecx,%eax
f0100e82:	5b                   	pop    %ebx
f0100e83:	5d                   	pop    %ebp
f0100e84:	c3                   	ret    

f0100e85 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0100e85:	f3 0f 1e fb          	endbr32 
f0100e89:	55                   	push   %ebp
f0100e8a:	89 e5                	mov    %esp,%ebp
f0100e8c:	53                   	push   %ebx
f0100e8d:	83 ec 10             	sub    $0x10,%esp
f0100e90:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0100e93:	53                   	push   %ebx
f0100e94:	e8 83 ff ff ff       	call   f0100e1c <strlen>
f0100e99:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0100e9c:	ff 75 0c             	pushl  0xc(%ebp)
f0100e9f:	01 d8                	add    %ebx,%eax
f0100ea1:	50                   	push   %eax
f0100ea2:	e8 b8 ff ff ff       	call   f0100e5f <strcpy>
	return dst;
}
f0100ea7:	89 d8                	mov    %ebx,%eax
f0100ea9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100eac:	c9                   	leave  
f0100ead:	c3                   	ret    

f0100eae <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0100eae:	f3 0f 1e fb          	endbr32 
f0100eb2:	55                   	push   %ebp
f0100eb3:	89 e5                	mov    %esp,%ebp
f0100eb5:	56                   	push   %esi
f0100eb6:	53                   	push   %ebx
f0100eb7:	8b 75 08             	mov    0x8(%ebp),%esi
f0100eba:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ebd:	89 f3                	mov    %esi,%ebx
f0100ebf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0100ec2:	89 f0                	mov    %esi,%eax
f0100ec4:	39 d8                	cmp    %ebx,%eax
f0100ec6:	74 11                	je     f0100ed9 <strncpy+0x2b>
		*dst++ = *src;
f0100ec8:	83 c0 01             	add    $0x1,%eax
f0100ecb:	0f b6 0a             	movzbl (%edx),%ecx
f0100ece:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0100ed1:	80 f9 01             	cmp    $0x1,%cl
f0100ed4:	83 da ff             	sbb    $0xffffffff,%edx
f0100ed7:	eb eb                	jmp    f0100ec4 <strncpy+0x16>
	}
	return ret;
}
f0100ed9:	89 f0                	mov    %esi,%eax
f0100edb:	5b                   	pop    %ebx
f0100edc:	5e                   	pop    %esi
f0100edd:	5d                   	pop    %ebp
f0100ede:	c3                   	ret    

f0100edf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0100edf:	f3 0f 1e fb          	endbr32 
f0100ee3:	55                   	push   %ebp
f0100ee4:	89 e5                	mov    %esp,%ebp
f0100ee6:	56                   	push   %esi
f0100ee7:	53                   	push   %ebx
f0100ee8:	8b 75 08             	mov    0x8(%ebp),%esi
f0100eeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0100eee:	8b 55 10             	mov    0x10(%ebp),%edx
f0100ef1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0100ef3:	85 d2                	test   %edx,%edx
f0100ef5:	74 21                	je     f0100f18 <strlcpy+0x39>
f0100ef7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0100efb:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0100efd:	39 c2                	cmp    %eax,%edx
f0100eff:	74 14                	je     f0100f15 <strlcpy+0x36>
f0100f01:	0f b6 19             	movzbl (%ecx),%ebx
f0100f04:	84 db                	test   %bl,%bl
f0100f06:	74 0b                	je     f0100f13 <strlcpy+0x34>
			*dst++ = *src++;
f0100f08:	83 c1 01             	add    $0x1,%ecx
f0100f0b:	83 c2 01             	add    $0x1,%edx
f0100f0e:	88 5a ff             	mov    %bl,-0x1(%edx)
f0100f11:	eb ea                	jmp    f0100efd <strlcpy+0x1e>
f0100f13:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0100f15:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0100f18:	29 f0                	sub    %esi,%eax
}
f0100f1a:	5b                   	pop    %ebx
f0100f1b:	5e                   	pop    %esi
f0100f1c:	5d                   	pop    %ebp
f0100f1d:	c3                   	ret    

f0100f1e <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0100f1e:	f3 0f 1e fb          	endbr32 
f0100f22:	55                   	push   %ebp
f0100f23:	89 e5                	mov    %esp,%ebp
f0100f25:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100f28:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0100f2b:	0f b6 01             	movzbl (%ecx),%eax
f0100f2e:	84 c0                	test   %al,%al
f0100f30:	74 0c                	je     f0100f3e <strcmp+0x20>
f0100f32:	3a 02                	cmp    (%edx),%al
f0100f34:	75 08                	jne    f0100f3e <strcmp+0x20>
		p++, q++;
f0100f36:	83 c1 01             	add    $0x1,%ecx
f0100f39:	83 c2 01             	add    $0x1,%edx
f0100f3c:	eb ed                	jmp    f0100f2b <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0100f3e:	0f b6 c0             	movzbl %al,%eax
f0100f41:	0f b6 12             	movzbl (%edx),%edx
f0100f44:	29 d0                	sub    %edx,%eax
}
f0100f46:	5d                   	pop    %ebp
f0100f47:	c3                   	ret    

f0100f48 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0100f48:	f3 0f 1e fb          	endbr32 
f0100f4c:	55                   	push   %ebp
f0100f4d:	89 e5                	mov    %esp,%ebp
f0100f4f:	53                   	push   %ebx
f0100f50:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f53:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100f56:	89 c3                	mov    %eax,%ebx
f0100f58:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0100f5b:	eb 06                	jmp    f0100f63 <strncmp+0x1b>
		n--, p++, q++;
f0100f5d:	83 c0 01             	add    $0x1,%eax
f0100f60:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0100f63:	39 d8                	cmp    %ebx,%eax
f0100f65:	74 16                	je     f0100f7d <strncmp+0x35>
f0100f67:	0f b6 08             	movzbl (%eax),%ecx
f0100f6a:	84 c9                	test   %cl,%cl
f0100f6c:	74 04                	je     f0100f72 <strncmp+0x2a>
f0100f6e:	3a 0a                	cmp    (%edx),%cl
f0100f70:	74 eb                	je     f0100f5d <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0100f72:	0f b6 00             	movzbl (%eax),%eax
f0100f75:	0f b6 12             	movzbl (%edx),%edx
f0100f78:	29 d0                	sub    %edx,%eax
}
f0100f7a:	5b                   	pop    %ebx
f0100f7b:	5d                   	pop    %ebp
f0100f7c:	c3                   	ret    
		return 0;
f0100f7d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f82:	eb f6                	jmp    f0100f7a <strncmp+0x32>

f0100f84 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0100f84:	f3 0f 1e fb          	endbr32 
f0100f88:	55                   	push   %ebp
f0100f89:	89 e5                	mov    %esp,%ebp
f0100f8b:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f8e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0100f92:	0f b6 10             	movzbl (%eax),%edx
f0100f95:	84 d2                	test   %dl,%dl
f0100f97:	74 09                	je     f0100fa2 <strchr+0x1e>
		if (*s == c)
f0100f99:	38 ca                	cmp    %cl,%dl
f0100f9b:	74 0a                	je     f0100fa7 <strchr+0x23>
	for (; *s; s++)
f0100f9d:	83 c0 01             	add    $0x1,%eax
f0100fa0:	eb f0                	jmp    f0100f92 <strchr+0xe>
			return (char *) s;
	return 0;
f0100fa2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100fa7:	5d                   	pop    %ebp
f0100fa8:	c3                   	ret    

f0100fa9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0100fa9:	f3 0f 1e fb          	endbr32 
f0100fad:	55                   	push   %ebp
f0100fae:	89 e5                	mov    %esp,%ebp
f0100fb0:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fb3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0100fb7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0100fba:	38 ca                	cmp    %cl,%dl
f0100fbc:	74 09                	je     f0100fc7 <strfind+0x1e>
f0100fbe:	84 d2                	test   %dl,%dl
f0100fc0:	74 05                	je     f0100fc7 <strfind+0x1e>
	for (; *s; s++)
f0100fc2:	83 c0 01             	add    $0x1,%eax
f0100fc5:	eb f0                	jmp    f0100fb7 <strfind+0xe>
			break;
	return (char *) s;
}
f0100fc7:	5d                   	pop    %ebp
f0100fc8:	c3                   	ret    

f0100fc9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0100fc9:	f3 0f 1e fb          	endbr32 
f0100fcd:	55                   	push   %ebp
f0100fce:	89 e5                	mov    %esp,%ebp
f0100fd0:	57                   	push   %edi
f0100fd1:	56                   	push   %esi
f0100fd2:	53                   	push   %ebx
f0100fd3:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100fd6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0100fd9:	85 c9                	test   %ecx,%ecx
f0100fdb:	74 31                	je     f010100e <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0100fdd:	89 f8                	mov    %edi,%eax
f0100fdf:	09 c8                	or     %ecx,%eax
f0100fe1:	a8 03                	test   $0x3,%al
f0100fe3:	75 23                	jne    f0101008 <memset+0x3f>
		c &= 0xFF;
f0100fe5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0100fe9:	89 d3                	mov    %edx,%ebx
f0100feb:	c1 e3 08             	shl    $0x8,%ebx
f0100fee:	89 d0                	mov    %edx,%eax
f0100ff0:	c1 e0 18             	shl    $0x18,%eax
f0100ff3:	89 d6                	mov    %edx,%esi
f0100ff5:	c1 e6 10             	shl    $0x10,%esi
f0100ff8:	09 f0                	or     %esi,%eax
f0100ffa:	09 c2                	or     %eax,%edx
f0100ffc:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0100ffe:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101001:	89 d0                	mov    %edx,%eax
f0101003:	fc                   	cld    
f0101004:	f3 ab                	rep stos %eax,%es:(%edi)
f0101006:	eb 06                	jmp    f010100e <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101008:	8b 45 0c             	mov    0xc(%ebp),%eax
f010100b:	fc                   	cld    
f010100c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010100e:	89 f8                	mov    %edi,%eax
f0101010:	5b                   	pop    %ebx
f0101011:	5e                   	pop    %esi
f0101012:	5f                   	pop    %edi
f0101013:	5d                   	pop    %ebp
f0101014:	c3                   	ret    

f0101015 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101015:	f3 0f 1e fb          	endbr32 
f0101019:	55                   	push   %ebp
f010101a:	89 e5                	mov    %esp,%ebp
f010101c:	57                   	push   %edi
f010101d:	56                   	push   %esi
f010101e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101021:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101024:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101027:	39 c6                	cmp    %eax,%esi
f0101029:	73 32                	jae    f010105d <memmove+0x48>
f010102b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010102e:	39 c2                	cmp    %eax,%edx
f0101030:	76 2b                	jbe    f010105d <memmove+0x48>
		s += n;
		d += n;
f0101032:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101035:	89 fe                	mov    %edi,%esi
f0101037:	09 ce                	or     %ecx,%esi
f0101039:	09 d6                	or     %edx,%esi
f010103b:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101041:	75 0e                	jne    f0101051 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101043:	83 ef 04             	sub    $0x4,%edi
f0101046:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101049:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010104c:	fd                   	std    
f010104d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010104f:	eb 09                	jmp    f010105a <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101051:	83 ef 01             	sub    $0x1,%edi
f0101054:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101057:	fd                   	std    
f0101058:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010105a:	fc                   	cld    
f010105b:	eb 1a                	jmp    f0101077 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010105d:	89 c2                	mov    %eax,%edx
f010105f:	09 ca                	or     %ecx,%edx
f0101061:	09 f2                	or     %esi,%edx
f0101063:	f6 c2 03             	test   $0x3,%dl
f0101066:	75 0a                	jne    f0101072 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101068:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010106b:	89 c7                	mov    %eax,%edi
f010106d:	fc                   	cld    
f010106e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101070:	eb 05                	jmp    f0101077 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0101072:	89 c7                	mov    %eax,%edi
f0101074:	fc                   	cld    
f0101075:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101077:	5e                   	pop    %esi
f0101078:	5f                   	pop    %edi
f0101079:	5d                   	pop    %ebp
f010107a:	c3                   	ret    

f010107b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010107b:	f3 0f 1e fb          	endbr32 
f010107f:	55                   	push   %ebp
f0101080:	89 e5                	mov    %esp,%ebp
f0101082:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101085:	ff 75 10             	pushl  0x10(%ebp)
f0101088:	ff 75 0c             	pushl  0xc(%ebp)
f010108b:	ff 75 08             	pushl  0x8(%ebp)
f010108e:	e8 82 ff ff ff       	call   f0101015 <memmove>
}
f0101093:	c9                   	leave  
f0101094:	c3                   	ret    

f0101095 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101095:	f3 0f 1e fb          	endbr32 
f0101099:	55                   	push   %ebp
f010109a:	89 e5                	mov    %esp,%ebp
f010109c:	56                   	push   %esi
f010109d:	53                   	push   %ebx
f010109e:	8b 45 08             	mov    0x8(%ebp),%eax
f01010a1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01010a4:	89 c6                	mov    %eax,%esi
f01010a6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01010a9:	39 f0                	cmp    %esi,%eax
f01010ab:	74 1c                	je     f01010c9 <memcmp+0x34>
		if (*s1 != *s2)
f01010ad:	0f b6 08             	movzbl (%eax),%ecx
f01010b0:	0f b6 1a             	movzbl (%edx),%ebx
f01010b3:	38 d9                	cmp    %bl,%cl
f01010b5:	75 08                	jne    f01010bf <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01010b7:	83 c0 01             	add    $0x1,%eax
f01010ba:	83 c2 01             	add    $0x1,%edx
f01010bd:	eb ea                	jmp    f01010a9 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f01010bf:	0f b6 c1             	movzbl %cl,%eax
f01010c2:	0f b6 db             	movzbl %bl,%ebx
f01010c5:	29 d8                	sub    %ebx,%eax
f01010c7:	eb 05                	jmp    f01010ce <memcmp+0x39>
	}

	return 0;
f01010c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01010ce:	5b                   	pop    %ebx
f01010cf:	5e                   	pop    %esi
f01010d0:	5d                   	pop    %ebp
f01010d1:	c3                   	ret    

f01010d2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01010d2:	f3 0f 1e fb          	endbr32 
f01010d6:	55                   	push   %ebp
f01010d7:	89 e5                	mov    %esp,%ebp
f01010d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01010dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01010df:	89 c2                	mov    %eax,%edx
f01010e1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01010e4:	39 d0                	cmp    %edx,%eax
f01010e6:	73 09                	jae    f01010f1 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f01010e8:	38 08                	cmp    %cl,(%eax)
f01010ea:	74 05                	je     f01010f1 <memfind+0x1f>
	for (; s < ends; s++)
f01010ec:	83 c0 01             	add    $0x1,%eax
f01010ef:	eb f3                	jmp    f01010e4 <memfind+0x12>
			break;
	return (void *) s;
}
f01010f1:	5d                   	pop    %ebp
f01010f2:	c3                   	ret    

f01010f3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01010f3:	f3 0f 1e fb          	endbr32 
f01010f7:	55                   	push   %ebp
f01010f8:	89 e5                	mov    %esp,%ebp
f01010fa:	57                   	push   %edi
f01010fb:	56                   	push   %esi
f01010fc:	53                   	push   %ebx
f01010fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101100:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101103:	eb 03                	jmp    f0101108 <strtol+0x15>
		s++;
f0101105:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101108:	0f b6 01             	movzbl (%ecx),%eax
f010110b:	3c 20                	cmp    $0x20,%al
f010110d:	74 f6                	je     f0101105 <strtol+0x12>
f010110f:	3c 09                	cmp    $0x9,%al
f0101111:	74 f2                	je     f0101105 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0101113:	3c 2b                	cmp    $0x2b,%al
f0101115:	74 2a                	je     f0101141 <strtol+0x4e>
	int neg = 0;
f0101117:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f010111c:	3c 2d                	cmp    $0x2d,%al
f010111e:	74 2b                	je     f010114b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101120:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101126:	75 0f                	jne    f0101137 <strtol+0x44>
f0101128:	80 39 30             	cmpb   $0x30,(%ecx)
f010112b:	74 28                	je     f0101155 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010112d:	85 db                	test   %ebx,%ebx
f010112f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101134:	0f 44 d8             	cmove  %eax,%ebx
f0101137:	b8 00 00 00 00       	mov    $0x0,%eax
f010113c:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010113f:	eb 46                	jmp    f0101187 <strtol+0x94>
		s++;
f0101141:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0101144:	bf 00 00 00 00       	mov    $0x0,%edi
f0101149:	eb d5                	jmp    f0101120 <strtol+0x2d>
		s++, neg = 1;
f010114b:	83 c1 01             	add    $0x1,%ecx
f010114e:	bf 01 00 00 00       	mov    $0x1,%edi
f0101153:	eb cb                	jmp    f0101120 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101155:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101159:	74 0e                	je     f0101169 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f010115b:	85 db                	test   %ebx,%ebx
f010115d:	75 d8                	jne    f0101137 <strtol+0x44>
		s++, base = 8;
f010115f:	83 c1 01             	add    $0x1,%ecx
f0101162:	bb 08 00 00 00       	mov    $0x8,%ebx
f0101167:	eb ce                	jmp    f0101137 <strtol+0x44>
		s += 2, base = 16;
f0101169:	83 c1 02             	add    $0x2,%ecx
f010116c:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101171:	eb c4                	jmp    f0101137 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0101173:	0f be d2             	movsbl %dl,%edx
f0101176:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101179:	3b 55 10             	cmp    0x10(%ebp),%edx
f010117c:	7d 3a                	jge    f01011b8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f010117e:	83 c1 01             	add    $0x1,%ecx
f0101181:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101185:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101187:	0f b6 11             	movzbl (%ecx),%edx
f010118a:	8d 72 d0             	lea    -0x30(%edx),%esi
f010118d:	89 f3                	mov    %esi,%ebx
f010118f:	80 fb 09             	cmp    $0x9,%bl
f0101192:	76 df                	jbe    f0101173 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f0101194:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101197:	89 f3                	mov    %esi,%ebx
f0101199:	80 fb 19             	cmp    $0x19,%bl
f010119c:	77 08                	ja     f01011a6 <strtol+0xb3>
			dig = *s - 'a' + 10;
f010119e:	0f be d2             	movsbl %dl,%edx
f01011a1:	83 ea 57             	sub    $0x57,%edx
f01011a4:	eb d3                	jmp    f0101179 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f01011a6:	8d 72 bf             	lea    -0x41(%edx),%esi
f01011a9:	89 f3                	mov    %esi,%ebx
f01011ab:	80 fb 19             	cmp    $0x19,%bl
f01011ae:	77 08                	ja     f01011b8 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01011b0:	0f be d2             	movsbl %dl,%edx
f01011b3:	83 ea 37             	sub    $0x37,%edx
f01011b6:	eb c1                	jmp    f0101179 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f01011b8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01011bc:	74 05                	je     f01011c3 <strtol+0xd0>
		*endptr = (char *) s;
f01011be:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011c1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01011c3:	89 c2                	mov    %eax,%edx
f01011c5:	f7 da                	neg    %edx
f01011c7:	85 ff                	test   %edi,%edi
f01011c9:	0f 45 c2             	cmovne %edx,%eax
}
f01011cc:	5b                   	pop    %ebx
f01011cd:	5e                   	pop    %esi
f01011ce:	5f                   	pop    %edi
f01011cf:	5d                   	pop    %ebp
f01011d0:	c3                   	ret    
f01011d1:	66 90                	xchg   %ax,%ax
f01011d3:	66 90                	xchg   %ax,%ax
f01011d5:	66 90                	xchg   %ax,%ax
f01011d7:	66 90                	xchg   %ax,%ax
f01011d9:	66 90                	xchg   %ax,%ax
f01011db:	66 90                	xchg   %ax,%ax
f01011dd:	66 90                	xchg   %ax,%ax
f01011df:	90                   	nop

f01011e0 <__udivdi3>:
f01011e0:	f3 0f 1e fb          	endbr32 
f01011e4:	55                   	push   %ebp
f01011e5:	57                   	push   %edi
f01011e6:	56                   	push   %esi
f01011e7:	53                   	push   %ebx
f01011e8:	83 ec 1c             	sub    $0x1c,%esp
f01011eb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01011ef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f01011f3:	8b 74 24 34          	mov    0x34(%esp),%esi
f01011f7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f01011fb:	85 d2                	test   %edx,%edx
f01011fd:	75 19                	jne    f0101218 <__udivdi3+0x38>
f01011ff:	39 f3                	cmp    %esi,%ebx
f0101201:	76 4d                	jbe    f0101250 <__udivdi3+0x70>
f0101203:	31 ff                	xor    %edi,%edi
f0101205:	89 e8                	mov    %ebp,%eax
f0101207:	89 f2                	mov    %esi,%edx
f0101209:	f7 f3                	div    %ebx
f010120b:	89 fa                	mov    %edi,%edx
f010120d:	83 c4 1c             	add    $0x1c,%esp
f0101210:	5b                   	pop    %ebx
f0101211:	5e                   	pop    %esi
f0101212:	5f                   	pop    %edi
f0101213:	5d                   	pop    %ebp
f0101214:	c3                   	ret    
f0101215:	8d 76 00             	lea    0x0(%esi),%esi
f0101218:	39 f2                	cmp    %esi,%edx
f010121a:	76 14                	jbe    f0101230 <__udivdi3+0x50>
f010121c:	31 ff                	xor    %edi,%edi
f010121e:	31 c0                	xor    %eax,%eax
f0101220:	89 fa                	mov    %edi,%edx
f0101222:	83 c4 1c             	add    $0x1c,%esp
f0101225:	5b                   	pop    %ebx
f0101226:	5e                   	pop    %esi
f0101227:	5f                   	pop    %edi
f0101228:	5d                   	pop    %ebp
f0101229:	c3                   	ret    
f010122a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101230:	0f bd fa             	bsr    %edx,%edi
f0101233:	83 f7 1f             	xor    $0x1f,%edi
f0101236:	75 48                	jne    f0101280 <__udivdi3+0xa0>
f0101238:	39 f2                	cmp    %esi,%edx
f010123a:	72 06                	jb     f0101242 <__udivdi3+0x62>
f010123c:	31 c0                	xor    %eax,%eax
f010123e:	39 eb                	cmp    %ebp,%ebx
f0101240:	77 de                	ja     f0101220 <__udivdi3+0x40>
f0101242:	b8 01 00 00 00       	mov    $0x1,%eax
f0101247:	eb d7                	jmp    f0101220 <__udivdi3+0x40>
f0101249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101250:	89 d9                	mov    %ebx,%ecx
f0101252:	85 db                	test   %ebx,%ebx
f0101254:	75 0b                	jne    f0101261 <__udivdi3+0x81>
f0101256:	b8 01 00 00 00       	mov    $0x1,%eax
f010125b:	31 d2                	xor    %edx,%edx
f010125d:	f7 f3                	div    %ebx
f010125f:	89 c1                	mov    %eax,%ecx
f0101261:	31 d2                	xor    %edx,%edx
f0101263:	89 f0                	mov    %esi,%eax
f0101265:	f7 f1                	div    %ecx
f0101267:	89 c6                	mov    %eax,%esi
f0101269:	89 e8                	mov    %ebp,%eax
f010126b:	89 f7                	mov    %esi,%edi
f010126d:	f7 f1                	div    %ecx
f010126f:	89 fa                	mov    %edi,%edx
f0101271:	83 c4 1c             	add    $0x1c,%esp
f0101274:	5b                   	pop    %ebx
f0101275:	5e                   	pop    %esi
f0101276:	5f                   	pop    %edi
f0101277:	5d                   	pop    %ebp
f0101278:	c3                   	ret    
f0101279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101280:	89 f9                	mov    %edi,%ecx
f0101282:	b8 20 00 00 00       	mov    $0x20,%eax
f0101287:	29 f8                	sub    %edi,%eax
f0101289:	d3 e2                	shl    %cl,%edx
f010128b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010128f:	89 c1                	mov    %eax,%ecx
f0101291:	89 da                	mov    %ebx,%edx
f0101293:	d3 ea                	shr    %cl,%edx
f0101295:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101299:	09 d1                	or     %edx,%ecx
f010129b:	89 f2                	mov    %esi,%edx
f010129d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01012a1:	89 f9                	mov    %edi,%ecx
f01012a3:	d3 e3                	shl    %cl,%ebx
f01012a5:	89 c1                	mov    %eax,%ecx
f01012a7:	d3 ea                	shr    %cl,%edx
f01012a9:	89 f9                	mov    %edi,%ecx
f01012ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01012af:	89 eb                	mov    %ebp,%ebx
f01012b1:	d3 e6                	shl    %cl,%esi
f01012b3:	89 c1                	mov    %eax,%ecx
f01012b5:	d3 eb                	shr    %cl,%ebx
f01012b7:	09 de                	or     %ebx,%esi
f01012b9:	89 f0                	mov    %esi,%eax
f01012bb:	f7 74 24 08          	divl   0x8(%esp)
f01012bf:	89 d6                	mov    %edx,%esi
f01012c1:	89 c3                	mov    %eax,%ebx
f01012c3:	f7 64 24 0c          	mull   0xc(%esp)
f01012c7:	39 d6                	cmp    %edx,%esi
f01012c9:	72 15                	jb     f01012e0 <__udivdi3+0x100>
f01012cb:	89 f9                	mov    %edi,%ecx
f01012cd:	d3 e5                	shl    %cl,%ebp
f01012cf:	39 c5                	cmp    %eax,%ebp
f01012d1:	73 04                	jae    f01012d7 <__udivdi3+0xf7>
f01012d3:	39 d6                	cmp    %edx,%esi
f01012d5:	74 09                	je     f01012e0 <__udivdi3+0x100>
f01012d7:	89 d8                	mov    %ebx,%eax
f01012d9:	31 ff                	xor    %edi,%edi
f01012db:	e9 40 ff ff ff       	jmp    f0101220 <__udivdi3+0x40>
f01012e0:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01012e3:	31 ff                	xor    %edi,%edi
f01012e5:	e9 36 ff ff ff       	jmp    f0101220 <__udivdi3+0x40>
f01012ea:	66 90                	xchg   %ax,%ax
f01012ec:	66 90                	xchg   %ax,%ax
f01012ee:	66 90                	xchg   %ax,%ax

f01012f0 <__umoddi3>:
f01012f0:	f3 0f 1e fb          	endbr32 
f01012f4:	55                   	push   %ebp
f01012f5:	57                   	push   %edi
f01012f6:	56                   	push   %esi
f01012f7:	53                   	push   %ebx
f01012f8:	83 ec 1c             	sub    $0x1c,%esp
f01012fb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01012ff:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101303:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101307:	8b 7c 24 38          	mov    0x38(%esp),%edi
f010130b:	85 c0                	test   %eax,%eax
f010130d:	75 19                	jne    f0101328 <__umoddi3+0x38>
f010130f:	39 df                	cmp    %ebx,%edi
f0101311:	76 5d                	jbe    f0101370 <__umoddi3+0x80>
f0101313:	89 f0                	mov    %esi,%eax
f0101315:	89 da                	mov    %ebx,%edx
f0101317:	f7 f7                	div    %edi
f0101319:	89 d0                	mov    %edx,%eax
f010131b:	31 d2                	xor    %edx,%edx
f010131d:	83 c4 1c             	add    $0x1c,%esp
f0101320:	5b                   	pop    %ebx
f0101321:	5e                   	pop    %esi
f0101322:	5f                   	pop    %edi
f0101323:	5d                   	pop    %ebp
f0101324:	c3                   	ret    
f0101325:	8d 76 00             	lea    0x0(%esi),%esi
f0101328:	89 f2                	mov    %esi,%edx
f010132a:	39 d8                	cmp    %ebx,%eax
f010132c:	76 12                	jbe    f0101340 <__umoddi3+0x50>
f010132e:	89 f0                	mov    %esi,%eax
f0101330:	89 da                	mov    %ebx,%edx
f0101332:	83 c4 1c             	add    $0x1c,%esp
f0101335:	5b                   	pop    %ebx
f0101336:	5e                   	pop    %esi
f0101337:	5f                   	pop    %edi
f0101338:	5d                   	pop    %ebp
f0101339:	c3                   	ret    
f010133a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101340:	0f bd e8             	bsr    %eax,%ebp
f0101343:	83 f5 1f             	xor    $0x1f,%ebp
f0101346:	75 50                	jne    f0101398 <__umoddi3+0xa8>
f0101348:	39 d8                	cmp    %ebx,%eax
f010134a:	0f 82 e0 00 00 00    	jb     f0101430 <__umoddi3+0x140>
f0101350:	89 d9                	mov    %ebx,%ecx
f0101352:	39 f7                	cmp    %esi,%edi
f0101354:	0f 86 d6 00 00 00    	jbe    f0101430 <__umoddi3+0x140>
f010135a:	89 d0                	mov    %edx,%eax
f010135c:	89 ca                	mov    %ecx,%edx
f010135e:	83 c4 1c             	add    $0x1c,%esp
f0101361:	5b                   	pop    %ebx
f0101362:	5e                   	pop    %esi
f0101363:	5f                   	pop    %edi
f0101364:	5d                   	pop    %ebp
f0101365:	c3                   	ret    
f0101366:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010136d:	8d 76 00             	lea    0x0(%esi),%esi
f0101370:	89 fd                	mov    %edi,%ebp
f0101372:	85 ff                	test   %edi,%edi
f0101374:	75 0b                	jne    f0101381 <__umoddi3+0x91>
f0101376:	b8 01 00 00 00       	mov    $0x1,%eax
f010137b:	31 d2                	xor    %edx,%edx
f010137d:	f7 f7                	div    %edi
f010137f:	89 c5                	mov    %eax,%ebp
f0101381:	89 d8                	mov    %ebx,%eax
f0101383:	31 d2                	xor    %edx,%edx
f0101385:	f7 f5                	div    %ebp
f0101387:	89 f0                	mov    %esi,%eax
f0101389:	f7 f5                	div    %ebp
f010138b:	89 d0                	mov    %edx,%eax
f010138d:	31 d2                	xor    %edx,%edx
f010138f:	eb 8c                	jmp    f010131d <__umoddi3+0x2d>
f0101391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101398:	89 e9                	mov    %ebp,%ecx
f010139a:	ba 20 00 00 00       	mov    $0x20,%edx
f010139f:	29 ea                	sub    %ebp,%edx
f01013a1:	d3 e0                	shl    %cl,%eax
f01013a3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01013a7:	89 d1                	mov    %edx,%ecx
f01013a9:	89 f8                	mov    %edi,%eax
f01013ab:	d3 e8                	shr    %cl,%eax
f01013ad:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01013b1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01013b5:	8b 54 24 04          	mov    0x4(%esp),%edx
f01013b9:	09 c1                	or     %eax,%ecx
f01013bb:	89 d8                	mov    %ebx,%eax
f01013bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01013c1:	89 e9                	mov    %ebp,%ecx
f01013c3:	d3 e7                	shl    %cl,%edi
f01013c5:	89 d1                	mov    %edx,%ecx
f01013c7:	d3 e8                	shr    %cl,%eax
f01013c9:	89 e9                	mov    %ebp,%ecx
f01013cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01013cf:	d3 e3                	shl    %cl,%ebx
f01013d1:	89 c7                	mov    %eax,%edi
f01013d3:	89 d1                	mov    %edx,%ecx
f01013d5:	89 f0                	mov    %esi,%eax
f01013d7:	d3 e8                	shr    %cl,%eax
f01013d9:	89 e9                	mov    %ebp,%ecx
f01013db:	89 fa                	mov    %edi,%edx
f01013dd:	d3 e6                	shl    %cl,%esi
f01013df:	09 d8                	or     %ebx,%eax
f01013e1:	f7 74 24 08          	divl   0x8(%esp)
f01013e5:	89 d1                	mov    %edx,%ecx
f01013e7:	89 f3                	mov    %esi,%ebx
f01013e9:	f7 64 24 0c          	mull   0xc(%esp)
f01013ed:	89 c6                	mov    %eax,%esi
f01013ef:	89 d7                	mov    %edx,%edi
f01013f1:	39 d1                	cmp    %edx,%ecx
f01013f3:	72 06                	jb     f01013fb <__umoddi3+0x10b>
f01013f5:	75 10                	jne    f0101407 <__umoddi3+0x117>
f01013f7:	39 c3                	cmp    %eax,%ebx
f01013f9:	73 0c                	jae    f0101407 <__umoddi3+0x117>
f01013fb:	2b 44 24 0c          	sub    0xc(%esp),%eax
f01013ff:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101403:	89 d7                	mov    %edx,%edi
f0101405:	89 c6                	mov    %eax,%esi
f0101407:	89 ca                	mov    %ecx,%edx
f0101409:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010140e:	29 f3                	sub    %esi,%ebx
f0101410:	19 fa                	sbb    %edi,%edx
f0101412:	89 d0                	mov    %edx,%eax
f0101414:	d3 e0                	shl    %cl,%eax
f0101416:	89 e9                	mov    %ebp,%ecx
f0101418:	d3 eb                	shr    %cl,%ebx
f010141a:	d3 ea                	shr    %cl,%edx
f010141c:	09 d8                	or     %ebx,%eax
f010141e:	83 c4 1c             	add    $0x1c,%esp
f0101421:	5b                   	pop    %ebx
f0101422:	5e                   	pop    %esi
f0101423:	5f                   	pop    %edi
f0101424:	5d                   	pop    %ebp
f0101425:	c3                   	ret    
f0101426:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010142d:	8d 76 00             	lea    0x0(%esi),%esi
f0101430:	29 fe                	sub    %edi,%esi
f0101432:	19 c3                	sbb    %eax,%ebx
f0101434:	89 f2                	mov    %esi,%edx
f0101436:	89 d9                	mov    %ebx,%ecx
f0101438:	e9 1d ff ff ff       	jmp    f010135a <__umoddi3+0x6a>
