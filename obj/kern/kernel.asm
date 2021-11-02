
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
f010004b:	e8 38 00 00 00       	call   f0100088 <__x86.get_pc_thunk.bx>
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
f0100068:	e8 08 0f 00 00       	call   f0100f75 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010006d:	e8 71 04 00 00       	call   f01004e3 <cons_init>

	cprintf("Hello POS!");
f0100072:	8d 83 e0 20 ff ff    	lea    -0xdf20(%ebx),%eax
f0100078:	89 04 24             	mov    %eax,(%esp)
f010007b:	e8 25 06 00 00       	call   f01006a5 <cprintf>
	// test_backtrace(5);

	// Drop into the kernel monitor.
	// while (1)
	// 	monitor(NULL);
f0100080:	83 c4 10             	add    $0x10,%esp
f0100083:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100086:	c9                   	leave  
f0100087:	c3                   	ret    

f0100088 <__x86.get_pc_thunk.bx>:
f0100088:	8b 1c 24             	mov    (%esp),%ebx
f010008b:	c3                   	ret    

f010008c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010008c:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100090:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100095:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100096:	a8 01                	test   $0x1,%al
f0100098:	74 0a                	je     f01000a4 <serial_proc_data+0x18>
f010009a:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010009f:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01000a0:	0f b6 c0             	movzbl %al,%eax
f01000a3:	c3                   	ret    
		return -1;
f01000a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01000a9:	c3                   	ret    

f01000aa <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01000aa:	55                   	push   %ebp
f01000ab:	89 e5                	mov    %esp,%ebp
f01000ad:	57                   	push   %edi
f01000ae:	56                   	push   %esi
f01000af:	53                   	push   %ebx
f01000b0:	83 ec 1c             	sub    $0x1c,%esp
f01000b3:	e8 88 05 00 00       	call   f0100640 <__x86.get_pc_thunk.si>
f01000b8:	81 c6 48 f2 00 00    	add    $0xf248,%esi
f01000be:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01000c0:	8d 1d 60 1d 00 00    	lea    0x1d60,%ebx
f01000c6:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01000c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01000cc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01000cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01000d2:	ff d0                	call   *%eax
f01000d4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01000d7:	74 2b                	je     f0100104 <cons_intr+0x5a>
		if (c == 0)
f01000d9:	85 c0                	test   %eax,%eax
f01000db:	74 f2                	je     f01000cf <cons_intr+0x25>
		cons.buf[cons.wpos++] = c;
f01000dd:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f01000e4:	8d 51 01             	lea    0x1(%ecx),%edx
f01000e7:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01000ea:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01000ed:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01000f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01000f8:	0f 44 d0             	cmove  %eax,%edx
f01000fb:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
f0100102:	eb cb                	jmp    f01000cf <cons_intr+0x25>
	}
}
f0100104:	83 c4 1c             	add    $0x1c,%esp
f0100107:	5b                   	pop    %ebx
f0100108:	5e                   	pop    %esi
f0100109:	5f                   	pop    %edi
f010010a:	5d                   	pop    %ebp
f010010b:	c3                   	ret    

f010010c <kbd_proc_data>:
{
f010010c:	f3 0f 1e fb          	endbr32 
f0100110:	55                   	push   %ebp
f0100111:	89 e5                	mov    %esp,%ebp
f0100113:	56                   	push   %esi
f0100114:	53                   	push   %ebx
f0100115:	e8 6e ff ff ff       	call   f0100088 <__x86.get_pc_thunk.bx>
f010011a:	81 c3 e6 f1 00 00    	add    $0xf1e6,%ebx
f0100120:	ba 64 00 00 00       	mov    $0x64,%edx
f0100125:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100126:	a8 01                	test   $0x1,%al
f0100128:	0f 84 fb 00 00 00    	je     f0100229 <kbd_proc_data+0x11d>
	if (stat & KBS_TERR)
f010012e:	a8 20                	test   $0x20,%al
f0100130:	0f 85 fa 00 00 00    	jne    f0100230 <kbd_proc_data+0x124>
f0100136:	ba 60 00 00 00       	mov    $0x60,%edx
f010013b:	ec                   	in     (%dx),%al
f010013c:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f010013e:	3c e0                	cmp    $0xe0,%al
f0100140:	74 64                	je     f01001a6 <kbd_proc_data+0x9a>
	} else if (data & 0x80) {
f0100142:	84 c0                	test   %al,%al
f0100144:	78 75                	js     f01001bb <kbd_proc_data+0xaf>
	} else if (shift & E0ESC) {
f0100146:	8b 8b 40 1d 00 00    	mov    0x1d40(%ebx),%ecx
f010014c:	f6 c1 40             	test   $0x40,%cl
f010014f:	74 0e                	je     f010015f <kbd_proc_data+0x53>
		data |= 0x80;
f0100151:	83 c8 80             	or     $0xffffff80,%eax
f0100154:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100156:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100159:	89 8b 40 1d 00 00    	mov    %ecx,0x1d40(%ebx)
	shift |= shiftcode[data];
f010015f:	0f b6 d2             	movzbl %dl,%edx
f0100162:	0f b6 84 13 20 22 ff 	movzbl -0xdde0(%ebx,%edx,1),%eax
f0100169:	ff 
f010016a:	0b 83 40 1d 00 00    	or     0x1d40(%ebx),%eax
	shift ^= togglecode[data];
f0100170:	0f b6 8c 13 20 21 ff 	movzbl -0xdee0(%ebx,%edx,1),%ecx
f0100177:	ff 
f0100178:	31 c8                	xor    %ecx,%eax
f010017a:	89 83 40 1d 00 00    	mov    %eax,0x1d40(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100180:	89 c1                	mov    %eax,%ecx
f0100182:	83 e1 03             	and    $0x3,%ecx
f0100185:	8b 8c 8b 00 1d 00 00 	mov    0x1d00(%ebx,%ecx,4),%ecx
f010018c:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100190:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f0100193:	a8 08                	test   $0x8,%al
f0100195:	74 65                	je     f01001fc <kbd_proc_data+0xf0>
		if ('a' <= c && c <= 'z')
f0100197:	89 f2                	mov    %esi,%edx
f0100199:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f010019c:	83 f9 19             	cmp    $0x19,%ecx
f010019f:	77 4f                	ja     f01001f0 <kbd_proc_data+0xe4>
			c += 'A' - 'a';
f01001a1:	83 ee 20             	sub    $0x20,%esi
f01001a4:	eb 0c                	jmp    f01001b2 <kbd_proc_data+0xa6>
		shift |= E0ESC;
f01001a6:	83 8b 40 1d 00 00 40 	orl    $0x40,0x1d40(%ebx)
		return 0;
f01001ad:	be 00 00 00 00       	mov    $0x0,%esi
}
f01001b2:	89 f0                	mov    %esi,%eax
f01001b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b7:	5b                   	pop    %ebx
f01001b8:	5e                   	pop    %esi
f01001b9:	5d                   	pop    %ebp
f01001ba:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01001bb:	8b 8b 40 1d 00 00    	mov    0x1d40(%ebx),%ecx
f01001c1:	89 ce                	mov    %ecx,%esi
f01001c3:	83 e6 40             	and    $0x40,%esi
f01001c6:	83 e0 7f             	and    $0x7f,%eax
f01001c9:	85 f6                	test   %esi,%esi
f01001cb:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001ce:	0f b6 d2             	movzbl %dl,%edx
f01001d1:	0f b6 84 13 20 22 ff 	movzbl -0xdde0(%ebx,%edx,1),%eax
f01001d8:	ff 
f01001d9:	83 c8 40             	or     $0x40,%eax
f01001dc:	0f b6 c0             	movzbl %al,%eax
f01001df:	f7 d0                	not    %eax
f01001e1:	21 c8                	and    %ecx,%eax
f01001e3:	89 83 40 1d 00 00    	mov    %eax,0x1d40(%ebx)
		return 0;
f01001e9:	be 00 00 00 00       	mov    $0x0,%esi
f01001ee:	eb c2                	jmp    f01001b2 <kbd_proc_data+0xa6>
		else if ('A' <= c && c <= 'Z')
f01001f0:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01001f3:	8d 4e 20             	lea    0x20(%esi),%ecx
f01001f6:	83 fa 1a             	cmp    $0x1a,%edx
f01001f9:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01001fc:	f7 d0                	not    %eax
f01001fe:	a8 06                	test   $0x6,%al
f0100200:	75 b0                	jne    f01001b2 <kbd_proc_data+0xa6>
f0100202:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100208:	75 a8                	jne    f01001b2 <kbd_proc_data+0xa6>
		cprintf("Rebooting!\n");
f010020a:	83 ec 0c             	sub    $0xc,%esp
f010020d:	8d 83 eb 20 ff ff    	lea    -0xdf15(%ebx),%eax
f0100213:	50                   	push   %eax
f0100214:	e8 8c 04 00 00       	call   f01006a5 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100219:	b8 03 00 00 00       	mov    $0x3,%eax
f010021e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100223:	ee                   	out    %al,(%dx)
}
f0100224:	83 c4 10             	add    $0x10,%esp
f0100227:	eb 89                	jmp    f01001b2 <kbd_proc_data+0xa6>
		return -1;
f0100229:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010022e:	eb 82                	jmp    f01001b2 <kbd_proc_data+0xa6>
		return -1;
f0100230:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100235:	e9 78 ff ff ff       	jmp    f01001b2 <kbd_proc_data+0xa6>

f010023a <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010023a:	55                   	push   %ebp
f010023b:	89 e5                	mov    %esp,%ebp
f010023d:	57                   	push   %edi
f010023e:	56                   	push   %esi
f010023f:	53                   	push   %ebx
f0100240:	83 ec 1c             	sub    $0x1c,%esp
f0100243:	e8 40 fe ff ff       	call   f0100088 <__x86.get_pc_thunk.bx>
f0100248:	81 c3 b8 f0 00 00    	add    $0xf0b8,%ebx
f010024e:	89 c7                	mov    %eax,%edi
	for (i = 0;
f0100250:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100255:	b9 84 00 00 00       	mov    $0x84,%ecx
f010025a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010025f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100260:	a8 20                	test   $0x20,%al
f0100262:	75 13                	jne    f0100277 <cons_putc+0x3d>
f0100264:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010026a:	7f 0b                	jg     f0100277 <cons_putc+0x3d>
f010026c:	89 ca                	mov    %ecx,%edx
f010026e:	ec                   	in     (%dx),%al
f010026f:	ec                   	in     (%dx),%al
f0100270:	ec                   	in     (%dx),%al
f0100271:	ec                   	in     (%dx),%al
	     i++)
f0100272:	83 c6 01             	add    $0x1,%esi
f0100275:	eb e3                	jmp    f010025a <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f0100277:	89 f8                	mov    %edi,%eax
f0100279:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010027c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100281:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100282:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100287:	b9 84 00 00 00       	mov    $0x84,%ecx
f010028c:	ba 79 03 00 00       	mov    $0x379,%edx
f0100291:	ec                   	in     (%dx),%al
f0100292:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100298:	7f 0f                	jg     f01002a9 <cons_putc+0x6f>
f010029a:	84 c0                	test   %al,%al
f010029c:	78 0b                	js     f01002a9 <cons_putc+0x6f>
f010029e:	89 ca                	mov    %ecx,%edx
f01002a0:	ec                   	in     (%dx),%al
f01002a1:	ec                   	in     (%dx),%al
f01002a2:	ec                   	in     (%dx),%al
f01002a3:	ec                   	in     (%dx),%al
f01002a4:	83 c6 01             	add    $0x1,%esi
f01002a7:	eb e3                	jmp    f010028c <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002a9:	ba 78 03 00 00       	mov    $0x378,%edx
f01002ae:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01002b2:	ee                   	out    %al,(%dx)
f01002b3:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01002b8:	b8 0d 00 00 00       	mov    $0xd,%eax
f01002bd:	ee                   	out    %al,(%dx)
f01002be:	b8 08 00 00 00       	mov    $0x8,%eax
f01002c3:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01002c4:	89 f8                	mov    %edi,%eax
f01002c6:	80 cc 07             	or     $0x7,%ah
f01002c9:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01002cf:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f01002d2:	89 f8                	mov    %edi,%eax
f01002d4:	0f b6 c0             	movzbl %al,%eax
f01002d7:	89 f9                	mov    %edi,%ecx
f01002d9:	80 f9 0a             	cmp    $0xa,%cl
f01002dc:	0f 84 e2 00 00 00    	je     f01003c4 <cons_putc+0x18a>
f01002e2:	83 f8 0a             	cmp    $0xa,%eax
f01002e5:	7f 46                	jg     f010032d <cons_putc+0xf3>
f01002e7:	83 f8 08             	cmp    $0x8,%eax
f01002ea:	0f 84 a8 00 00 00    	je     f0100398 <cons_putc+0x15e>
f01002f0:	83 f8 09             	cmp    $0x9,%eax
f01002f3:	0f 85 d8 00 00 00    	jne    f01003d1 <cons_putc+0x197>
		cons_putc(' ');
f01002f9:	b8 20 00 00 00       	mov    $0x20,%eax
f01002fe:	e8 37 ff ff ff       	call   f010023a <cons_putc>
		cons_putc(' ');
f0100303:	b8 20 00 00 00       	mov    $0x20,%eax
f0100308:	e8 2d ff ff ff       	call   f010023a <cons_putc>
		cons_putc(' ');
f010030d:	b8 20 00 00 00       	mov    $0x20,%eax
f0100312:	e8 23 ff ff ff       	call   f010023a <cons_putc>
		cons_putc(' ');
f0100317:	b8 20 00 00 00       	mov    $0x20,%eax
f010031c:	e8 19 ff ff ff       	call   f010023a <cons_putc>
		cons_putc(' ');
f0100321:	b8 20 00 00 00       	mov    $0x20,%eax
f0100326:	e8 0f ff ff ff       	call   f010023a <cons_putc>
		break;
f010032b:	eb 26                	jmp    f0100353 <cons_putc+0x119>
	switch (c & 0xff) {
f010032d:	83 f8 0d             	cmp    $0xd,%eax
f0100330:	0f 85 9b 00 00 00    	jne    f01003d1 <cons_putc+0x197>
		crt_pos -= (crt_pos % CRT_COLS);
f0100336:	0f b7 83 68 1f 00 00 	movzwl 0x1f68(%ebx),%eax
f010033d:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100343:	c1 e8 16             	shr    $0x16,%eax
f0100346:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100349:	c1 e0 04             	shl    $0x4,%eax
f010034c:	66 89 83 68 1f 00 00 	mov    %ax,0x1f68(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100353:	66 81 bb 68 1f 00 00 	cmpw   $0x7cf,0x1f68(%ebx)
f010035a:	cf 07 
f010035c:	0f 87 92 00 00 00    	ja     f01003f4 <cons_putc+0x1ba>
	outb(addr_6845, 14);
f0100362:	8b 8b 70 1f 00 00    	mov    0x1f70(%ebx),%ecx
f0100368:	b8 0e 00 00 00       	mov    $0xe,%eax
f010036d:	89 ca                	mov    %ecx,%edx
f010036f:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100370:	0f b7 9b 68 1f 00 00 	movzwl 0x1f68(%ebx),%ebx
f0100377:	8d 71 01             	lea    0x1(%ecx),%esi
f010037a:	89 d8                	mov    %ebx,%eax
f010037c:	66 c1 e8 08          	shr    $0x8,%ax
f0100380:	89 f2                	mov    %esi,%edx
f0100382:	ee                   	out    %al,(%dx)
f0100383:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100388:	89 ca                	mov    %ecx,%edx
f010038a:	ee                   	out    %al,(%dx)
f010038b:	89 d8                	mov    %ebx,%eax
f010038d:	89 f2                	mov    %esi,%edx
f010038f:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100390:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100393:	5b                   	pop    %ebx
f0100394:	5e                   	pop    %esi
f0100395:	5f                   	pop    %edi
f0100396:	5d                   	pop    %ebp
f0100397:	c3                   	ret    
		if (crt_pos > 0) {
f0100398:	0f b7 83 68 1f 00 00 	movzwl 0x1f68(%ebx),%eax
f010039f:	66 85 c0             	test   %ax,%ax
f01003a2:	74 be                	je     f0100362 <cons_putc+0x128>
			crt_pos--;
f01003a4:	83 e8 01             	sub    $0x1,%eax
f01003a7:	66 89 83 68 1f 00 00 	mov    %ax,0x1f68(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003ae:	0f b7 c0             	movzwl %ax,%eax
f01003b1:	89 fa                	mov    %edi,%edx
f01003b3:	b2 00                	mov    $0x0,%dl
f01003b5:	83 ca 20             	or     $0x20,%edx
f01003b8:	8b 8b 6c 1f 00 00    	mov    0x1f6c(%ebx),%ecx
f01003be:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01003c2:	eb 8f                	jmp    f0100353 <cons_putc+0x119>
		crt_pos += CRT_COLS;
f01003c4:	66 83 83 68 1f 00 00 	addw   $0x50,0x1f68(%ebx)
f01003cb:	50 
f01003cc:	e9 65 ff ff ff       	jmp    f0100336 <cons_putc+0xfc>
		crt_buf[crt_pos++] = c;		/* write the character */
f01003d1:	0f b7 83 68 1f 00 00 	movzwl 0x1f68(%ebx),%eax
f01003d8:	8d 50 01             	lea    0x1(%eax),%edx
f01003db:	66 89 93 68 1f 00 00 	mov    %dx,0x1f68(%ebx)
f01003e2:	0f b7 c0             	movzwl %ax,%eax
f01003e5:	8b 93 6c 1f 00 00    	mov    0x1f6c(%ebx),%edx
f01003eb:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f01003ef:	e9 5f ff ff ff       	jmp    f0100353 <cons_putc+0x119>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01003f4:	8b 83 6c 1f 00 00    	mov    0x1f6c(%ebx),%eax
f01003fa:	83 ec 04             	sub    $0x4,%esp
f01003fd:	68 00 0f 00 00       	push   $0xf00
f0100402:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100408:	52                   	push   %edx
f0100409:	50                   	push   %eax
f010040a:	e8 b2 0b 00 00       	call   f0100fc1 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010040f:	8b 93 6c 1f 00 00    	mov    0x1f6c(%ebx),%edx
f0100415:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010041b:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100421:	83 c4 10             	add    $0x10,%esp
f0100424:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100429:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010042c:	39 d0                	cmp    %edx,%eax
f010042e:	75 f4                	jne    f0100424 <cons_putc+0x1ea>
		crt_pos -= CRT_COLS;
f0100430:	66 83 ab 68 1f 00 00 	subw   $0x50,0x1f68(%ebx)
f0100437:	50 
f0100438:	e9 25 ff ff ff       	jmp    f0100362 <cons_putc+0x128>

f010043d <serial_intr>:
{
f010043d:	f3 0f 1e fb          	endbr32 
f0100441:	e8 f6 01 00 00       	call   f010063c <__x86.get_pc_thunk.ax>
f0100446:	05 ba ee 00 00       	add    $0xeeba,%eax
	if (serial_exists)
f010044b:	80 b8 74 1f 00 00 00 	cmpb   $0x0,0x1f74(%eax)
f0100452:	75 01                	jne    f0100455 <serial_intr+0x18>
f0100454:	c3                   	ret    
{
f0100455:	55                   	push   %ebp
f0100456:	89 e5                	mov    %esp,%ebp
f0100458:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010045b:	8d 80 8c 0d ff ff    	lea    -0xf274(%eax),%eax
f0100461:	e8 44 fc ff ff       	call   f01000aa <cons_intr>
}
f0100466:	c9                   	leave  
f0100467:	c3                   	ret    

f0100468 <kbd_intr>:
{
f0100468:	f3 0f 1e fb          	endbr32 
f010046c:	55                   	push   %ebp
f010046d:	89 e5                	mov    %esp,%ebp
f010046f:	83 ec 08             	sub    $0x8,%esp
f0100472:	e8 c5 01 00 00       	call   f010063c <__x86.get_pc_thunk.ax>
f0100477:	05 89 ee 00 00       	add    $0xee89,%eax
	cons_intr(kbd_proc_data);
f010047c:	8d 80 0c 0e ff ff    	lea    -0xf1f4(%eax),%eax
f0100482:	e8 23 fc ff ff       	call   f01000aa <cons_intr>
}
f0100487:	c9                   	leave  
f0100488:	c3                   	ret    

f0100489 <cons_getc>:
{
f0100489:	f3 0f 1e fb          	endbr32 
f010048d:	55                   	push   %ebp
f010048e:	89 e5                	mov    %esp,%ebp
f0100490:	53                   	push   %ebx
f0100491:	83 ec 04             	sub    $0x4,%esp
f0100494:	e8 ef fb ff ff       	call   f0100088 <__x86.get_pc_thunk.bx>
f0100499:	81 c3 67 ee 00 00    	add    $0xee67,%ebx
	serial_intr();
f010049f:	e8 99 ff ff ff       	call   f010043d <serial_intr>
	kbd_intr();
f01004a4:	e8 bf ff ff ff       	call   f0100468 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01004a9:	8b 83 60 1f 00 00    	mov    0x1f60(%ebx),%eax
	return 0;
f01004af:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01004b4:	3b 83 64 1f 00 00    	cmp    0x1f64(%ebx),%eax
f01004ba:	74 1f                	je     f01004db <cons_getc+0x52>
		c = cons.buf[cons.rpos++];
f01004bc:	8d 48 01             	lea    0x1(%eax),%ecx
f01004bf:	0f b6 94 03 60 1d 00 	movzbl 0x1d60(%ebx,%eax,1),%edx
f01004c6:	00 
			cons.rpos = 0;
f01004c7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01004cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01004d2:	0f 44 c8             	cmove  %eax,%ecx
f01004d5:	89 8b 60 1f 00 00    	mov    %ecx,0x1f60(%ebx)
}
f01004db:	89 d0                	mov    %edx,%eax
f01004dd:	83 c4 04             	add    $0x4,%esp
f01004e0:	5b                   	pop    %ebx
f01004e1:	5d                   	pop    %ebp
f01004e2:	c3                   	ret    

f01004e3 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01004e3:	f3 0f 1e fb          	endbr32 
f01004e7:	55                   	push   %ebp
f01004e8:	89 e5                	mov    %esp,%ebp
f01004ea:	57                   	push   %edi
f01004eb:	56                   	push   %esi
f01004ec:	53                   	push   %ebx
f01004ed:	83 ec 1c             	sub    $0x1c,%esp
f01004f0:	e8 93 fb ff ff       	call   f0100088 <__x86.get_pc_thunk.bx>
f01004f5:	81 c3 0b ee 00 00    	add    $0xee0b,%ebx
	was = *cp;
f01004fb:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100502:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100509:	5a a5 
	if (*cp != 0xA55A) {
f010050b:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100512:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100516:	0f 84 bc 00 00 00    	je     f01005d8 <cons_init+0xf5>
		addr_6845 = MONO_BASE;
f010051c:	c7 83 70 1f 00 00 b4 	movl   $0x3b4,0x1f70(%ebx)
f0100523:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100526:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f010052d:	8b bb 70 1f 00 00    	mov    0x1f70(%ebx),%edi
f0100533:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100538:	89 fa                	mov    %edi,%edx
f010053a:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010053b:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010053e:	89 ca                	mov    %ecx,%edx
f0100540:	ec                   	in     (%dx),%al
f0100541:	0f b6 f0             	movzbl %al,%esi
f0100544:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100547:	b8 0f 00 00 00       	mov    $0xf,%eax
f010054c:	89 fa                	mov    %edi,%edx
f010054e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010054f:	89 ca                	mov    %ecx,%edx
f0100551:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100555:	89 bb 6c 1f 00 00    	mov    %edi,0x1f6c(%ebx)
	pos |= inb(addr_6845 + 1);
f010055b:	0f b6 c0             	movzbl %al,%eax
f010055e:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100560:	66 89 b3 68 1f 00 00 	mov    %si,0x1f68(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100567:	b9 00 00 00 00       	mov    $0x0,%ecx
f010056c:	89 c8                	mov    %ecx,%eax
f010056e:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100573:	ee                   	out    %al,(%dx)
f0100574:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100579:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010057e:	89 fa                	mov    %edi,%edx
f0100580:	ee                   	out    %al,(%dx)
f0100581:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100586:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010058b:	ee                   	out    %al,(%dx)
f010058c:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100591:	89 c8                	mov    %ecx,%eax
f0100593:	89 f2                	mov    %esi,%edx
f0100595:	ee                   	out    %al,(%dx)
f0100596:	b8 03 00 00 00       	mov    $0x3,%eax
f010059b:	89 fa                	mov    %edi,%edx
f010059d:	ee                   	out    %al,(%dx)
f010059e:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005a3:	89 c8                	mov    %ecx,%eax
f01005a5:	ee                   	out    %al,(%dx)
f01005a6:	b8 01 00 00 00       	mov    $0x1,%eax
f01005ab:	89 f2                	mov    %esi,%edx
f01005ad:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ae:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005b3:	ec                   	in     (%dx),%al
f01005b4:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005b6:	3c ff                	cmp    $0xff,%al
f01005b8:	0f 95 83 74 1f 00 00 	setne  0x1f74(%ebx)
f01005bf:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01005c4:	ec                   	in     (%dx),%al
f01005c5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01005ca:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005cb:	80 f9 ff             	cmp    $0xff,%cl
f01005ce:	74 25                	je     f01005f5 <cons_init+0x112>
		cprintf("Serial port does not exist!\n");
}
f01005d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005d3:	5b                   	pop    %ebx
f01005d4:	5e                   	pop    %esi
f01005d5:	5f                   	pop    %edi
f01005d6:	5d                   	pop    %ebp
f01005d7:	c3                   	ret    
		*cp = was;
f01005d8:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005df:	c7 83 70 1f 00 00 d4 	movl   $0x3d4,0x1f70(%ebx)
f01005e6:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005e9:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01005f0:	e9 38 ff ff ff       	jmp    f010052d <cons_init+0x4a>
		cprintf("Serial port does not exist!\n");
f01005f5:	83 ec 0c             	sub    $0xc,%esp
f01005f8:	8d 83 f7 20 ff ff    	lea    -0xdf09(%ebx),%eax
f01005fe:	50                   	push   %eax
f01005ff:	e8 a1 00 00 00       	call   f01006a5 <cprintf>
f0100604:	83 c4 10             	add    $0x10,%esp
}
f0100607:	eb c7                	jmp    f01005d0 <cons_init+0xed>

f0100609 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100609:	f3 0f 1e fb          	endbr32 
f010060d:	55                   	push   %ebp
f010060e:	89 e5                	mov    %esp,%ebp
f0100610:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100613:	8b 45 08             	mov    0x8(%ebp),%eax
f0100616:	e8 1f fc ff ff       	call   f010023a <cons_putc>
}
f010061b:	c9                   	leave  
f010061c:	c3                   	ret    

f010061d <getchar>:

int
getchar(void)
{
f010061d:	f3 0f 1e fb          	endbr32 
f0100621:	55                   	push   %ebp
f0100622:	89 e5                	mov    %esp,%ebp
f0100624:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100627:	e8 5d fe ff ff       	call   f0100489 <cons_getc>
f010062c:	85 c0                	test   %eax,%eax
f010062e:	74 f7                	je     f0100627 <getchar+0xa>
		/* do nothing */;
	return c;
}
f0100630:	c9                   	leave  
f0100631:	c3                   	ret    

f0100632 <iscons>:

int
iscons(int fdnum)
{
f0100632:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f0100636:	b8 01 00 00 00       	mov    $0x1,%eax
f010063b:	c3                   	ret    

f010063c <__x86.get_pc_thunk.ax>:
f010063c:	8b 04 24             	mov    (%esp),%eax
f010063f:	c3                   	ret    

f0100640 <__x86.get_pc_thunk.si>:
f0100640:	8b 34 24             	mov    (%esp),%esi
f0100643:	c3                   	ret    

f0100644 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100644:	f3 0f 1e fb          	endbr32 
f0100648:	55                   	push   %ebp
f0100649:	89 e5                	mov    %esp,%ebp
f010064b:	53                   	push   %ebx
f010064c:	83 ec 10             	sub    $0x10,%esp
f010064f:	e8 34 fa ff ff       	call   f0100088 <__x86.get_pc_thunk.bx>
f0100654:	81 c3 ac ec 00 00    	add    $0xecac,%ebx
	cputchar(ch);
f010065a:	ff 75 08             	pushl  0x8(%ebp)
f010065d:	e8 a7 ff ff ff       	call   f0100609 <cputchar>
	*cnt++;
}
f0100662:	83 c4 10             	add    $0x10,%esp
f0100665:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100668:	c9                   	leave  
f0100669:	c3                   	ret    

f010066a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010066a:	f3 0f 1e fb          	endbr32 
f010066e:	55                   	push   %ebp
f010066f:	89 e5                	mov    %esp,%ebp
f0100671:	53                   	push   %ebx
f0100672:	83 ec 14             	sub    $0x14,%esp
f0100675:	e8 0e fa ff ff       	call   f0100088 <__x86.get_pc_thunk.bx>
f010067a:	81 c3 86 ec 00 00    	add    $0xec86,%ebx
	int cnt = 0;
f0100680:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100687:	ff 75 0c             	pushl  0xc(%ebp)
f010068a:	ff 75 08             	pushl  0x8(%ebp)
f010068d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100690:	50                   	push   %eax
f0100691:	8d 83 44 13 ff ff    	lea    -0xecbc(%ebx),%eax
f0100697:	50                   	push   %eax
f0100698:	e8 20 01 00 00       	call   f01007bd <vprintfmt>
	return cnt;
}
f010069d:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01006a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01006a3:	c9                   	leave  
f01006a4:	c3                   	ret    

f01006a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01006a5:	f3 0f 1e fb          	endbr32 
f01006a9:	55                   	push   %ebp
f01006aa:	89 e5                	mov    %esp,%ebp
f01006ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01006af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01006b2:	50                   	push   %eax
f01006b3:	ff 75 08             	pushl  0x8(%ebp)
f01006b6:	e8 af ff ff ff       	call   f010066a <vcprintf>
	va_end(ap);

	return cnt;
}
f01006bb:	c9                   	leave  
f01006bc:	c3                   	ret    

f01006bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01006bd:	55                   	push   %ebp
f01006be:	89 e5                	mov    %esp,%ebp
f01006c0:	57                   	push   %edi
f01006c1:	56                   	push   %esi
f01006c2:	53                   	push   %ebx
f01006c3:	83 ec 2c             	sub    $0x2c,%esp
f01006c6:	e8 f0 05 00 00       	call   f0100cbb <__x86.get_pc_thunk.cx>
f01006cb:	81 c1 35 ec 00 00    	add    $0xec35,%ecx
f01006d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01006d4:	89 c7                	mov    %eax,%edi
f01006d6:	89 d6                	mov    %edx,%esi
f01006d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01006db:	8b 55 0c             	mov    0xc(%ebp),%edx
f01006de:	89 d1                	mov    %edx,%ecx
f01006e0:	89 c2                	mov    %eax,%edx
f01006e2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01006e5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01006e8:	8b 45 10             	mov    0x10(%ebp),%eax
f01006eb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01006ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01006f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01006f8:	39 c2                	cmp    %eax,%edx
f01006fa:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f01006fd:	72 41                	jb     f0100740 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01006ff:	83 ec 0c             	sub    $0xc,%esp
f0100702:	ff 75 18             	pushl  0x18(%ebp)
f0100705:	83 eb 01             	sub    $0x1,%ebx
f0100708:	53                   	push   %ebx
f0100709:	50                   	push   %eax
f010070a:	83 ec 08             	sub    $0x8,%esp
f010070d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100710:	ff 75 e0             	pushl  -0x20(%ebp)
f0100713:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100716:	ff 75 d0             	pushl  -0x30(%ebp)
f0100719:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010071c:	e8 5f 0a 00 00       	call   f0101180 <__udivdi3>
f0100721:	83 c4 18             	add    $0x18,%esp
f0100724:	52                   	push   %edx
f0100725:	50                   	push   %eax
f0100726:	89 f2                	mov    %esi,%edx
f0100728:	89 f8                	mov    %edi,%eax
f010072a:	e8 8e ff ff ff       	call   f01006bd <printnum>
f010072f:	83 c4 20             	add    $0x20,%esp
f0100732:	eb 13                	jmp    f0100747 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100734:	83 ec 08             	sub    $0x8,%esp
f0100737:	56                   	push   %esi
f0100738:	ff 75 18             	pushl  0x18(%ebp)
f010073b:	ff d7                	call   *%edi
f010073d:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100740:	83 eb 01             	sub    $0x1,%ebx
f0100743:	85 db                	test   %ebx,%ebx
f0100745:	7f ed                	jg     f0100734 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100747:	83 ec 08             	sub    $0x8,%esp
f010074a:	56                   	push   %esi
f010074b:	83 ec 04             	sub    $0x4,%esp
f010074e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100751:	ff 75 e0             	pushl  -0x20(%ebp)
f0100754:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100757:	ff 75 d0             	pushl  -0x30(%ebp)
f010075a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010075d:	e8 2e 0b 00 00       	call   f0101290 <__umoddi3>
f0100762:	83 c4 14             	add    $0x14,%esp
f0100765:	0f be 84 03 20 23 ff 	movsbl -0xdce0(%ebx,%eax,1),%eax
f010076c:	ff 
f010076d:	50                   	push   %eax
f010076e:	ff d7                	call   *%edi
}
f0100770:	83 c4 10             	add    $0x10,%esp
f0100773:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100776:	5b                   	pop    %ebx
f0100777:	5e                   	pop    %esi
f0100778:	5f                   	pop    %edi
f0100779:	5d                   	pop    %ebp
f010077a:	c3                   	ret    

f010077b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010077b:	f3 0f 1e fb          	endbr32 
f010077f:	55                   	push   %ebp
f0100780:	89 e5                	mov    %esp,%ebp
f0100782:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100785:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100789:	8b 10                	mov    (%eax),%edx
f010078b:	3b 50 04             	cmp    0x4(%eax),%edx
f010078e:	73 0a                	jae    f010079a <sprintputch+0x1f>
		*b->buf++ = ch;
f0100790:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100793:	89 08                	mov    %ecx,(%eax)
f0100795:	8b 45 08             	mov    0x8(%ebp),%eax
f0100798:	88 02                	mov    %al,(%edx)
}
f010079a:	5d                   	pop    %ebp
f010079b:	c3                   	ret    

f010079c <printfmt>:
{
f010079c:	f3 0f 1e fb          	endbr32 
f01007a0:	55                   	push   %ebp
f01007a1:	89 e5                	mov    %esp,%ebp
f01007a3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01007a6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01007a9:	50                   	push   %eax
f01007aa:	ff 75 10             	pushl  0x10(%ebp)
f01007ad:	ff 75 0c             	pushl  0xc(%ebp)
f01007b0:	ff 75 08             	pushl  0x8(%ebp)
f01007b3:	e8 05 00 00 00       	call   f01007bd <vprintfmt>
}
f01007b8:	83 c4 10             	add    $0x10,%esp
f01007bb:	c9                   	leave  
f01007bc:	c3                   	ret    

f01007bd <vprintfmt>:
{
f01007bd:	f3 0f 1e fb          	endbr32 
f01007c1:	55                   	push   %ebp
f01007c2:	89 e5                	mov    %esp,%ebp
f01007c4:	57                   	push   %edi
f01007c5:	56                   	push   %esi
f01007c6:	53                   	push   %ebx
f01007c7:	83 ec 3c             	sub    $0x3c,%esp
f01007ca:	e8 6d fe ff ff       	call   f010063c <__x86.get_pc_thunk.ax>
f01007cf:	05 31 eb 00 00       	add    $0xeb31,%eax
f01007d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01007d7:	8b 75 08             	mov    0x8(%ebp),%esi
f01007da:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01007dd:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01007e0:	8d 80 10 1d 00 00    	lea    0x1d10(%eax),%eax
f01007e6:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01007e9:	e9 95 03 00 00       	jmp    f0100b83 <.L25+0x48>
		padc = ' ';
f01007ee:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f01007f2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f01007f9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0100800:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
f0100807:	b9 00 00 00 00       	mov    $0x0,%ecx
f010080c:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f010080f:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100812:	8d 43 01             	lea    0x1(%ebx),%eax
f0100815:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100818:	0f b6 13             	movzbl (%ebx),%edx
f010081b:	8d 42 dd             	lea    -0x23(%edx),%eax
f010081e:	3c 55                	cmp    $0x55,%al
f0100820:	0f 87 e9 03 00 00    	ja     f0100c0f <.L20>
f0100826:	0f b6 c0             	movzbl %al,%eax
f0100829:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010082c:	89 ce                	mov    %ecx,%esi
f010082e:	03 b4 81 b0 23 ff ff 	add    -0xdc50(%ecx,%eax,4),%esi
f0100835:	3e ff e6             	notrack jmp *%esi

f0100838 <.L66>:
f0100838:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f010083b:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f010083f:	eb d1                	jmp    f0100812 <vprintfmt+0x55>

f0100841 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f0100841:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100844:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f0100848:	eb c8                	jmp    f0100812 <vprintfmt+0x55>

f010084a <.L31>:
f010084a:	0f b6 d2             	movzbl %dl,%edx
f010084d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f0100850:	b8 00 00 00 00       	mov    $0x0,%eax
f0100855:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f0100858:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010085b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010085f:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f0100862:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0100865:	83 f9 09             	cmp    $0x9,%ecx
f0100868:	77 58                	ja     f01008c2 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f010086a:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f010086d:	eb e9                	jmp    f0100858 <.L31+0xe>

f010086f <.L34>:
			precision = va_arg(ap, int);
f010086f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100872:	8b 00                	mov    (%eax),%eax
f0100874:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100877:	8b 45 14             	mov    0x14(%ebp),%eax
f010087a:	8d 40 04             	lea    0x4(%eax),%eax
f010087d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100880:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f0100883:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100887:	79 89                	jns    f0100812 <vprintfmt+0x55>
				width = precision, precision = -1;
f0100889:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010088c:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010088f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f0100896:	e9 77 ff ff ff       	jmp    f0100812 <vprintfmt+0x55>

f010089b <.L33>:
f010089b:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010089e:	85 c0                	test   %eax,%eax
f01008a0:	ba 00 00 00 00       	mov    $0x0,%edx
f01008a5:	0f 49 d0             	cmovns %eax,%edx
f01008a8:	89 55 d0             	mov    %edx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01008ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01008ae:	e9 5f ff ff ff       	jmp    f0100812 <vprintfmt+0x55>

f01008b3 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f01008b3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f01008b6:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01008bd:	e9 50 ff ff ff       	jmp    f0100812 <vprintfmt+0x55>
f01008c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01008c5:	89 75 08             	mov    %esi,0x8(%ebp)
f01008c8:	eb b9                	jmp    f0100883 <.L34+0x14>

f01008ca <.L27>:
			lflag++;
f01008ca:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01008ce:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f01008d1:	e9 3c ff ff ff       	jmp    f0100812 <vprintfmt+0x55>

f01008d6 <.L30>:
f01008d6:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f01008d9:	8b 45 14             	mov    0x14(%ebp),%eax
f01008dc:	8d 58 04             	lea    0x4(%eax),%ebx
f01008df:	83 ec 08             	sub    $0x8,%esp
f01008e2:	57                   	push   %edi
f01008e3:	ff 30                	pushl  (%eax)
f01008e5:	ff d6                	call   *%esi
			break;
f01008e7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01008ea:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f01008ed:	e9 8e 02 00 00       	jmp    f0100b80 <.L25+0x45>

f01008f2 <.L28>:
f01008f2:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f01008f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01008f8:	8d 58 04             	lea    0x4(%eax),%ebx
f01008fb:	8b 00                	mov    (%eax),%eax
f01008fd:	99                   	cltd   
f01008fe:	31 d0                	xor    %edx,%eax
f0100900:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100902:	83 f8 06             	cmp    $0x6,%eax
f0100905:	7f 27                	jg     f010092e <.L28+0x3c>
f0100907:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f010090a:	8b 14 82             	mov    (%edx,%eax,4),%edx
f010090d:	85 d2                	test   %edx,%edx
f010090f:	74 1d                	je     f010092e <.L28+0x3c>
				printfmt(putch, putdat, "%s", p);
f0100911:	52                   	push   %edx
f0100912:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100915:	8d 80 41 23 ff ff    	lea    -0xdcbf(%eax),%eax
f010091b:	50                   	push   %eax
f010091c:	57                   	push   %edi
f010091d:	56                   	push   %esi
f010091e:	e8 79 fe ff ff       	call   f010079c <printfmt>
f0100923:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100926:	89 5d 14             	mov    %ebx,0x14(%ebp)
f0100929:	e9 52 02 00 00       	jmp    f0100b80 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f010092e:	50                   	push   %eax
f010092f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100932:	8d 80 38 23 ff ff    	lea    -0xdcc8(%eax),%eax
f0100938:	50                   	push   %eax
f0100939:	57                   	push   %edi
f010093a:	56                   	push   %esi
f010093b:	e8 5c fe ff ff       	call   f010079c <printfmt>
f0100940:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0100943:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0100946:	e9 35 02 00 00       	jmp    f0100b80 <.L25+0x45>

f010094b <.L24>:
f010094b:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f010094e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100951:	83 c0 04             	add    $0x4,%eax
f0100954:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0100957:	8b 45 14             	mov    0x14(%ebp),%eax
f010095a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f010095c:	85 d2                	test   %edx,%edx
f010095e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100961:	8d 80 31 23 ff ff    	lea    -0xdccf(%eax),%eax
f0100967:	0f 45 c2             	cmovne %edx,%eax
f010096a:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f010096d:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0100971:	7e 06                	jle    f0100979 <.L24+0x2e>
f0100973:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f0100977:	75 0d                	jne    f0100986 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100979:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010097c:	89 c3                	mov    %eax,%ebx
f010097e:	03 45 d0             	add    -0x30(%ebp),%eax
f0100981:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100984:	eb 58                	jmp    f01009de <.L24+0x93>
f0100986:	83 ec 08             	sub    $0x8,%esp
f0100989:	ff 75 d8             	pushl  -0x28(%ebp)
f010098c:	ff 75 c8             	pushl  -0x38(%ebp)
f010098f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100992:	e8 4d 04 00 00       	call   f0100de4 <strnlen>
f0100997:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010099a:	29 c2                	sub    %eax,%edx
f010099c:	89 55 bc             	mov    %edx,-0x44(%ebp)
f010099f:	83 c4 10             	add    $0x10,%esp
f01009a2:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f01009a4:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f01009a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01009ab:	85 db                	test   %ebx,%ebx
f01009ad:	7e 11                	jle    f01009c0 <.L24+0x75>
					putch(padc, putdat);
f01009af:	83 ec 08             	sub    $0x8,%esp
f01009b2:	57                   	push   %edi
f01009b3:	ff 75 d0             	pushl  -0x30(%ebp)
f01009b6:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01009b8:	83 eb 01             	sub    $0x1,%ebx
f01009bb:	83 c4 10             	add    $0x10,%esp
f01009be:	eb eb                	jmp    f01009ab <.L24+0x60>
f01009c0:	8b 55 bc             	mov    -0x44(%ebp),%edx
f01009c3:	85 d2                	test   %edx,%edx
f01009c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01009ca:	0f 49 c2             	cmovns %edx,%eax
f01009cd:	29 c2                	sub    %eax,%edx
f01009cf:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01009d2:	eb a5                	jmp    f0100979 <.L24+0x2e>
					putch(ch, putdat);
f01009d4:	83 ec 08             	sub    $0x8,%esp
f01009d7:	57                   	push   %edi
f01009d8:	52                   	push   %edx
f01009d9:	ff d6                	call   *%esi
f01009db:	83 c4 10             	add    $0x10,%esp
f01009de:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01009e1:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01009e3:	83 c3 01             	add    $0x1,%ebx
f01009e6:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f01009ea:	0f be d0             	movsbl %al,%edx
f01009ed:	85 d2                	test   %edx,%edx
f01009ef:	74 4b                	je     f0100a3c <.L24+0xf1>
f01009f1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01009f5:	78 06                	js     f01009fd <.L24+0xb2>
f01009f7:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01009fb:	78 1e                	js     f0100a1b <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f01009fd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100a01:	74 d1                	je     f01009d4 <.L24+0x89>
f0100a03:	0f be c0             	movsbl %al,%eax
f0100a06:	83 e8 20             	sub    $0x20,%eax
f0100a09:	83 f8 5e             	cmp    $0x5e,%eax
f0100a0c:	76 c6                	jbe    f01009d4 <.L24+0x89>
					putch('?', putdat);
f0100a0e:	83 ec 08             	sub    $0x8,%esp
f0100a11:	57                   	push   %edi
f0100a12:	6a 3f                	push   $0x3f
f0100a14:	ff d6                	call   *%esi
f0100a16:	83 c4 10             	add    $0x10,%esp
f0100a19:	eb c3                	jmp    f01009de <.L24+0x93>
f0100a1b:	89 cb                	mov    %ecx,%ebx
f0100a1d:	eb 0e                	jmp    f0100a2d <.L24+0xe2>
				putch(' ', putdat);
f0100a1f:	83 ec 08             	sub    $0x8,%esp
f0100a22:	57                   	push   %edi
f0100a23:	6a 20                	push   $0x20
f0100a25:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0100a27:	83 eb 01             	sub    $0x1,%ebx
f0100a2a:	83 c4 10             	add    $0x10,%esp
f0100a2d:	85 db                	test   %ebx,%ebx
f0100a2f:	7f ee                	jg     f0100a1f <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f0100a31:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100a34:	89 45 14             	mov    %eax,0x14(%ebp)
f0100a37:	e9 44 01 00 00       	jmp    f0100b80 <.L25+0x45>
f0100a3c:	89 cb                	mov    %ecx,%ebx
f0100a3e:	eb ed                	jmp    f0100a2d <.L24+0xe2>

f0100a40 <.L29>:
f0100a40:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100a43:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0100a46:	83 f9 01             	cmp    $0x1,%ecx
f0100a49:	7f 1b                	jg     f0100a66 <.L29+0x26>
	else if (lflag)
f0100a4b:	85 c9                	test   %ecx,%ecx
f0100a4d:	74 63                	je     f0100ab2 <.L29+0x72>
		return va_arg(*ap, long);
f0100a4f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100a52:	8b 00                	mov    (%eax),%eax
f0100a54:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100a57:	99                   	cltd   
f0100a58:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100a5b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100a5e:	8d 40 04             	lea    0x4(%eax),%eax
f0100a61:	89 45 14             	mov    %eax,0x14(%ebp)
f0100a64:	eb 17                	jmp    f0100a7d <.L29+0x3d>
		return va_arg(*ap, long long);
f0100a66:	8b 45 14             	mov    0x14(%ebp),%eax
f0100a69:	8b 50 04             	mov    0x4(%eax),%edx
f0100a6c:	8b 00                	mov    (%eax),%eax
f0100a6e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100a71:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100a74:	8b 45 14             	mov    0x14(%ebp),%eax
f0100a77:	8d 40 08             	lea    0x8(%eax),%eax
f0100a7a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0100a7d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100a80:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0100a83:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0100a88:	85 c9                	test   %ecx,%ecx
f0100a8a:	0f 89 d6 00 00 00    	jns    f0100b66 <.L25+0x2b>
				putch('-', putdat);
f0100a90:	83 ec 08             	sub    $0x8,%esp
f0100a93:	57                   	push   %edi
f0100a94:	6a 2d                	push   $0x2d
f0100a96:	ff d6                	call   *%esi
				num = -(long long) num;
f0100a98:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100a9b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100a9e:	f7 da                	neg    %edx
f0100aa0:	83 d1 00             	adc    $0x0,%ecx
f0100aa3:	f7 d9                	neg    %ecx
f0100aa5:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0100aa8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0100aad:	e9 b4 00 00 00       	jmp    f0100b66 <.L25+0x2b>
		return va_arg(*ap, int);
f0100ab2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ab5:	8b 00                	mov    (%eax),%eax
f0100ab7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100aba:	99                   	cltd   
f0100abb:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0100abe:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ac1:	8d 40 04             	lea    0x4(%eax),%eax
f0100ac4:	89 45 14             	mov    %eax,0x14(%ebp)
f0100ac7:	eb b4                	jmp    f0100a7d <.L29+0x3d>

f0100ac9 <.L23>:
f0100ac9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100acc:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0100acf:	83 f9 01             	cmp    $0x1,%ecx
f0100ad2:	7f 1b                	jg     f0100aef <.L23+0x26>
	else if (lflag)
f0100ad4:	85 c9                	test   %ecx,%ecx
f0100ad6:	74 2c                	je     f0100b04 <.L23+0x3b>
		return va_arg(*ap, unsigned long);
f0100ad8:	8b 45 14             	mov    0x14(%ebp),%eax
f0100adb:	8b 10                	mov    (%eax),%edx
f0100add:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ae2:	8d 40 04             	lea    0x4(%eax),%eax
f0100ae5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0100ae8:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f0100aed:	eb 77                	jmp    f0100b66 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0100aef:	8b 45 14             	mov    0x14(%ebp),%eax
f0100af2:	8b 10                	mov    (%eax),%edx
f0100af4:	8b 48 04             	mov    0x4(%eax),%ecx
f0100af7:	8d 40 08             	lea    0x8(%eax),%eax
f0100afa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0100afd:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f0100b02:	eb 62                	jmp    f0100b66 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0100b04:	8b 45 14             	mov    0x14(%ebp),%eax
f0100b07:	8b 10                	mov    (%eax),%edx
f0100b09:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100b0e:	8d 40 04             	lea    0x4(%eax),%eax
f0100b11:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0100b14:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f0100b19:	eb 4b                	jmp    f0100b66 <.L25+0x2b>

f0100b1b <.L26>:
f0100b1b:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('X', putdat);
f0100b1e:	83 ec 08             	sub    $0x8,%esp
f0100b21:	57                   	push   %edi
f0100b22:	6a 58                	push   $0x58
f0100b24:	ff d6                	call   *%esi
			putch('X', putdat);
f0100b26:	83 c4 08             	add    $0x8,%esp
f0100b29:	57                   	push   %edi
f0100b2a:	6a 58                	push   $0x58
f0100b2c:	ff d6                	call   *%esi
			putch('X', putdat);
f0100b2e:	83 c4 08             	add    $0x8,%esp
f0100b31:	57                   	push   %edi
f0100b32:	6a 58                	push   $0x58
f0100b34:	ff d6                	call   *%esi
			break;
f0100b36:	83 c4 10             	add    $0x10,%esp
f0100b39:	eb 45                	jmp    f0100b80 <.L25+0x45>

f0100b3b <.L25>:
f0100b3b:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f0100b3e:	83 ec 08             	sub    $0x8,%esp
f0100b41:	57                   	push   %edi
f0100b42:	6a 30                	push   $0x30
f0100b44:	ff d6                	call   *%esi
			putch('x', putdat);
f0100b46:	83 c4 08             	add    $0x8,%esp
f0100b49:	57                   	push   %edi
f0100b4a:	6a 78                	push   $0x78
f0100b4c:	ff d6                	call   *%esi
			num = (unsigned long long)
f0100b4e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100b51:	8b 10                	mov    (%eax),%edx
f0100b53:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0100b58:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0100b5b:	8d 40 04             	lea    0x4(%eax),%eax
f0100b5e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0100b61:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0100b66:	83 ec 0c             	sub    $0xc,%esp
f0100b69:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f0100b6d:	53                   	push   %ebx
f0100b6e:	ff 75 d0             	pushl  -0x30(%ebp)
f0100b71:	50                   	push   %eax
f0100b72:	51                   	push   %ecx
f0100b73:	52                   	push   %edx
f0100b74:	89 fa                	mov    %edi,%edx
f0100b76:	89 f0                	mov    %esi,%eax
f0100b78:	e8 40 fb ff ff       	call   f01006bd <printnum>
			break;
f0100b7d:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f0100b80:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100b83:	83 c3 01             	add    $0x1,%ebx
f0100b86:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0100b8a:	83 f8 25             	cmp    $0x25,%eax
f0100b8d:	0f 84 5b fc ff ff    	je     f01007ee <vprintfmt+0x31>
			if (ch == '\0')
f0100b93:	85 c0                	test   %eax,%eax
f0100b95:	0f 84 97 00 00 00    	je     f0100c32 <.L20+0x23>
			putch(ch, putdat);
f0100b9b:	83 ec 08             	sub    $0x8,%esp
f0100b9e:	57                   	push   %edi
f0100b9f:	50                   	push   %eax
f0100ba0:	ff d6                	call   *%esi
f0100ba2:	83 c4 10             	add    $0x10,%esp
f0100ba5:	eb dc                	jmp    f0100b83 <.L25+0x48>

f0100ba7 <.L21>:
f0100ba7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0100baa:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0100bad:	83 f9 01             	cmp    $0x1,%ecx
f0100bb0:	7f 1b                	jg     f0100bcd <.L21+0x26>
	else if (lflag)
f0100bb2:	85 c9                	test   %ecx,%ecx
f0100bb4:	74 2c                	je     f0100be2 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f0100bb6:	8b 45 14             	mov    0x14(%ebp),%eax
f0100bb9:	8b 10                	mov    (%eax),%edx
f0100bbb:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100bc0:	8d 40 04             	lea    0x4(%eax),%eax
f0100bc3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0100bc6:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f0100bcb:	eb 99                	jmp    f0100b66 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0100bcd:	8b 45 14             	mov    0x14(%ebp),%eax
f0100bd0:	8b 10                	mov    (%eax),%edx
f0100bd2:	8b 48 04             	mov    0x4(%eax),%ecx
f0100bd5:	8d 40 08             	lea    0x8(%eax),%eax
f0100bd8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0100bdb:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0100be0:	eb 84                	jmp    f0100b66 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f0100be2:	8b 45 14             	mov    0x14(%ebp),%eax
f0100be5:	8b 10                	mov    (%eax),%edx
f0100be7:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100bec:	8d 40 04             	lea    0x4(%eax),%eax
f0100bef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0100bf2:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0100bf7:	e9 6a ff ff ff       	jmp    f0100b66 <.L25+0x2b>

f0100bfc <.L35>:
f0100bfc:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f0100bff:	83 ec 08             	sub    $0x8,%esp
f0100c02:	57                   	push   %edi
f0100c03:	6a 25                	push   $0x25
f0100c05:	ff d6                	call   *%esi
			break;
f0100c07:	83 c4 10             	add    $0x10,%esp
f0100c0a:	e9 71 ff ff ff       	jmp    f0100b80 <.L25+0x45>

f0100c0f <.L20>:
f0100c0f:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f0100c12:	83 ec 08             	sub    $0x8,%esp
f0100c15:	57                   	push   %edi
f0100c16:	6a 25                	push   $0x25
f0100c18:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0100c1a:	83 c4 10             	add    $0x10,%esp
f0100c1d:	89 d8                	mov    %ebx,%eax
f0100c1f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0100c23:	74 05                	je     f0100c2a <.L20+0x1b>
f0100c25:	83 e8 01             	sub    $0x1,%eax
f0100c28:	eb f5                	jmp    f0100c1f <.L20+0x10>
f0100c2a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100c2d:	e9 4e ff ff ff       	jmp    f0100b80 <.L25+0x45>
}
f0100c32:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c35:	5b                   	pop    %ebx
f0100c36:	5e                   	pop    %esi
f0100c37:	5f                   	pop    %edi
f0100c38:	5d                   	pop    %ebp
f0100c39:	c3                   	ret    

f0100c3a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0100c3a:	f3 0f 1e fb          	endbr32 
f0100c3e:	55                   	push   %ebp
f0100c3f:	89 e5                	mov    %esp,%ebp
f0100c41:	53                   	push   %ebx
f0100c42:	83 ec 14             	sub    $0x14,%esp
f0100c45:	e8 3e f4 ff ff       	call   f0100088 <__x86.get_pc_thunk.bx>
f0100c4a:	81 c3 b6 e6 00 00    	add    $0xe6b6,%ebx
f0100c50:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c53:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0100c56:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100c59:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0100c5d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0100c60:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0100c67:	85 c0                	test   %eax,%eax
f0100c69:	74 2b                	je     f0100c96 <vsnprintf+0x5c>
f0100c6b:	85 d2                	test   %edx,%edx
f0100c6d:	7e 27                	jle    f0100c96 <vsnprintf+0x5c>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0100c6f:	ff 75 14             	pushl  0x14(%ebp)
f0100c72:	ff 75 10             	pushl  0x10(%ebp)
f0100c75:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0100c78:	50                   	push   %eax
f0100c79:	8d 83 7b 14 ff ff    	lea    -0xeb85(%ebx),%eax
f0100c7f:	50                   	push   %eax
f0100c80:	e8 38 fb ff ff       	call   f01007bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0100c85:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0100c88:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0100c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100c8e:	83 c4 10             	add    $0x10,%esp
}
f0100c91:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c94:	c9                   	leave  
f0100c95:	c3                   	ret    
		return -E_INVAL;
f0100c96:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0100c9b:	eb f4                	jmp    f0100c91 <vsnprintf+0x57>

f0100c9d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0100c9d:	f3 0f 1e fb          	endbr32 
f0100ca1:	55                   	push   %ebp
f0100ca2:	89 e5                	mov    %esp,%ebp
f0100ca4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0100ca7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0100caa:	50                   	push   %eax
f0100cab:	ff 75 10             	pushl  0x10(%ebp)
f0100cae:	ff 75 0c             	pushl  0xc(%ebp)
f0100cb1:	ff 75 08             	pushl  0x8(%ebp)
f0100cb4:	e8 81 ff ff ff       	call   f0100c3a <vsnprintf>
	va_end(ap);

	return rc;
}
f0100cb9:	c9                   	leave  
f0100cba:	c3                   	ret    

f0100cbb <__x86.get_pc_thunk.cx>:
f0100cbb:	8b 0c 24             	mov    (%esp),%ecx
f0100cbe:	c3                   	ret    

f0100cbf <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0100cbf:	f3 0f 1e fb          	endbr32 
f0100cc3:	55                   	push   %ebp
f0100cc4:	89 e5                	mov    %esp,%ebp
f0100cc6:	57                   	push   %edi
f0100cc7:	56                   	push   %esi
f0100cc8:	53                   	push   %ebx
f0100cc9:	83 ec 1c             	sub    $0x1c,%esp
f0100ccc:	e8 b7 f3 ff ff       	call   f0100088 <__x86.get_pc_thunk.bx>
f0100cd1:	81 c3 2f e6 00 00    	add    $0xe62f,%ebx
f0100cd7:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0100cda:	85 c0                	test   %eax,%eax
f0100cdc:	74 13                	je     f0100cf1 <readline+0x32>
		cprintf("%s", prompt);
f0100cde:	83 ec 08             	sub    $0x8,%esp
f0100ce1:	50                   	push   %eax
f0100ce2:	8d 83 41 23 ff ff    	lea    -0xdcbf(%ebx),%eax
f0100ce8:	50                   	push   %eax
f0100ce9:	e8 b7 f9 ff ff       	call   f01006a5 <cprintf>
f0100cee:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0100cf1:	83 ec 0c             	sub    $0xc,%esp
f0100cf4:	6a 00                	push   $0x0
f0100cf6:	e8 37 f9 ff ff       	call   f0100632 <iscons>
f0100cfb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100cfe:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0100d01:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0100d06:	8d 83 80 1f 00 00    	lea    0x1f80(%ebx),%eax
f0100d0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100d0f:	eb 51                	jmp    f0100d62 <readline+0xa3>
			cprintf("read error: %e\n", c);
f0100d11:	83 ec 08             	sub    $0x8,%esp
f0100d14:	50                   	push   %eax
f0100d15:	8d 83 08 25 ff ff    	lea    -0xdaf8(%ebx),%eax
f0100d1b:	50                   	push   %eax
f0100d1c:	e8 84 f9 ff ff       	call   f01006a5 <cprintf>
			return NULL;
f0100d21:	83 c4 10             	add    $0x10,%esp
f0100d24:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0100d29:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d2c:	5b                   	pop    %ebx
f0100d2d:	5e                   	pop    %esi
f0100d2e:	5f                   	pop    %edi
f0100d2f:	5d                   	pop    %ebp
f0100d30:	c3                   	ret    
			if (echoing)
f0100d31:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100d35:	75 05                	jne    f0100d3c <readline+0x7d>
			i--;
f0100d37:	83 ef 01             	sub    $0x1,%edi
f0100d3a:	eb 26                	jmp    f0100d62 <readline+0xa3>
				cputchar('\b');
f0100d3c:	83 ec 0c             	sub    $0xc,%esp
f0100d3f:	6a 08                	push   $0x8
f0100d41:	e8 c3 f8 ff ff       	call   f0100609 <cputchar>
f0100d46:	83 c4 10             	add    $0x10,%esp
f0100d49:	eb ec                	jmp    f0100d37 <readline+0x78>
				cputchar(c);
f0100d4b:	83 ec 0c             	sub    $0xc,%esp
f0100d4e:	56                   	push   %esi
f0100d4f:	e8 b5 f8 ff ff       	call   f0100609 <cputchar>
f0100d54:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0100d57:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100d5a:	89 f0                	mov    %esi,%eax
f0100d5c:	88 04 39             	mov    %al,(%ecx,%edi,1)
f0100d5f:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0100d62:	e8 b6 f8 ff ff       	call   f010061d <getchar>
f0100d67:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0100d69:	85 c0                	test   %eax,%eax
f0100d6b:	78 a4                	js     f0100d11 <readline+0x52>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0100d6d:	83 f8 08             	cmp    $0x8,%eax
f0100d70:	0f 94 c2             	sete   %dl
f0100d73:	83 f8 7f             	cmp    $0x7f,%eax
f0100d76:	0f 94 c0             	sete   %al
f0100d79:	08 c2                	or     %al,%dl
f0100d7b:	74 04                	je     f0100d81 <readline+0xc2>
f0100d7d:	85 ff                	test   %edi,%edi
f0100d7f:	7f b0                	jg     f0100d31 <readline+0x72>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0100d81:	83 fe 1f             	cmp    $0x1f,%esi
f0100d84:	7e 10                	jle    f0100d96 <readline+0xd7>
f0100d86:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0100d8c:	7f 08                	jg     f0100d96 <readline+0xd7>
			if (echoing)
f0100d8e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100d92:	74 c3                	je     f0100d57 <readline+0x98>
f0100d94:	eb b5                	jmp    f0100d4b <readline+0x8c>
		} else if (c == '\n' || c == '\r') {
f0100d96:	83 fe 0a             	cmp    $0xa,%esi
f0100d99:	74 05                	je     f0100da0 <readline+0xe1>
f0100d9b:	83 fe 0d             	cmp    $0xd,%esi
f0100d9e:	75 c2                	jne    f0100d62 <readline+0xa3>
			if (echoing)
f0100da0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100da4:	75 13                	jne    f0100db9 <readline+0xfa>
			buf[i] = 0;
f0100da6:	c6 84 3b 80 1f 00 00 	movb   $0x0,0x1f80(%ebx,%edi,1)
f0100dad:	00 
			return buf;
f0100dae:	8d 83 80 1f 00 00    	lea    0x1f80(%ebx),%eax
f0100db4:	e9 70 ff ff ff       	jmp    f0100d29 <readline+0x6a>
				cputchar('\n');
f0100db9:	83 ec 0c             	sub    $0xc,%esp
f0100dbc:	6a 0a                	push   $0xa
f0100dbe:	e8 46 f8 ff ff       	call   f0100609 <cputchar>
f0100dc3:	83 c4 10             	add    $0x10,%esp
f0100dc6:	eb de                	jmp    f0100da6 <readline+0xe7>

f0100dc8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0100dc8:	f3 0f 1e fb          	endbr32 
f0100dcc:	55                   	push   %ebp
f0100dcd:	89 e5                	mov    %esp,%ebp
f0100dcf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0100dd2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100dd7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0100ddb:	74 05                	je     f0100de2 <strlen+0x1a>
		n++;
f0100ddd:	83 c0 01             	add    $0x1,%eax
f0100de0:	eb f5                	jmp    f0100dd7 <strlen+0xf>
	return n;
}
f0100de2:	5d                   	pop    %ebp
f0100de3:	c3                   	ret    

f0100de4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0100de4:	f3 0f 1e fb          	endbr32 
f0100de8:	55                   	push   %ebp
f0100de9:	89 e5                	mov    %esp,%ebp
f0100deb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100dee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0100df1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100df6:	39 d0                	cmp    %edx,%eax
f0100df8:	74 0d                	je     f0100e07 <strnlen+0x23>
f0100dfa:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0100dfe:	74 05                	je     f0100e05 <strnlen+0x21>
		n++;
f0100e00:	83 c0 01             	add    $0x1,%eax
f0100e03:	eb f1                	jmp    f0100df6 <strnlen+0x12>
f0100e05:	89 c2                	mov    %eax,%edx
	return n;
}
f0100e07:	89 d0                	mov    %edx,%eax
f0100e09:	5d                   	pop    %ebp
f0100e0a:	c3                   	ret    

f0100e0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0100e0b:	f3 0f 1e fb          	endbr32 
f0100e0f:	55                   	push   %ebp
f0100e10:	89 e5                	mov    %esp,%ebp
f0100e12:	53                   	push   %ebx
f0100e13:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100e16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0100e19:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e1e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0100e22:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f0100e25:	83 c0 01             	add    $0x1,%eax
f0100e28:	84 d2                	test   %dl,%dl
f0100e2a:	75 f2                	jne    f0100e1e <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0100e2c:	89 c8                	mov    %ecx,%eax
f0100e2e:	5b                   	pop    %ebx
f0100e2f:	5d                   	pop    %ebp
f0100e30:	c3                   	ret    

f0100e31 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0100e31:	f3 0f 1e fb          	endbr32 
f0100e35:	55                   	push   %ebp
f0100e36:	89 e5                	mov    %esp,%ebp
f0100e38:	53                   	push   %ebx
f0100e39:	83 ec 10             	sub    $0x10,%esp
f0100e3c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0100e3f:	53                   	push   %ebx
f0100e40:	e8 83 ff ff ff       	call   f0100dc8 <strlen>
f0100e45:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0100e48:	ff 75 0c             	pushl  0xc(%ebp)
f0100e4b:	01 d8                	add    %ebx,%eax
f0100e4d:	50                   	push   %eax
f0100e4e:	e8 b8 ff ff ff       	call   f0100e0b <strcpy>
	return dst;
}
f0100e53:	89 d8                	mov    %ebx,%eax
f0100e55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e58:	c9                   	leave  
f0100e59:	c3                   	ret    

f0100e5a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0100e5a:	f3 0f 1e fb          	endbr32 
f0100e5e:	55                   	push   %ebp
f0100e5f:	89 e5                	mov    %esp,%ebp
f0100e61:	56                   	push   %esi
f0100e62:	53                   	push   %ebx
f0100e63:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e66:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100e69:	89 f3                	mov    %esi,%ebx
f0100e6b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0100e6e:	89 f0                	mov    %esi,%eax
f0100e70:	39 d8                	cmp    %ebx,%eax
f0100e72:	74 11                	je     f0100e85 <strncpy+0x2b>
		*dst++ = *src;
f0100e74:	83 c0 01             	add    $0x1,%eax
f0100e77:	0f b6 0a             	movzbl (%edx),%ecx
f0100e7a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0100e7d:	80 f9 01             	cmp    $0x1,%cl
f0100e80:	83 da ff             	sbb    $0xffffffff,%edx
f0100e83:	eb eb                	jmp    f0100e70 <strncpy+0x16>
	}
	return ret;
}
f0100e85:	89 f0                	mov    %esi,%eax
f0100e87:	5b                   	pop    %ebx
f0100e88:	5e                   	pop    %esi
f0100e89:	5d                   	pop    %ebp
f0100e8a:	c3                   	ret    

f0100e8b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0100e8b:	f3 0f 1e fb          	endbr32 
f0100e8f:	55                   	push   %ebp
f0100e90:	89 e5                	mov    %esp,%ebp
f0100e92:	56                   	push   %esi
f0100e93:	53                   	push   %ebx
f0100e94:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0100e9a:	8b 55 10             	mov    0x10(%ebp),%edx
f0100e9d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0100e9f:	85 d2                	test   %edx,%edx
f0100ea1:	74 21                	je     f0100ec4 <strlcpy+0x39>
f0100ea3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0100ea7:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0100ea9:	39 c2                	cmp    %eax,%edx
f0100eab:	74 14                	je     f0100ec1 <strlcpy+0x36>
f0100ead:	0f b6 19             	movzbl (%ecx),%ebx
f0100eb0:	84 db                	test   %bl,%bl
f0100eb2:	74 0b                	je     f0100ebf <strlcpy+0x34>
			*dst++ = *src++;
f0100eb4:	83 c1 01             	add    $0x1,%ecx
f0100eb7:	83 c2 01             	add    $0x1,%edx
f0100eba:	88 5a ff             	mov    %bl,-0x1(%edx)
f0100ebd:	eb ea                	jmp    f0100ea9 <strlcpy+0x1e>
f0100ebf:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0100ec1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0100ec4:	29 f0                	sub    %esi,%eax
}
f0100ec6:	5b                   	pop    %ebx
f0100ec7:	5e                   	pop    %esi
f0100ec8:	5d                   	pop    %ebp
f0100ec9:	c3                   	ret    

f0100eca <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0100eca:	f3 0f 1e fb          	endbr32 
f0100ece:	55                   	push   %ebp
f0100ecf:	89 e5                	mov    %esp,%ebp
f0100ed1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100ed4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0100ed7:	0f b6 01             	movzbl (%ecx),%eax
f0100eda:	84 c0                	test   %al,%al
f0100edc:	74 0c                	je     f0100eea <strcmp+0x20>
f0100ede:	3a 02                	cmp    (%edx),%al
f0100ee0:	75 08                	jne    f0100eea <strcmp+0x20>
		p++, q++;
f0100ee2:	83 c1 01             	add    $0x1,%ecx
f0100ee5:	83 c2 01             	add    $0x1,%edx
f0100ee8:	eb ed                	jmp    f0100ed7 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0100eea:	0f b6 c0             	movzbl %al,%eax
f0100eed:	0f b6 12             	movzbl (%edx),%edx
f0100ef0:	29 d0                	sub    %edx,%eax
}
f0100ef2:	5d                   	pop    %ebp
f0100ef3:	c3                   	ret    

f0100ef4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0100ef4:	f3 0f 1e fb          	endbr32 
f0100ef8:	55                   	push   %ebp
f0100ef9:	89 e5                	mov    %esp,%ebp
f0100efb:	53                   	push   %ebx
f0100efc:	8b 45 08             	mov    0x8(%ebp),%eax
f0100eff:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100f02:	89 c3                	mov    %eax,%ebx
f0100f04:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0100f07:	eb 06                	jmp    f0100f0f <strncmp+0x1b>
		n--, p++, q++;
f0100f09:	83 c0 01             	add    $0x1,%eax
f0100f0c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0100f0f:	39 d8                	cmp    %ebx,%eax
f0100f11:	74 16                	je     f0100f29 <strncmp+0x35>
f0100f13:	0f b6 08             	movzbl (%eax),%ecx
f0100f16:	84 c9                	test   %cl,%cl
f0100f18:	74 04                	je     f0100f1e <strncmp+0x2a>
f0100f1a:	3a 0a                	cmp    (%edx),%cl
f0100f1c:	74 eb                	je     f0100f09 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0100f1e:	0f b6 00             	movzbl (%eax),%eax
f0100f21:	0f b6 12             	movzbl (%edx),%edx
f0100f24:	29 d0                	sub    %edx,%eax
}
f0100f26:	5b                   	pop    %ebx
f0100f27:	5d                   	pop    %ebp
f0100f28:	c3                   	ret    
		return 0;
f0100f29:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f2e:	eb f6                	jmp    f0100f26 <strncmp+0x32>

f0100f30 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0100f30:	f3 0f 1e fb          	endbr32 
f0100f34:	55                   	push   %ebp
f0100f35:	89 e5                	mov    %esp,%ebp
f0100f37:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f3a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0100f3e:	0f b6 10             	movzbl (%eax),%edx
f0100f41:	84 d2                	test   %dl,%dl
f0100f43:	74 09                	je     f0100f4e <strchr+0x1e>
		if (*s == c)
f0100f45:	38 ca                	cmp    %cl,%dl
f0100f47:	74 0a                	je     f0100f53 <strchr+0x23>
	for (; *s; s++)
f0100f49:	83 c0 01             	add    $0x1,%eax
f0100f4c:	eb f0                	jmp    f0100f3e <strchr+0xe>
			return (char *) s;
	return 0;
f0100f4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100f53:	5d                   	pop    %ebp
f0100f54:	c3                   	ret    

f0100f55 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0100f55:	f3 0f 1e fb          	endbr32 
f0100f59:	55                   	push   %ebp
f0100f5a:	89 e5                	mov    %esp,%ebp
f0100f5c:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f5f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0100f63:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0100f66:	38 ca                	cmp    %cl,%dl
f0100f68:	74 09                	je     f0100f73 <strfind+0x1e>
f0100f6a:	84 d2                	test   %dl,%dl
f0100f6c:	74 05                	je     f0100f73 <strfind+0x1e>
	for (; *s; s++)
f0100f6e:	83 c0 01             	add    $0x1,%eax
f0100f71:	eb f0                	jmp    f0100f63 <strfind+0xe>
			break;
	return (char *) s;
}
f0100f73:	5d                   	pop    %ebp
f0100f74:	c3                   	ret    

f0100f75 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0100f75:	f3 0f 1e fb          	endbr32 
f0100f79:	55                   	push   %ebp
f0100f7a:	89 e5                	mov    %esp,%ebp
f0100f7c:	57                   	push   %edi
f0100f7d:	56                   	push   %esi
f0100f7e:	53                   	push   %ebx
f0100f7f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100f82:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0100f85:	85 c9                	test   %ecx,%ecx
f0100f87:	74 31                	je     f0100fba <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0100f89:	89 f8                	mov    %edi,%eax
f0100f8b:	09 c8                	or     %ecx,%eax
f0100f8d:	a8 03                	test   $0x3,%al
f0100f8f:	75 23                	jne    f0100fb4 <memset+0x3f>
		c &= 0xFF;
f0100f91:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0100f95:	89 d3                	mov    %edx,%ebx
f0100f97:	c1 e3 08             	shl    $0x8,%ebx
f0100f9a:	89 d0                	mov    %edx,%eax
f0100f9c:	c1 e0 18             	shl    $0x18,%eax
f0100f9f:	89 d6                	mov    %edx,%esi
f0100fa1:	c1 e6 10             	shl    $0x10,%esi
f0100fa4:	09 f0                	or     %esi,%eax
f0100fa6:	09 c2                	or     %eax,%edx
f0100fa8:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0100faa:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0100fad:	89 d0                	mov    %edx,%eax
f0100faf:	fc                   	cld    
f0100fb0:	f3 ab                	rep stos %eax,%es:(%edi)
f0100fb2:	eb 06                	jmp    f0100fba <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0100fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fb7:	fc                   	cld    
f0100fb8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0100fba:	89 f8                	mov    %edi,%eax
f0100fbc:	5b                   	pop    %ebx
f0100fbd:	5e                   	pop    %esi
f0100fbe:	5f                   	pop    %edi
f0100fbf:	5d                   	pop    %ebp
f0100fc0:	c3                   	ret    

f0100fc1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0100fc1:	f3 0f 1e fb          	endbr32 
f0100fc5:	55                   	push   %ebp
f0100fc6:	89 e5                	mov    %esp,%ebp
f0100fc8:	57                   	push   %edi
f0100fc9:	56                   	push   %esi
f0100fca:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fcd:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100fd0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0100fd3:	39 c6                	cmp    %eax,%esi
f0100fd5:	73 32                	jae    f0101009 <memmove+0x48>
f0100fd7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0100fda:	39 c2                	cmp    %eax,%edx
f0100fdc:	76 2b                	jbe    f0101009 <memmove+0x48>
		s += n;
		d += n;
f0100fde:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0100fe1:	89 fe                	mov    %edi,%esi
f0100fe3:	09 ce                	or     %ecx,%esi
f0100fe5:	09 d6                	or     %edx,%esi
f0100fe7:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0100fed:	75 0e                	jne    f0100ffd <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0100fef:	83 ef 04             	sub    $0x4,%edi
f0100ff2:	8d 72 fc             	lea    -0x4(%edx),%esi
f0100ff5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0100ff8:	fd                   	std    
f0100ff9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0100ffb:	eb 09                	jmp    f0101006 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0100ffd:	83 ef 01             	sub    $0x1,%edi
f0101000:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101003:	fd                   	std    
f0101004:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101006:	fc                   	cld    
f0101007:	eb 1a                	jmp    f0101023 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101009:	89 c2                	mov    %eax,%edx
f010100b:	09 ca                	or     %ecx,%edx
f010100d:	09 f2                	or     %esi,%edx
f010100f:	f6 c2 03             	test   $0x3,%dl
f0101012:	75 0a                	jne    f010101e <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101014:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0101017:	89 c7                	mov    %eax,%edi
f0101019:	fc                   	cld    
f010101a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010101c:	eb 05                	jmp    f0101023 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f010101e:	89 c7                	mov    %eax,%edi
f0101020:	fc                   	cld    
f0101021:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101023:	5e                   	pop    %esi
f0101024:	5f                   	pop    %edi
f0101025:	5d                   	pop    %ebp
f0101026:	c3                   	ret    

f0101027 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101027:	f3 0f 1e fb          	endbr32 
f010102b:	55                   	push   %ebp
f010102c:	89 e5                	mov    %esp,%ebp
f010102e:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0101031:	ff 75 10             	pushl  0x10(%ebp)
f0101034:	ff 75 0c             	pushl  0xc(%ebp)
f0101037:	ff 75 08             	pushl  0x8(%ebp)
f010103a:	e8 82 ff ff ff       	call   f0100fc1 <memmove>
}
f010103f:	c9                   	leave  
f0101040:	c3                   	ret    

f0101041 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101041:	f3 0f 1e fb          	endbr32 
f0101045:	55                   	push   %ebp
f0101046:	89 e5                	mov    %esp,%ebp
f0101048:	56                   	push   %esi
f0101049:	53                   	push   %ebx
f010104a:	8b 45 08             	mov    0x8(%ebp),%eax
f010104d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101050:	89 c6                	mov    %eax,%esi
f0101052:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101055:	39 f0                	cmp    %esi,%eax
f0101057:	74 1c                	je     f0101075 <memcmp+0x34>
		if (*s1 != *s2)
f0101059:	0f b6 08             	movzbl (%eax),%ecx
f010105c:	0f b6 1a             	movzbl (%edx),%ebx
f010105f:	38 d9                	cmp    %bl,%cl
f0101061:	75 08                	jne    f010106b <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101063:	83 c0 01             	add    $0x1,%eax
f0101066:	83 c2 01             	add    $0x1,%edx
f0101069:	eb ea                	jmp    f0101055 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f010106b:	0f b6 c1             	movzbl %cl,%eax
f010106e:	0f b6 db             	movzbl %bl,%ebx
f0101071:	29 d8                	sub    %ebx,%eax
f0101073:	eb 05                	jmp    f010107a <memcmp+0x39>
	}

	return 0;
f0101075:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010107a:	5b                   	pop    %ebx
f010107b:	5e                   	pop    %esi
f010107c:	5d                   	pop    %ebp
f010107d:	c3                   	ret    

f010107e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010107e:	f3 0f 1e fb          	endbr32 
f0101082:	55                   	push   %ebp
f0101083:	89 e5                	mov    %esp,%ebp
f0101085:	8b 45 08             	mov    0x8(%ebp),%eax
f0101088:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010108b:	89 c2                	mov    %eax,%edx
f010108d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101090:	39 d0                	cmp    %edx,%eax
f0101092:	73 09                	jae    f010109d <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101094:	38 08                	cmp    %cl,(%eax)
f0101096:	74 05                	je     f010109d <memfind+0x1f>
	for (; s < ends; s++)
f0101098:	83 c0 01             	add    $0x1,%eax
f010109b:	eb f3                	jmp    f0101090 <memfind+0x12>
			break;
	return (void *) s;
}
f010109d:	5d                   	pop    %ebp
f010109e:	c3                   	ret    

f010109f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010109f:	f3 0f 1e fb          	endbr32 
f01010a3:	55                   	push   %ebp
f01010a4:	89 e5                	mov    %esp,%ebp
f01010a6:	57                   	push   %edi
f01010a7:	56                   	push   %esi
f01010a8:	53                   	push   %ebx
f01010a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01010ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01010af:	eb 03                	jmp    f01010b4 <strtol+0x15>
		s++;
f01010b1:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01010b4:	0f b6 01             	movzbl (%ecx),%eax
f01010b7:	3c 20                	cmp    $0x20,%al
f01010b9:	74 f6                	je     f01010b1 <strtol+0x12>
f01010bb:	3c 09                	cmp    $0x9,%al
f01010bd:	74 f2                	je     f01010b1 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f01010bf:	3c 2b                	cmp    $0x2b,%al
f01010c1:	74 2a                	je     f01010ed <strtol+0x4e>
	int neg = 0;
f01010c3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01010c8:	3c 2d                	cmp    $0x2d,%al
f01010ca:	74 2b                	je     f01010f7 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01010cc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01010d2:	75 0f                	jne    f01010e3 <strtol+0x44>
f01010d4:	80 39 30             	cmpb   $0x30,(%ecx)
f01010d7:	74 28                	je     f0101101 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01010d9:	85 db                	test   %ebx,%ebx
f01010db:	b8 0a 00 00 00       	mov    $0xa,%eax
f01010e0:	0f 44 d8             	cmove  %eax,%ebx
f01010e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01010e8:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01010eb:	eb 46                	jmp    f0101133 <strtol+0x94>
		s++;
f01010ed:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01010f0:	bf 00 00 00 00       	mov    $0x0,%edi
f01010f5:	eb d5                	jmp    f01010cc <strtol+0x2d>
		s++, neg = 1;
f01010f7:	83 c1 01             	add    $0x1,%ecx
f01010fa:	bf 01 00 00 00       	mov    $0x1,%edi
f01010ff:	eb cb                	jmp    f01010cc <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101101:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101105:	74 0e                	je     f0101115 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0101107:	85 db                	test   %ebx,%ebx
f0101109:	75 d8                	jne    f01010e3 <strtol+0x44>
		s++, base = 8;
f010110b:	83 c1 01             	add    $0x1,%ecx
f010110e:	bb 08 00 00 00       	mov    $0x8,%ebx
f0101113:	eb ce                	jmp    f01010e3 <strtol+0x44>
		s += 2, base = 16;
f0101115:	83 c1 02             	add    $0x2,%ecx
f0101118:	bb 10 00 00 00       	mov    $0x10,%ebx
f010111d:	eb c4                	jmp    f01010e3 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f010111f:	0f be d2             	movsbl %dl,%edx
f0101122:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101125:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101128:	7d 3a                	jge    f0101164 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f010112a:	83 c1 01             	add    $0x1,%ecx
f010112d:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101131:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0101133:	0f b6 11             	movzbl (%ecx),%edx
f0101136:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101139:	89 f3                	mov    %esi,%ebx
f010113b:	80 fb 09             	cmp    $0x9,%bl
f010113e:	76 df                	jbe    f010111f <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f0101140:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101143:	89 f3                	mov    %esi,%ebx
f0101145:	80 fb 19             	cmp    $0x19,%bl
f0101148:	77 08                	ja     f0101152 <strtol+0xb3>
			dig = *s - 'a' + 10;
f010114a:	0f be d2             	movsbl %dl,%edx
f010114d:	83 ea 57             	sub    $0x57,%edx
f0101150:	eb d3                	jmp    f0101125 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f0101152:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101155:	89 f3                	mov    %esi,%ebx
f0101157:	80 fb 19             	cmp    $0x19,%bl
f010115a:	77 08                	ja     f0101164 <strtol+0xc5>
			dig = *s - 'A' + 10;
f010115c:	0f be d2             	movsbl %dl,%edx
f010115f:	83 ea 37             	sub    $0x37,%edx
f0101162:	eb c1                	jmp    f0101125 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0101164:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101168:	74 05                	je     f010116f <strtol+0xd0>
		*endptr = (char *) s;
f010116a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010116d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010116f:	89 c2                	mov    %eax,%edx
f0101171:	f7 da                	neg    %edx
f0101173:	85 ff                	test   %edi,%edi
f0101175:	0f 45 c2             	cmovne %edx,%eax
}
f0101178:	5b                   	pop    %ebx
f0101179:	5e                   	pop    %esi
f010117a:	5f                   	pop    %edi
f010117b:	5d                   	pop    %ebp
f010117c:	c3                   	ret    
f010117d:	66 90                	xchg   %ax,%ax
f010117f:	90                   	nop

f0101180 <__udivdi3>:
f0101180:	f3 0f 1e fb          	endbr32 
f0101184:	55                   	push   %ebp
f0101185:	57                   	push   %edi
f0101186:	56                   	push   %esi
f0101187:	53                   	push   %ebx
f0101188:	83 ec 1c             	sub    $0x1c,%esp
f010118b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010118f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101193:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101197:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010119b:	85 d2                	test   %edx,%edx
f010119d:	75 19                	jne    f01011b8 <__udivdi3+0x38>
f010119f:	39 f3                	cmp    %esi,%ebx
f01011a1:	76 4d                	jbe    f01011f0 <__udivdi3+0x70>
f01011a3:	31 ff                	xor    %edi,%edi
f01011a5:	89 e8                	mov    %ebp,%eax
f01011a7:	89 f2                	mov    %esi,%edx
f01011a9:	f7 f3                	div    %ebx
f01011ab:	89 fa                	mov    %edi,%edx
f01011ad:	83 c4 1c             	add    $0x1c,%esp
f01011b0:	5b                   	pop    %ebx
f01011b1:	5e                   	pop    %esi
f01011b2:	5f                   	pop    %edi
f01011b3:	5d                   	pop    %ebp
f01011b4:	c3                   	ret    
f01011b5:	8d 76 00             	lea    0x0(%esi),%esi
f01011b8:	39 f2                	cmp    %esi,%edx
f01011ba:	76 14                	jbe    f01011d0 <__udivdi3+0x50>
f01011bc:	31 ff                	xor    %edi,%edi
f01011be:	31 c0                	xor    %eax,%eax
f01011c0:	89 fa                	mov    %edi,%edx
f01011c2:	83 c4 1c             	add    $0x1c,%esp
f01011c5:	5b                   	pop    %ebx
f01011c6:	5e                   	pop    %esi
f01011c7:	5f                   	pop    %edi
f01011c8:	5d                   	pop    %ebp
f01011c9:	c3                   	ret    
f01011ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01011d0:	0f bd fa             	bsr    %edx,%edi
f01011d3:	83 f7 1f             	xor    $0x1f,%edi
f01011d6:	75 48                	jne    f0101220 <__udivdi3+0xa0>
f01011d8:	39 f2                	cmp    %esi,%edx
f01011da:	72 06                	jb     f01011e2 <__udivdi3+0x62>
f01011dc:	31 c0                	xor    %eax,%eax
f01011de:	39 eb                	cmp    %ebp,%ebx
f01011e0:	77 de                	ja     f01011c0 <__udivdi3+0x40>
f01011e2:	b8 01 00 00 00       	mov    $0x1,%eax
f01011e7:	eb d7                	jmp    f01011c0 <__udivdi3+0x40>
f01011e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01011f0:	89 d9                	mov    %ebx,%ecx
f01011f2:	85 db                	test   %ebx,%ebx
f01011f4:	75 0b                	jne    f0101201 <__udivdi3+0x81>
f01011f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01011fb:	31 d2                	xor    %edx,%edx
f01011fd:	f7 f3                	div    %ebx
f01011ff:	89 c1                	mov    %eax,%ecx
f0101201:	31 d2                	xor    %edx,%edx
f0101203:	89 f0                	mov    %esi,%eax
f0101205:	f7 f1                	div    %ecx
f0101207:	89 c6                	mov    %eax,%esi
f0101209:	89 e8                	mov    %ebp,%eax
f010120b:	89 f7                	mov    %esi,%edi
f010120d:	f7 f1                	div    %ecx
f010120f:	89 fa                	mov    %edi,%edx
f0101211:	83 c4 1c             	add    $0x1c,%esp
f0101214:	5b                   	pop    %ebx
f0101215:	5e                   	pop    %esi
f0101216:	5f                   	pop    %edi
f0101217:	5d                   	pop    %ebp
f0101218:	c3                   	ret    
f0101219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101220:	89 f9                	mov    %edi,%ecx
f0101222:	b8 20 00 00 00       	mov    $0x20,%eax
f0101227:	29 f8                	sub    %edi,%eax
f0101229:	d3 e2                	shl    %cl,%edx
f010122b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010122f:	89 c1                	mov    %eax,%ecx
f0101231:	89 da                	mov    %ebx,%edx
f0101233:	d3 ea                	shr    %cl,%edx
f0101235:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101239:	09 d1                	or     %edx,%ecx
f010123b:	89 f2                	mov    %esi,%edx
f010123d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101241:	89 f9                	mov    %edi,%ecx
f0101243:	d3 e3                	shl    %cl,%ebx
f0101245:	89 c1                	mov    %eax,%ecx
f0101247:	d3 ea                	shr    %cl,%edx
f0101249:	89 f9                	mov    %edi,%ecx
f010124b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010124f:	89 eb                	mov    %ebp,%ebx
f0101251:	d3 e6                	shl    %cl,%esi
f0101253:	89 c1                	mov    %eax,%ecx
f0101255:	d3 eb                	shr    %cl,%ebx
f0101257:	09 de                	or     %ebx,%esi
f0101259:	89 f0                	mov    %esi,%eax
f010125b:	f7 74 24 08          	divl   0x8(%esp)
f010125f:	89 d6                	mov    %edx,%esi
f0101261:	89 c3                	mov    %eax,%ebx
f0101263:	f7 64 24 0c          	mull   0xc(%esp)
f0101267:	39 d6                	cmp    %edx,%esi
f0101269:	72 15                	jb     f0101280 <__udivdi3+0x100>
f010126b:	89 f9                	mov    %edi,%ecx
f010126d:	d3 e5                	shl    %cl,%ebp
f010126f:	39 c5                	cmp    %eax,%ebp
f0101271:	73 04                	jae    f0101277 <__udivdi3+0xf7>
f0101273:	39 d6                	cmp    %edx,%esi
f0101275:	74 09                	je     f0101280 <__udivdi3+0x100>
f0101277:	89 d8                	mov    %ebx,%eax
f0101279:	31 ff                	xor    %edi,%edi
f010127b:	e9 40 ff ff ff       	jmp    f01011c0 <__udivdi3+0x40>
f0101280:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101283:	31 ff                	xor    %edi,%edi
f0101285:	e9 36 ff ff ff       	jmp    f01011c0 <__udivdi3+0x40>
f010128a:	66 90                	xchg   %ax,%ax
f010128c:	66 90                	xchg   %ax,%ax
f010128e:	66 90                	xchg   %ax,%ax

f0101290 <__umoddi3>:
f0101290:	f3 0f 1e fb          	endbr32 
f0101294:	55                   	push   %ebp
f0101295:	57                   	push   %edi
f0101296:	56                   	push   %esi
f0101297:	53                   	push   %ebx
f0101298:	83 ec 1c             	sub    $0x1c,%esp
f010129b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010129f:	8b 74 24 30          	mov    0x30(%esp),%esi
f01012a3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01012a7:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01012ab:	85 c0                	test   %eax,%eax
f01012ad:	75 19                	jne    f01012c8 <__umoddi3+0x38>
f01012af:	39 df                	cmp    %ebx,%edi
f01012b1:	76 5d                	jbe    f0101310 <__umoddi3+0x80>
f01012b3:	89 f0                	mov    %esi,%eax
f01012b5:	89 da                	mov    %ebx,%edx
f01012b7:	f7 f7                	div    %edi
f01012b9:	89 d0                	mov    %edx,%eax
f01012bb:	31 d2                	xor    %edx,%edx
f01012bd:	83 c4 1c             	add    $0x1c,%esp
f01012c0:	5b                   	pop    %ebx
f01012c1:	5e                   	pop    %esi
f01012c2:	5f                   	pop    %edi
f01012c3:	5d                   	pop    %ebp
f01012c4:	c3                   	ret    
f01012c5:	8d 76 00             	lea    0x0(%esi),%esi
f01012c8:	89 f2                	mov    %esi,%edx
f01012ca:	39 d8                	cmp    %ebx,%eax
f01012cc:	76 12                	jbe    f01012e0 <__umoddi3+0x50>
f01012ce:	89 f0                	mov    %esi,%eax
f01012d0:	89 da                	mov    %ebx,%edx
f01012d2:	83 c4 1c             	add    $0x1c,%esp
f01012d5:	5b                   	pop    %ebx
f01012d6:	5e                   	pop    %esi
f01012d7:	5f                   	pop    %edi
f01012d8:	5d                   	pop    %ebp
f01012d9:	c3                   	ret    
f01012da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01012e0:	0f bd e8             	bsr    %eax,%ebp
f01012e3:	83 f5 1f             	xor    $0x1f,%ebp
f01012e6:	75 50                	jne    f0101338 <__umoddi3+0xa8>
f01012e8:	39 d8                	cmp    %ebx,%eax
f01012ea:	0f 82 e0 00 00 00    	jb     f01013d0 <__umoddi3+0x140>
f01012f0:	89 d9                	mov    %ebx,%ecx
f01012f2:	39 f7                	cmp    %esi,%edi
f01012f4:	0f 86 d6 00 00 00    	jbe    f01013d0 <__umoddi3+0x140>
f01012fa:	89 d0                	mov    %edx,%eax
f01012fc:	89 ca                	mov    %ecx,%edx
f01012fe:	83 c4 1c             	add    $0x1c,%esp
f0101301:	5b                   	pop    %ebx
f0101302:	5e                   	pop    %esi
f0101303:	5f                   	pop    %edi
f0101304:	5d                   	pop    %ebp
f0101305:	c3                   	ret    
f0101306:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010130d:	8d 76 00             	lea    0x0(%esi),%esi
f0101310:	89 fd                	mov    %edi,%ebp
f0101312:	85 ff                	test   %edi,%edi
f0101314:	75 0b                	jne    f0101321 <__umoddi3+0x91>
f0101316:	b8 01 00 00 00       	mov    $0x1,%eax
f010131b:	31 d2                	xor    %edx,%edx
f010131d:	f7 f7                	div    %edi
f010131f:	89 c5                	mov    %eax,%ebp
f0101321:	89 d8                	mov    %ebx,%eax
f0101323:	31 d2                	xor    %edx,%edx
f0101325:	f7 f5                	div    %ebp
f0101327:	89 f0                	mov    %esi,%eax
f0101329:	f7 f5                	div    %ebp
f010132b:	89 d0                	mov    %edx,%eax
f010132d:	31 d2                	xor    %edx,%edx
f010132f:	eb 8c                	jmp    f01012bd <__umoddi3+0x2d>
f0101331:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101338:	89 e9                	mov    %ebp,%ecx
f010133a:	ba 20 00 00 00       	mov    $0x20,%edx
f010133f:	29 ea                	sub    %ebp,%edx
f0101341:	d3 e0                	shl    %cl,%eax
f0101343:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101347:	89 d1                	mov    %edx,%ecx
f0101349:	89 f8                	mov    %edi,%eax
f010134b:	d3 e8                	shr    %cl,%eax
f010134d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101351:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101355:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101359:	09 c1                	or     %eax,%ecx
f010135b:	89 d8                	mov    %ebx,%eax
f010135d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101361:	89 e9                	mov    %ebp,%ecx
f0101363:	d3 e7                	shl    %cl,%edi
f0101365:	89 d1                	mov    %edx,%ecx
f0101367:	d3 e8                	shr    %cl,%eax
f0101369:	89 e9                	mov    %ebp,%ecx
f010136b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010136f:	d3 e3                	shl    %cl,%ebx
f0101371:	89 c7                	mov    %eax,%edi
f0101373:	89 d1                	mov    %edx,%ecx
f0101375:	89 f0                	mov    %esi,%eax
f0101377:	d3 e8                	shr    %cl,%eax
f0101379:	89 e9                	mov    %ebp,%ecx
f010137b:	89 fa                	mov    %edi,%edx
f010137d:	d3 e6                	shl    %cl,%esi
f010137f:	09 d8                	or     %ebx,%eax
f0101381:	f7 74 24 08          	divl   0x8(%esp)
f0101385:	89 d1                	mov    %edx,%ecx
f0101387:	89 f3                	mov    %esi,%ebx
f0101389:	f7 64 24 0c          	mull   0xc(%esp)
f010138d:	89 c6                	mov    %eax,%esi
f010138f:	89 d7                	mov    %edx,%edi
f0101391:	39 d1                	cmp    %edx,%ecx
f0101393:	72 06                	jb     f010139b <__umoddi3+0x10b>
f0101395:	75 10                	jne    f01013a7 <__umoddi3+0x117>
f0101397:	39 c3                	cmp    %eax,%ebx
f0101399:	73 0c                	jae    f01013a7 <__umoddi3+0x117>
f010139b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010139f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f01013a3:	89 d7                	mov    %edx,%edi
f01013a5:	89 c6                	mov    %eax,%esi
f01013a7:	89 ca                	mov    %ecx,%edx
f01013a9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01013ae:	29 f3                	sub    %esi,%ebx
f01013b0:	19 fa                	sbb    %edi,%edx
f01013b2:	89 d0                	mov    %edx,%eax
f01013b4:	d3 e0                	shl    %cl,%eax
f01013b6:	89 e9                	mov    %ebp,%ecx
f01013b8:	d3 eb                	shr    %cl,%ebx
f01013ba:	d3 ea                	shr    %cl,%edx
f01013bc:	09 d8                	or     %ebx,%eax
f01013be:	83 c4 1c             	add    $0x1c,%esp
f01013c1:	5b                   	pop    %ebx
f01013c2:	5e                   	pop    %esi
f01013c3:	5f                   	pop    %edi
f01013c4:	5d                   	pop    %ebp
f01013c5:	c3                   	ret    
f01013c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01013cd:	8d 76 00             	lea    0x0(%esi),%esi
f01013d0:	29 fe                	sub    %edi,%esi
f01013d2:	19 c3                	sbb    %eax,%ebx
f01013d4:	89 f2                	mov    %esi,%edx
f01013d6:	89 d9                	mov    %ebx,%ecx
f01013d8:	e9 1d ff ff ff       	jmp    f01012fa <__umoddi3+0x6a>
