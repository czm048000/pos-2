
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
f0100015:	b8 00 30 11 00       	mov    $0x113000,%eax
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
f0100034:	bc 00 10 11 f0       	mov    $0xf0111000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/monitor.h>
#include <kern/console.h>

void
i386_init(void)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	53                   	push   %ebx
f0100048:	83 ec 08             	sub    $0x8,%esp
f010004b:	e8 4a 01 00 00       	call   f010019a <__x86.get_pc_thunk.bx>
f0100050:	81 c3 b8 22 01 00    	add    $0x122b8,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100056:	c7 c0 a0 46 11 f0    	mov    $0xf01146a0,%eax
f010005c:	c7 c2 60 40 11 f0    	mov    $0xf0114060,%edx
f0100062:	29 d0                	sub    %edx,%eax
f0100064:	50                   	push   %eax
f0100065:	6a 00                	push   $0x0
f0100067:	52                   	push   %edx
f0100068:	e8 7d 17 00 00       	call   f01017ea <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010006d:	e8 83 05 00 00       	call   f01005f5 <cons_init>

	cprintf("Hello POS!\n");
f0100072:	8d 83 58 f9 fe ff    	lea    -0x106a8(%ebx),%eax
f0100078:	89 04 24             	mov    %eax,(%esp)
f010007b:	e8 97 0b 00 00       	call   f0100c17 <cprintf>

	cprintf("    ___    ___     ___   \n");
f0100080:	8d 83 64 f9 fe ff    	lea    -0x1069c(%ebx),%eax
f0100086:	89 04 24             	mov    %eax,(%esp)
f0100089:	e8 89 0b 00 00       	call   f0100c17 <cprintf>
	cprintf("   | _ \\  / _ \\   / __|  \n");
f010008e:	8d 83 7f f9 fe ff    	lea    -0x10681(%ebx),%eax
f0100094:	89 04 24             	mov    %eax,(%esp)
f0100097:	e8 7b 0b 00 00       	call   f0100c17 <cprintf>
	cprintf("   |  _/ | (_) |  \\__ \\  \n");
f010009c:	8d 83 9a f9 fe ff    	lea    -0x10666(%ebx),%eax
f01000a2:	89 04 24             	mov    %eax,(%esp)
f01000a5:	e8 6d 0b 00 00       	call   f0100c17 <cprintf>
	cprintf("  _|_|_   \\___/   |___/  \n");
f01000aa:	8d 83 b5 f9 fe ff    	lea    -0x1064b(%ebx),%eax
f01000b0:	89 04 24             	mov    %eax,(%esp)
f01000b3:	e8 5f 0b 00 00       	call   f0100c17 <cprintf>
	cprintf("_| \"\"\" |_|\"\"\"\"\"|_|\"\"\"\"\"| \n");
f01000b8:	8d 83 d0 f9 fe ff    	lea    -0x10630(%ebx),%eax
f01000be:	89 04 24             	mov    %eax,(%esp)
f01000c1:	e8 51 0b 00 00       	call   f0100c17 <cprintf>
	cprintf("\"`-0-0-'\"`-0-0-'\"`-0-0-' \n");
f01000c6:	8d 83 eb f9 fe ff    	lea    -0x10615(%ebx),%eax
f01000cc:	89 04 24             	mov    %eax,(%esp)
f01000cf:	e8 43 0b 00 00       	call   f0100c17 <cprintf>
	// test_backtrace(5);

	// Drop into the kernel monitor.
	// while (1)
	// 	monitor(NULL);
}
f01000d4:	83 c4 10             	add    $0x10,%esp
f01000d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01000da:	c9                   	leave  
f01000db:	c3                   	ret    

f01000dc <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000dc:	f3 0f 1e fb          	endbr32 
f01000e0:	55                   	push   %ebp
f01000e1:	89 e5                	mov    %esp,%ebp
f01000e3:	57                   	push   %edi
f01000e4:	56                   	push   %esi
f01000e5:	53                   	push   %ebx
f01000e6:	83 ec 0c             	sub    $0xc,%esp
f01000e9:	e8 ac 00 00 00       	call   f010019a <__x86.get_pc_thunk.bx>
f01000ee:	81 c3 1a 22 01 00    	add    $0x1221a,%ebx
f01000f4:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f01000f7:	c7 c0 a4 46 11 f0    	mov    $0xf01146a4,%eax
f01000fd:	83 38 00             	cmpl   $0x0,(%eax)
f0100100:	74 0f                	je     f0100111 <_panic+0x35>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100102:	83 ec 0c             	sub    $0xc,%esp
f0100105:	6a 00                	push   $0x0
f0100107:	e8 7d 07 00 00       	call   f0100889 <monitor>
f010010c:	83 c4 10             	add    $0x10,%esp
f010010f:	eb f1                	jmp    f0100102 <_panic+0x26>
	panicstr = fmt;
f0100111:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100113:	fa                   	cli    
f0100114:	fc                   	cld    
	va_start(ap, fmt);
f0100115:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0100118:	83 ec 04             	sub    $0x4,%esp
f010011b:	ff 75 0c             	pushl  0xc(%ebp)
f010011e:	ff 75 08             	pushl  0x8(%ebp)
f0100121:	8d 83 06 fa fe ff    	lea    -0x105fa(%ebx),%eax
f0100127:	50                   	push   %eax
f0100128:	e8 ea 0a 00 00       	call   f0100c17 <cprintf>
	vcprintf(fmt, ap);
f010012d:	83 c4 08             	add    $0x8,%esp
f0100130:	56                   	push   %esi
f0100131:	57                   	push   %edi
f0100132:	e8 a5 0a 00 00       	call   f0100bdc <vcprintf>
	cprintf("\n");
f0100137:	8d 83 7d f9 fe ff    	lea    -0x10683(%ebx),%eax
f010013d:	89 04 24             	mov    %eax,(%esp)
f0100140:	e8 d2 0a 00 00       	call   f0100c17 <cprintf>
f0100145:	83 c4 10             	add    $0x10,%esp
f0100148:	eb b8                	jmp    f0100102 <_panic+0x26>

f010014a <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010014a:	f3 0f 1e fb          	endbr32 
f010014e:	55                   	push   %ebp
f010014f:	89 e5                	mov    %esp,%ebp
f0100151:	56                   	push   %esi
f0100152:	53                   	push   %ebx
f0100153:	e8 42 00 00 00       	call   f010019a <__x86.get_pc_thunk.bx>
f0100158:	81 c3 b0 21 01 00    	add    $0x121b0,%ebx
	va_list ap;

	va_start(ap, fmt);
f010015e:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100161:	83 ec 04             	sub    $0x4,%esp
f0100164:	ff 75 0c             	pushl  0xc(%ebp)
f0100167:	ff 75 08             	pushl  0x8(%ebp)
f010016a:	8d 83 1e fa fe ff    	lea    -0x105e2(%ebx),%eax
f0100170:	50                   	push   %eax
f0100171:	e8 a1 0a 00 00       	call   f0100c17 <cprintf>
	vcprintf(fmt, ap);
f0100176:	83 c4 08             	add    $0x8,%esp
f0100179:	56                   	push   %esi
f010017a:	ff 75 10             	pushl  0x10(%ebp)
f010017d:	e8 5a 0a 00 00       	call   f0100bdc <vcprintf>
	cprintf("\n");
f0100182:	8d 83 7d f9 fe ff    	lea    -0x10683(%ebx),%eax
f0100188:	89 04 24             	mov    %eax,(%esp)
f010018b:	e8 87 0a 00 00       	call   f0100c17 <cprintf>
	va_end(ap);
}
f0100190:	83 c4 10             	add    $0x10,%esp
f0100193:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100196:	5b                   	pop    %ebx
f0100197:	5e                   	pop    %esi
f0100198:	5d                   	pop    %ebp
f0100199:	c3                   	ret    

f010019a <__x86.get_pc_thunk.bx>:
f010019a:	8b 1c 24             	mov    (%esp),%ebx
f010019d:	c3                   	ret    

f010019e <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010019e:	f3 0f 1e fb          	endbr32 

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001a2:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001a7:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001a8:	a8 01                	test   $0x1,%al
f01001aa:	74 0a                	je     f01001b6 <serial_proc_data+0x18>
f01001ac:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001b1:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001b2:	0f b6 c0             	movzbl %al,%eax
f01001b5:	c3                   	ret    
		return -1;
f01001b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f01001bb:	c3                   	ret    

f01001bc <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001bc:	55                   	push   %ebp
f01001bd:	89 e5                	mov    %esp,%ebp
f01001bf:	57                   	push   %edi
f01001c0:	56                   	push   %esi
f01001c1:	53                   	push   %ebx
f01001c2:	83 ec 1c             	sub    $0x1c,%esp
f01001c5:	e8 88 05 00 00       	call   f0100752 <__x86.get_pc_thunk.si>
f01001ca:	81 c6 3e 21 01 00    	add    $0x1213e,%esi
f01001d0:	89 c7                	mov    %eax,%edi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f01001d2:	8d 1d 78 1d 00 00    	lea    0x1d78,%ebx
f01001d8:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f01001db:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01001de:	89 7d e4             	mov    %edi,-0x1c(%ebp)
	while ((c = (*proc)()) != -1) {
f01001e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01001e4:	ff d0                	call   *%eax
f01001e6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001e9:	74 2b                	je     f0100216 <cons_intr+0x5a>
		if (c == 0)
f01001eb:	85 c0                	test   %eax,%eax
f01001ed:	74 f2                	je     f01001e1 <cons_intr+0x25>
		cons.buf[cons.wpos++] = c;
f01001ef:	8b 8c 1e 04 02 00 00 	mov    0x204(%esi,%ebx,1),%ecx
f01001f6:	8d 51 01             	lea    0x1(%ecx),%edx
f01001f9:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01001fc:	88 04 0f             	mov    %al,(%edi,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001ff:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f0100205:	b8 00 00 00 00       	mov    $0x0,%eax
f010020a:	0f 44 d0             	cmove  %eax,%edx
f010020d:	89 94 1e 04 02 00 00 	mov    %edx,0x204(%esi,%ebx,1)
f0100214:	eb cb                	jmp    f01001e1 <cons_intr+0x25>
	}
}
f0100216:	83 c4 1c             	add    $0x1c,%esp
f0100219:	5b                   	pop    %ebx
f010021a:	5e                   	pop    %esi
f010021b:	5f                   	pop    %edi
f010021c:	5d                   	pop    %ebp
f010021d:	c3                   	ret    

f010021e <kbd_proc_data>:
{
f010021e:	f3 0f 1e fb          	endbr32 
f0100222:	55                   	push   %ebp
f0100223:	89 e5                	mov    %esp,%ebp
f0100225:	56                   	push   %esi
f0100226:	53                   	push   %ebx
f0100227:	e8 6e ff ff ff       	call   f010019a <__x86.get_pc_thunk.bx>
f010022c:	81 c3 dc 20 01 00    	add    $0x120dc,%ebx
f0100232:	ba 64 00 00 00       	mov    $0x64,%edx
f0100237:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100238:	a8 01                	test   $0x1,%al
f010023a:	0f 84 fb 00 00 00    	je     f010033b <kbd_proc_data+0x11d>
	if (stat & KBS_TERR)
f0100240:	a8 20                	test   $0x20,%al
f0100242:	0f 85 fa 00 00 00    	jne    f0100342 <kbd_proc_data+0x124>
f0100248:	ba 60 00 00 00       	mov    $0x60,%edx
f010024d:	ec                   	in     (%dx),%al
f010024e:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100250:	3c e0                	cmp    $0xe0,%al
f0100252:	74 64                	je     f01002b8 <kbd_proc_data+0x9a>
	} else if (data & 0x80) {
f0100254:	84 c0                	test   %al,%al
f0100256:	78 75                	js     f01002cd <kbd_proc_data+0xaf>
	} else if (shift & E0ESC) {
f0100258:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010025e:	f6 c1 40             	test   $0x40,%cl
f0100261:	74 0e                	je     f0100271 <kbd_proc_data+0x53>
		data |= 0x80;
f0100263:	83 c8 80             	or     $0xffffff80,%eax
f0100266:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100268:	83 e1 bf             	and    $0xffffffbf,%ecx
f010026b:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f0100271:	0f b6 d2             	movzbl %dl,%edx
f0100274:	0f b6 84 13 78 fb fe 	movzbl -0x10488(%ebx,%edx,1),%eax
f010027b:	ff 
f010027c:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f0100282:	0f b6 8c 13 78 fa fe 	movzbl -0x10588(%ebx,%edx,1),%ecx
f0100289:	ff 
f010028a:	31 c8                	xor    %ecx,%eax
f010028c:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100292:	89 c1                	mov    %eax,%ecx
f0100294:	83 e1 03             	and    $0x3,%ecx
f0100297:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f010029e:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002a2:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002a5:	a8 08                	test   $0x8,%al
f01002a7:	74 65                	je     f010030e <kbd_proc_data+0xf0>
		if ('a' <= c && c <= 'z')
f01002a9:	89 f2                	mov    %esi,%edx
f01002ab:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002ae:	83 f9 19             	cmp    $0x19,%ecx
f01002b1:	77 4f                	ja     f0100302 <kbd_proc_data+0xe4>
			c += 'A' - 'a';
f01002b3:	83 ee 20             	sub    $0x20,%esi
f01002b6:	eb 0c                	jmp    f01002c4 <kbd_proc_data+0xa6>
		shift |= E0ESC;
f01002b8:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002bf:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002c4:	89 f0                	mov    %esi,%eax
f01002c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01002c9:	5b                   	pop    %ebx
f01002ca:	5e                   	pop    %esi
f01002cb:	5d                   	pop    %ebp
f01002cc:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f01002cd:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f01002d3:	89 ce                	mov    %ecx,%esi
f01002d5:	83 e6 40             	and    $0x40,%esi
f01002d8:	83 e0 7f             	and    $0x7f,%eax
f01002db:	85 f6                	test   %esi,%esi
f01002dd:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002e0:	0f b6 d2             	movzbl %dl,%edx
f01002e3:	0f b6 84 13 78 fb fe 	movzbl -0x10488(%ebx,%edx,1),%eax
f01002ea:	ff 
f01002eb:	83 c8 40             	or     $0x40,%eax
f01002ee:	0f b6 c0             	movzbl %al,%eax
f01002f1:	f7 d0                	not    %eax
f01002f3:	21 c8                	and    %ecx,%eax
f01002f5:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f01002fb:	be 00 00 00 00       	mov    $0x0,%esi
f0100300:	eb c2                	jmp    f01002c4 <kbd_proc_data+0xa6>
		else if ('A' <= c && c <= 'Z')
f0100302:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100305:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100308:	83 fa 1a             	cmp    $0x1a,%edx
f010030b:	0f 42 f1             	cmovb  %ecx,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010030e:	f7 d0                	not    %eax
f0100310:	a8 06                	test   $0x6,%al
f0100312:	75 b0                	jne    f01002c4 <kbd_proc_data+0xa6>
f0100314:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f010031a:	75 a8                	jne    f01002c4 <kbd_proc_data+0xa6>
		cprintf("Rebooting!\n");
f010031c:	83 ec 0c             	sub    $0xc,%esp
f010031f:	8d 83 38 fa fe ff    	lea    -0x105c8(%ebx),%eax
f0100325:	50                   	push   %eax
f0100326:	e8 ec 08 00 00       	call   f0100c17 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010032b:	b8 03 00 00 00       	mov    $0x3,%eax
f0100330:	ba 92 00 00 00       	mov    $0x92,%edx
f0100335:	ee                   	out    %al,(%dx)
}
f0100336:	83 c4 10             	add    $0x10,%esp
f0100339:	eb 89                	jmp    f01002c4 <kbd_proc_data+0xa6>
		return -1;
f010033b:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100340:	eb 82                	jmp    f01002c4 <kbd_proc_data+0xa6>
		return -1;
f0100342:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100347:	e9 78 ff ff ff       	jmp    f01002c4 <kbd_proc_data+0xa6>

f010034c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010034c:	55                   	push   %ebp
f010034d:	89 e5                	mov    %esp,%ebp
f010034f:	57                   	push   %edi
f0100350:	56                   	push   %esi
f0100351:	53                   	push   %ebx
f0100352:	83 ec 1c             	sub    $0x1c,%esp
f0100355:	e8 40 fe ff ff       	call   f010019a <__x86.get_pc_thunk.bx>
f010035a:	81 c3 ae 1f 01 00    	add    $0x11fae,%ebx
f0100360:	89 c7                	mov    %eax,%edi
	for (i = 0;
f0100362:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100367:	b9 84 00 00 00       	mov    $0x84,%ecx
f010036c:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100371:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100372:	a8 20                	test   $0x20,%al
f0100374:	75 13                	jne    f0100389 <cons_putc+0x3d>
f0100376:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010037c:	7f 0b                	jg     f0100389 <cons_putc+0x3d>
f010037e:	89 ca                	mov    %ecx,%edx
f0100380:	ec                   	in     (%dx),%al
f0100381:	ec                   	in     (%dx),%al
f0100382:	ec                   	in     (%dx),%al
f0100383:	ec                   	in     (%dx),%al
	     i++)
f0100384:	83 c6 01             	add    $0x1,%esi
f0100387:	eb e3                	jmp    f010036c <cons_putc+0x20>
	outb(COM1 + COM_TX, c);
f0100389:	89 f8                	mov    %edi,%eax
f010038b:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010038e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100393:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100394:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100399:	b9 84 00 00 00       	mov    $0x84,%ecx
f010039e:	ba 79 03 00 00       	mov    $0x379,%edx
f01003a3:	ec                   	in     (%dx),%al
f01003a4:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003aa:	7f 0f                	jg     f01003bb <cons_putc+0x6f>
f01003ac:	84 c0                	test   %al,%al
f01003ae:	78 0b                	js     f01003bb <cons_putc+0x6f>
f01003b0:	89 ca                	mov    %ecx,%edx
f01003b2:	ec                   	in     (%dx),%al
f01003b3:	ec                   	in     (%dx),%al
f01003b4:	ec                   	in     (%dx),%al
f01003b5:	ec                   	in     (%dx),%al
f01003b6:	83 c6 01             	add    $0x1,%esi
f01003b9:	eb e3                	jmp    f010039e <cons_putc+0x52>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003bb:	ba 78 03 00 00       	mov    $0x378,%edx
f01003c0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01003c4:	ee                   	out    %al,(%dx)
f01003c5:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003ca:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003cf:	ee                   	out    %al,(%dx)
f01003d0:	b8 08 00 00 00       	mov    $0x8,%eax
f01003d5:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f01003d6:	89 f8                	mov    %edi,%eax
f01003d8:	80 cc 07             	or     $0x7,%ah
f01003db:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f01003e1:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f01003e4:	89 f8                	mov    %edi,%eax
f01003e6:	0f b6 c0             	movzbl %al,%eax
f01003e9:	89 f9                	mov    %edi,%ecx
f01003eb:	80 f9 0a             	cmp    $0xa,%cl
f01003ee:	0f 84 e2 00 00 00    	je     f01004d6 <cons_putc+0x18a>
f01003f4:	83 f8 0a             	cmp    $0xa,%eax
f01003f7:	7f 46                	jg     f010043f <cons_putc+0xf3>
f01003f9:	83 f8 08             	cmp    $0x8,%eax
f01003fc:	0f 84 a8 00 00 00    	je     f01004aa <cons_putc+0x15e>
f0100402:	83 f8 09             	cmp    $0x9,%eax
f0100405:	0f 85 d8 00 00 00    	jne    f01004e3 <cons_putc+0x197>
		cons_putc(' ');
f010040b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100410:	e8 37 ff ff ff       	call   f010034c <cons_putc>
		cons_putc(' ');
f0100415:	b8 20 00 00 00       	mov    $0x20,%eax
f010041a:	e8 2d ff ff ff       	call   f010034c <cons_putc>
		cons_putc(' ');
f010041f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100424:	e8 23 ff ff ff       	call   f010034c <cons_putc>
		cons_putc(' ');
f0100429:	b8 20 00 00 00       	mov    $0x20,%eax
f010042e:	e8 19 ff ff ff       	call   f010034c <cons_putc>
		cons_putc(' ');
f0100433:	b8 20 00 00 00       	mov    $0x20,%eax
f0100438:	e8 0f ff ff ff       	call   f010034c <cons_putc>
		break;
f010043d:	eb 26                	jmp    f0100465 <cons_putc+0x119>
	switch (c & 0xff) {
f010043f:	83 f8 0d             	cmp    $0xd,%eax
f0100442:	0f 85 9b 00 00 00    	jne    f01004e3 <cons_putc+0x197>
		crt_pos -= (crt_pos % CRT_COLS);
f0100448:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f010044f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100455:	c1 e8 16             	shr    $0x16,%eax
f0100458:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010045b:	c1 e0 04             	shl    $0x4,%eax
f010045e:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100465:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010046c:	cf 07 
f010046e:	0f 87 92 00 00 00    	ja     f0100506 <cons_putc+0x1ba>
	outb(addr_6845, 14);
f0100474:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f010047a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010047f:	89 ca                	mov    %ecx,%edx
f0100481:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100482:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f0100489:	8d 71 01             	lea    0x1(%ecx),%esi
f010048c:	89 d8                	mov    %ebx,%eax
f010048e:	66 c1 e8 08          	shr    $0x8,%ax
f0100492:	89 f2                	mov    %esi,%edx
f0100494:	ee                   	out    %al,(%dx)
f0100495:	b8 0f 00 00 00       	mov    $0xf,%eax
f010049a:	89 ca                	mov    %ecx,%edx
f010049c:	ee                   	out    %al,(%dx)
f010049d:	89 d8                	mov    %ebx,%eax
f010049f:	89 f2                	mov    %esi,%edx
f01004a1:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004a5:	5b                   	pop    %ebx
f01004a6:	5e                   	pop    %esi
f01004a7:	5f                   	pop    %edi
f01004a8:	5d                   	pop    %ebp
f01004a9:	c3                   	ret    
		if (crt_pos > 0) {
f01004aa:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01004b1:	66 85 c0             	test   %ax,%ax
f01004b4:	74 be                	je     f0100474 <cons_putc+0x128>
			crt_pos--;
f01004b6:	83 e8 01             	sub    $0x1,%eax
f01004b9:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004c0:	0f b7 c0             	movzwl %ax,%eax
f01004c3:	89 fa                	mov    %edi,%edx
f01004c5:	b2 00                	mov    $0x0,%dl
f01004c7:	83 ca 20             	or     $0x20,%edx
f01004ca:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004d0:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004d4:	eb 8f                	jmp    f0100465 <cons_putc+0x119>
		crt_pos += CRT_COLS;
f01004d6:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004dd:	50 
f01004de:	e9 65 ff ff ff       	jmp    f0100448 <cons_putc+0xfc>
		crt_buf[crt_pos++] = c;		/* write the character */
f01004e3:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f01004ea:	8d 50 01             	lea    0x1(%eax),%edx
f01004ed:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f01004f4:	0f b7 c0             	movzwl %ax,%eax
f01004f7:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f01004fd:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
f0100501:	e9 5f ff ff ff       	jmp    f0100465 <cons_putc+0x119>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100506:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010050c:	83 ec 04             	sub    $0x4,%esp
f010050f:	68 00 0f 00 00       	push   $0xf00
f0100514:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010051a:	52                   	push   %edx
f010051b:	50                   	push   %eax
f010051c:	e8 15 13 00 00       	call   f0101836 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100521:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f0100527:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010052d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100533:	83 c4 10             	add    $0x10,%esp
f0100536:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010053b:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010053e:	39 d0                	cmp    %edx,%eax
f0100540:	75 f4                	jne    f0100536 <cons_putc+0x1ea>
		crt_pos -= CRT_COLS;
f0100542:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f0100549:	50 
f010054a:	e9 25 ff ff ff       	jmp    f0100474 <cons_putc+0x128>

f010054f <serial_intr>:
{
f010054f:	f3 0f 1e fb          	endbr32 
f0100553:	e8 f6 01 00 00       	call   f010074e <__x86.get_pc_thunk.ax>
f0100558:	05 b0 1d 01 00       	add    $0x11db0,%eax
	if (serial_exists)
f010055d:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100564:	75 01                	jne    f0100567 <serial_intr+0x18>
f0100566:	c3                   	ret    
{
f0100567:	55                   	push   %ebp
f0100568:	89 e5                	mov    %esp,%ebp
f010056a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010056d:	8d 80 96 de fe ff    	lea    -0x1216a(%eax),%eax
f0100573:	e8 44 fc ff ff       	call   f01001bc <cons_intr>
}
f0100578:	c9                   	leave  
f0100579:	c3                   	ret    

f010057a <kbd_intr>:
{
f010057a:	f3 0f 1e fb          	endbr32 
f010057e:	55                   	push   %ebp
f010057f:	89 e5                	mov    %esp,%ebp
f0100581:	83 ec 08             	sub    $0x8,%esp
f0100584:	e8 c5 01 00 00       	call   f010074e <__x86.get_pc_thunk.ax>
f0100589:	05 7f 1d 01 00       	add    $0x11d7f,%eax
	cons_intr(kbd_proc_data);
f010058e:	8d 80 16 df fe ff    	lea    -0x120ea(%eax),%eax
f0100594:	e8 23 fc ff ff       	call   f01001bc <cons_intr>
}
f0100599:	c9                   	leave  
f010059a:	c3                   	ret    

f010059b <cons_getc>:
{
f010059b:	f3 0f 1e fb          	endbr32 
f010059f:	55                   	push   %ebp
f01005a0:	89 e5                	mov    %esp,%ebp
f01005a2:	53                   	push   %ebx
f01005a3:	83 ec 04             	sub    $0x4,%esp
f01005a6:	e8 ef fb ff ff       	call   f010019a <__x86.get_pc_thunk.bx>
f01005ab:	81 c3 5d 1d 01 00    	add    $0x11d5d,%ebx
	serial_intr();
f01005b1:	e8 99 ff ff ff       	call   f010054f <serial_intr>
	kbd_intr();
f01005b6:	e8 bf ff ff ff       	call   f010057a <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005bb:	8b 83 78 1f 00 00    	mov    0x1f78(%ebx),%eax
	return 0;
f01005c1:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f01005c6:	3b 83 7c 1f 00 00    	cmp    0x1f7c(%ebx),%eax
f01005cc:	74 1f                	je     f01005ed <cons_getc+0x52>
		c = cons.buf[cons.rpos++];
f01005ce:	8d 48 01             	lea    0x1(%eax),%ecx
f01005d1:	0f b6 94 03 78 1d 00 	movzbl 0x1d78(%ebx,%eax,1),%edx
f01005d8:	00 
			cons.rpos = 0;
f01005d9:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005df:	b8 00 00 00 00       	mov    $0x0,%eax
f01005e4:	0f 44 c8             	cmove  %eax,%ecx
f01005e7:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
}
f01005ed:	89 d0                	mov    %edx,%eax
f01005ef:	83 c4 04             	add    $0x4,%esp
f01005f2:	5b                   	pop    %ebx
f01005f3:	5d                   	pop    %ebp
f01005f4:	c3                   	ret    

f01005f5 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005f5:	f3 0f 1e fb          	endbr32 
f01005f9:	55                   	push   %ebp
f01005fa:	89 e5                	mov    %esp,%ebp
f01005fc:	57                   	push   %edi
f01005fd:	56                   	push   %esi
f01005fe:	53                   	push   %ebx
f01005ff:	83 ec 1c             	sub    $0x1c,%esp
f0100602:	e8 93 fb ff ff       	call   f010019a <__x86.get_pc_thunk.bx>
f0100607:	81 c3 01 1d 01 00    	add    $0x11d01,%ebx
	was = *cp;
f010060d:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100614:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010061b:	5a a5 
	if (*cp != 0xA55A) {
f010061d:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100624:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100628:	0f 84 bc 00 00 00    	je     f01006ea <cons_init+0xf5>
		addr_6845 = MONO_BASE;
f010062e:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f0100635:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100638:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f010063f:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f0100645:	b8 0e 00 00 00       	mov    $0xe,%eax
f010064a:	89 fa                	mov    %edi,%edx
f010064c:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010064d:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100650:	89 ca                	mov    %ecx,%edx
f0100652:	ec                   	in     (%dx),%al
f0100653:	0f b6 f0             	movzbl %al,%esi
f0100656:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100659:	b8 0f 00 00 00       	mov    $0xf,%eax
f010065e:	89 fa                	mov    %edi,%edx
f0100660:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100661:	89 ca                	mov    %ecx,%edx
f0100663:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f0100664:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100667:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f010066d:	0f b6 c0             	movzbl %al,%eax
f0100670:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f0100672:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100679:	b9 00 00 00 00       	mov    $0x0,%ecx
f010067e:	89 c8                	mov    %ecx,%eax
f0100680:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100685:	ee                   	out    %al,(%dx)
f0100686:	bf fb 03 00 00       	mov    $0x3fb,%edi
f010068b:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100690:	89 fa                	mov    %edi,%edx
f0100692:	ee                   	out    %al,(%dx)
f0100693:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100698:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010069d:	ee                   	out    %al,(%dx)
f010069e:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006a3:	89 c8                	mov    %ecx,%eax
f01006a5:	89 f2                	mov    %esi,%edx
f01006a7:	ee                   	out    %al,(%dx)
f01006a8:	b8 03 00 00 00       	mov    $0x3,%eax
f01006ad:	89 fa                	mov    %edi,%edx
f01006af:	ee                   	out    %al,(%dx)
f01006b0:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006b5:	89 c8                	mov    %ecx,%eax
f01006b7:	ee                   	out    %al,(%dx)
f01006b8:	b8 01 00 00 00       	mov    $0x1,%eax
f01006bd:	89 f2                	mov    %esi,%edx
f01006bf:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c0:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006c5:	ec                   	in     (%dx),%al
f01006c6:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006c8:	3c ff                	cmp    $0xff,%al
f01006ca:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006d1:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006d6:	ec                   	in     (%dx),%al
f01006d7:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006dc:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006dd:	80 f9 ff             	cmp    $0xff,%cl
f01006e0:	74 25                	je     f0100707 <cons_init+0x112>
		cprintf("Serial port does not exist!\n");
}
f01006e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006e5:	5b                   	pop    %ebx
f01006e6:	5e                   	pop    %esi
f01006e7:	5f                   	pop    %edi
f01006e8:	5d                   	pop    %ebp
f01006e9:	c3                   	ret    
		*cp = was;
f01006ea:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006f1:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f01006f8:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006fb:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f0100702:	e9 38 ff ff ff       	jmp    f010063f <cons_init+0x4a>
		cprintf("Serial port does not exist!\n");
f0100707:	83 ec 0c             	sub    $0xc,%esp
f010070a:	8d 83 44 fa fe ff    	lea    -0x105bc(%ebx),%eax
f0100710:	50                   	push   %eax
f0100711:	e8 01 05 00 00       	call   f0100c17 <cprintf>
f0100716:	83 c4 10             	add    $0x10,%esp
}
f0100719:	eb c7                	jmp    f01006e2 <cons_init+0xed>

f010071b <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010071b:	f3 0f 1e fb          	endbr32 
f010071f:	55                   	push   %ebp
f0100720:	89 e5                	mov    %esp,%ebp
f0100722:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100725:	8b 45 08             	mov    0x8(%ebp),%eax
f0100728:	e8 1f fc ff ff       	call   f010034c <cons_putc>
}
f010072d:	c9                   	leave  
f010072e:	c3                   	ret    

f010072f <getchar>:

int
getchar(void)
{
f010072f:	f3 0f 1e fb          	endbr32 
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100739:	e8 5d fe ff ff       	call   f010059b <cons_getc>
f010073e:	85 c0                	test   %eax,%eax
f0100740:	74 f7                	je     f0100739 <getchar+0xa>
		/* do nothing */;
	return c;
}
f0100742:	c9                   	leave  
f0100743:	c3                   	ret    

f0100744 <iscons>:

int
iscons(int fdnum)
{
f0100744:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f0100748:	b8 01 00 00 00       	mov    $0x1,%eax
f010074d:	c3                   	ret    

f010074e <__x86.get_pc_thunk.ax>:
f010074e:	8b 04 24             	mov    (%esp),%eax
f0100751:	c3                   	ret    

f0100752 <__x86.get_pc_thunk.si>:
f0100752:	8b 34 24             	mov    (%esp),%esi
f0100755:	c3                   	ret    

f0100756 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100756:	f3 0f 1e fb          	endbr32 
f010075a:	55                   	push   %ebp
f010075b:	89 e5                	mov    %esp,%ebp
f010075d:	56                   	push   %esi
f010075e:	53                   	push   %ebx
f010075f:	e8 36 fa ff ff       	call   f010019a <__x86.get_pc_thunk.bx>
f0100764:	81 c3 a4 1b 01 00    	add    $0x11ba4,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010076a:	83 ec 04             	sub    $0x4,%esp
f010076d:	8d 83 78 fc fe ff    	lea    -0x10388(%ebx),%eax
f0100773:	50                   	push   %eax
f0100774:	8d 83 96 fc fe ff    	lea    -0x1036a(%ebx),%eax
f010077a:	50                   	push   %eax
f010077b:	8d b3 9b fc fe ff    	lea    -0x10365(%ebx),%esi
f0100781:	56                   	push   %esi
f0100782:	e8 90 04 00 00       	call   f0100c17 <cprintf>
f0100787:	83 c4 0c             	add    $0xc,%esp
f010078a:	8d 83 04 fd fe ff    	lea    -0x102fc(%ebx),%eax
f0100790:	50                   	push   %eax
f0100791:	8d 83 a4 fc fe ff    	lea    -0x1035c(%ebx),%eax
f0100797:	50                   	push   %eax
f0100798:	56                   	push   %esi
f0100799:	e8 79 04 00 00       	call   f0100c17 <cprintf>
	return 0;
}
f010079e:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007a6:	5b                   	pop    %ebx
f01007a7:	5e                   	pop    %esi
f01007a8:	5d                   	pop    %ebp
f01007a9:	c3                   	ret    

f01007aa <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007aa:	f3 0f 1e fb          	endbr32 
f01007ae:	55                   	push   %ebp
f01007af:	89 e5                	mov    %esp,%ebp
f01007b1:	57                   	push   %edi
f01007b2:	56                   	push   %esi
f01007b3:	53                   	push   %ebx
f01007b4:	83 ec 18             	sub    $0x18,%esp
f01007b7:	e8 de f9 ff ff       	call   f010019a <__x86.get_pc_thunk.bx>
f01007bc:	81 c3 4c 1b 01 00    	add    $0x11b4c,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c2:	8d 83 ad fc fe ff    	lea    -0x10353(%ebx),%eax
f01007c8:	50                   	push   %eax
f01007c9:	e8 49 04 00 00       	call   f0100c17 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ce:	83 c4 08             	add    $0x8,%esp
f01007d1:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007d7:	8d 83 2c fd fe ff    	lea    -0x102d4(%ebx),%eax
f01007dd:	50                   	push   %eax
f01007de:	e8 34 04 00 00       	call   f0100c17 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e3:	83 c4 0c             	add    $0xc,%esp
f01007e6:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007ec:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007f2:	50                   	push   %eax
f01007f3:	57                   	push   %edi
f01007f4:	8d 83 54 fd fe ff    	lea    -0x102ac(%ebx),%eax
f01007fa:	50                   	push   %eax
f01007fb:	e8 17 04 00 00       	call   f0100c17 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100800:	83 c4 0c             	add    $0xc,%esp
f0100803:	c7 c0 5d 1c 10 f0    	mov    $0xf0101c5d,%eax
f0100809:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010080f:	52                   	push   %edx
f0100810:	50                   	push   %eax
f0100811:	8d 83 78 fd fe ff    	lea    -0x10288(%ebx),%eax
f0100817:	50                   	push   %eax
f0100818:	e8 fa 03 00 00       	call   f0100c17 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010081d:	83 c4 0c             	add    $0xc,%esp
f0100820:	c7 c0 60 40 11 f0    	mov    $0xf0114060,%eax
f0100826:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010082c:	52                   	push   %edx
f010082d:	50                   	push   %eax
f010082e:	8d 83 9c fd fe ff    	lea    -0x10264(%ebx),%eax
f0100834:	50                   	push   %eax
f0100835:	e8 dd 03 00 00       	call   f0100c17 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010083a:	83 c4 0c             	add    $0xc,%esp
f010083d:	c7 c6 a0 46 11 f0    	mov    $0xf01146a0,%esi
f0100843:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f0100849:	50                   	push   %eax
f010084a:	56                   	push   %esi
f010084b:	8d 83 c0 fd fe ff    	lea    -0x10240(%ebx),%eax
f0100851:	50                   	push   %eax
f0100852:	e8 c0 03 00 00       	call   f0100c17 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100857:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010085a:	29 fe                	sub    %edi,%esi
f010085c:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100862:	c1 fe 0a             	sar    $0xa,%esi
f0100865:	56                   	push   %esi
f0100866:	8d 83 e4 fd fe ff    	lea    -0x1021c(%ebx),%eax
f010086c:	50                   	push   %eax
f010086d:	e8 a5 03 00 00       	call   f0100c17 <cprintf>
	return 0;
}
f0100872:	b8 00 00 00 00       	mov    $0x0,%eax
f0100877:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010087a:	5b                   	pop    %ebx
f010087b:	5e                   	pop    %esi
f010087c:	5f                   	pop    %edi
f010087d:	5d                   	pop    %ebp
f010087e:	c3                   	ret    

f010087f <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010087f:	f3 0f 1e fb          	endbr32 
	// Your code here.
	return 0;
}
f0100883:	b8 00 00 00 00       	mov    $0x0,%eax
f0100888:	c3                   	ret    

f0100889 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100889:	f3 0f 1e fb          	endbr32 
f010088d:	55                   	push   %ebp
f010088e:	89 e5                	mov    %esp,%ebp
f0100890:	57                   	push   %edi
f0100891:	56                   	push   %esi
f0100892:	53                   	push   %ebx
f0100893:	83 ec 68             	sub    $0x68,%esp
f0100896:	e8 ff f8 ff ff       	call   f010019a <__x86.get_pc_thunk.bx>
f010089b:	81 c3 6d 1a 01 00    	add    $0x11a6d,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008a1:	8d 83 10 fe fe ff    	lea    -0x101f0(%ebx),%eax
f01008a7:	50                   	push   %eax
f01008a8:	e8 6a 03 00 00       	call   f0100c17 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008ad:	8d 83 34 fe fe ff    	lea    -0x101cc(%ebx),%eax
f01008b3:	89 04 24             	mov    %eax,(%esp)
f01008b6:	e8 5c 03 00 00       	call   f0100c17 <cprintf>
f01008bb:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f01008be:	8d 83 ca fc fe ff    	lea    -0x10336(%ebx),%eax
f01008c4:	89 45 a0             	mov    %eax,-0x60(%ebp)
f01008c7:	e9 dc 00 00 00       	jmp    f01009a8 <monitor+0x11f>
f01008cc:	83 ec 08             	sub    $0x8,%esp
f01008cf:	0f be c0             	movsbl %al,%eax
f01008d2:	50                   	push   %eax
f01008d3:	ff 75 a0             	pushl  -0x60(%ebp)
f01008d6:	e8 ca 0e 00 00       	call   f01017a5 <strchr>
f01008db:	83 c4 10             	add    $0x10,%esp
f01008de:	85 c0                	test   %eax,%eax
f01008e0:	74 74                	je     f0100956 <monitor+0xcd>
			*buf++ = 0;
f01008e2:	c6 06 00             	movb   $0x0,(%esi)
f01008e5:	89 7d a4             	mov    %edi,-0x5c(%ebp)
f01008e8:	8d 76 01             	lea    0x1(%esi),%esi
f01008eb:	8b 7d a4             	mov    -0x5c(%ebp),%edi
		while (*buf && strchr(WHITESPACE, *buf))
f01008ee:	0f b6 06             	movzbl (%esi),%eax
f01008f1:	84 c0                	test   %al,%al
f01008f3:	75 d7                	jne    f01008cc <monitor+0x43>
	argv[argc] = 0;
f01008f5:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
f01008fc:	00 
	if (argc == 0)
f01008fd:	85 ff                	test   %edi,%edi
f01008ff:	0f 84 a3 00 00 00    	je     f01009a8 <monitor+0x11f>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100905:	83 ec 08             	sub    $0x8,%esp
f0100908:	8d 83 96 fc fe ff    	lea    -0x1036a(%ebx),%eax
f010090e:	50                   	push   %eax
f010090f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100912:	e8 28 0e 00 00       	call   f010173f <strcmp>
f0100917:	83 c4 10             	add    $0x10,%esp
f010091a:	85 c0                	test   %eax,%eax
f010091c:	0f 84 b4 00 00 00    	je     f01009d6 <monitor+0x14d>
f0100922:	83 ec 08             	sub    $0x8,%esp
f0100925:	8d 83 a4 fc fe ff    	lea    -0x1035c(%ebx),%eax
f010092b:	50                   	push   %eax
f010092c:	ff 75 a8             	pushl  -0x58(%ebp)
f010092f:	e8 0b 0e 00 00       	call   f010173f <strcmp>
f0100934:	83 c4 10             	add    $0x10,%esp
f0100937:	85 c0                	test   %eax,%eax
f0100939:	0f 84 92 00 00 00    	je     f01009d1 <monitor+0x148>
	cprintf("Unknown command '%s'\n", argv[0]);
f010093f:	83 ec 08             	sub    $0x8,%esp
f0100942:	ff 75 a8             	pushl  -0x58(%ebp)
f0100945:	8d 83 ec fc fe ff    	lea    -0x10314(%ebx),%eax
f010094b:	50                   	push   %eax
f010094c:	e8 c6 02 00 00       	call   f0100c17 <cprintf>
	return 0;
f0100951:	83 c4 10             	add    $0x10,%esp
f0100954:	eb 52                	jmp    f01009a8 <monitor+0x11f>
		if (*buf == 0)
f0100956:	80 3e 00             	cmpb   $0x0,(%esi)
f0100959:	74 9a                	je     f01008f5 <monitor+0x6c>
		if (argc == MAXARGS-1) {
f010095b:	83 ff 0f             	cmp    $0xf,%edi
f010095e:	74 34                	je     f0100994 <monitor+0x10b>
		argv[argc++] = buf;
f0100960:	8d 47 01             	lea    0x1(%edi),%eax
f0100963:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100966:	89 74 bd a8          	mov    %esi,-0x58(%ebp,%edi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f010096a:	0f b6 06             	movzbl (%esi),%eax
f010096d:	84 c0                	test   %al,%al
f010096f:	0f 84 76 ff ff ff    	je     f01008eb <monitor+0x62>
f0100975:	83 ec 08             	sub    $0x8,%esp
f0100978:	0f be c0             	movsbl %al,%eax
f010097b:	50                   	push   %eax
f010097c:	ff 75 a0             	pushl  -0x60(%ebp)
f010097f:	e8 21 0e 00 00       	call   f01017a5 <strchr>
f0100984:	83 c4 10             	add    $0x10,%esp
f0100987:	85 c0                	test   %eax,%eax
f0100989:	0f 85 5c ff ff ff    	jne    f01008eb <monitor+0x62>
			buf++;
f010098f:	83 c6 01             	add    $0x1,%esi
f0100992:	eb d6                	jmp    f010096a <monitor+0xe1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100994:	83 ec 08             	sub    $0x8,%esp
f0100997:	6a 10                	push   $0x10
f0100999:	8d 83 cf fc fe ff    	lea    -0x10331(%ebx),%eax
f010099f:	50                   	push   %eax
f01009a0:	e8 72 02 00 00       	call   f0100c17 <cprintf>
			return 0;
f01009a5:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01009a8:	8d bb c6 fc fe ff    	lea    -0x1033a(%ebx),%edi
f01009ae:	83 ec 0c             	sub    $0xc,%esp
f01009b1:	57                   	push   %edi
f01009b2:	e8 7d 0b 00 00       	call   f0101534 <readline>
f01009b7:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f01009b9:	83 c4 10             	add    $0x10,%esp
f01009bc:	85 c0                	test   %eax,%eax
f01009be:	74 ee                	je     f01009ae <monitor+0x125>
	argv[argc] = 0;
f01009c0:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009c7:	bf 00 00 00 00       	mov    $0x0,%edi
f01009cc:	e9 1d ff ff ff       	jmp    f01008ee <monitor+0x65>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009d1:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f01009d6:	83 ec 04             	sub    $0x4,%esp
f01009d9:	8d 04 40             	lea    (%eax,%eax,2),%eax
f01009dc:	ff 75 08             	pushl  0x8(%ebp)
f01009df:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009e2:	52                   	push   %edx
f01009e3:	57                   	push   %edi
f01009e4:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f01009eb:	83 c4 10             	add    $0x10,%esp
f01009ee:	85 c0                	test   %eax,%eax
f01009f0:	79 b6                	jns    f01009a8 <monitor+0x11f>
				break;
	}
}
f01009f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009f5:	5b                   	pop    %ebx
f01009f6:	5e                   	pop    %esi
f01009f7:	5f                   	pop    %edi
f01009f8:	5d                   	pop    %ebp
f01009f9:	c3                   	ret    

f01009fa <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01009fa:	55                   	push   %ebp
f01009fb:	89 e5                	mov    %esp,%ebp
f01009fd:	57                   	push   %edi
f01009fe:	56                   	push   %esi
f01009ff:	53                   	push   %ebx
f0100a00:	83 ec 18             	sub    $0x18,%esp
f0100a03:	e8 92 f7 ff ff       	call   f010019a <__x86.get_pc_thunk.bx>
f0100a08:	81 c3 00 19 01 00    	add    $0x11900,%ebx
f0100a0e:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a10:	50                   	push   %eax
f0100a11:	e8 6a 01 00 00       	call   f0100b80 <mc146818_read>
f0100a16:	89 c7                	mov    %eax,%edi
f0100a18:	83 c6 01             	add    $0x1,%esi
f0100a1b:	89 34 24             	mov    %esi,(%esp)
f0100a1e:	e8 5d 01 00 00       	call   f0100b80 <mc146818_read>
f0100a23:	c1 e0 08             	shl    $0x8,%eax
f0100a26:	09 f8                	or     %edi,%eax
}
f0100a28:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a2b:	5b                   	pop    %ebx
f0100a2c:	5e                   	pop    %esi
f0100a2d:	5f                   	pop    %edi
f0100a2e:	5d                   	pop    %ebp
f0100a2f:	c3                   	ret    

f0100a30 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100a30:	f3 0f 1e fb          	endbr32 
f0100a34:	55                   	push   %ebp
f0100a35:	89 e5                	mov    %esp,%ebp
f0100a37:	57                   	push   %edi
f0100a38:	56                   	push   %esi
f0100a39:	53                   	push   %ebx
f0100a3a:	83 ec 0c             	sub    $0xc,%esp
f0100a3d:	e8 58 f7 ff ff       	call   f010019a <__x86.get_pc_thunk.bx>
f0100a42:	81 c3 c6 18 01 00    	add    $0x118c6,%ebx
	basemem = nvram_read(NVRAM_BASELO);
f0100a48:	b8 15 00 00 00       	mov    $0x15,%eax
f0100a4d:	e8 a8 ff ff ff       	call   f01009fa <nvram_read>
f0100a52:	89 c6                	mov    %eax,%esi
	extmem = nvram_read(NVRAM_EXTLO);
f0100a54:	b8 17 00 00 00       	mov    $0x17,%eax
f0100a59:	e8 9c ff ff ff       	call   f01009fa <nvram_read>
f0100a5e:	89 c7                	mov    %eax,%edi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100a60:	b8 34 00 00 00       	mov    $0x34,%eax
f0100a65:	e8 90 ff ff ff       	call   f01009fa <nvram_read>
	if (ext16mem)
f0100a6a:	c1 e0 06             	shl    $0x6,%eax
f0100a6d:	74 40                	je     f0100aaf <mem_init+0x7f>
		totalmem = 16 * 1024 + ext16mem;
f0100a6f:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0100a74:	89 c1                	mov    %eax,%ecx
f0100a76:	c1 e9 02             	shr    $0x2,%ecx
f0100a79:	c7 c2 a8 46 11 f0    	mov    $0xf01146a8,%edx
f0100a7f:	89 0a                	mov    %ecx,(%edx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100a81:	89 c2                	mov    %eax,%edx
f0100a83:	29 f2                	sub    %esi,%edx
f0100a85:	52                   	push   %edx
f0100a86:	56                   	push   %esi
f0100a87:	50                   	push   %eax
f0100a88:	8d 83 5c fe fe ff    	lea    -0x101a4(%ebx),%eax
f0100a8e:	50                   	push   %eax
f0100a8f:	e8 83 01 00 00       	call   f0100c17 <cprintf>

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	// Remove this line when you're ready to test this function.
	panic("mem_init: This function is not finished\n");
f0100a94:	83 c4 0c             	add    $0xc,%esp
f0100a97:	8d 83 98 fe fe ff    	lea    -0x10168(%ebx),%eax
f0100a9d:	50                   	push   %eax
f0100a9e:	68 80 00 00 00       	push   $0x80
f0100aa3:	8d 83 c1 fe fe ff    	lea    -0x1013f(%ebx),%eax
f0100aa9:	50                   	push   %eax
f0100aaa:	e8 2d f6 ff ff       	call   f01000dc <_panic>
		totalmem = basemem;
f0100aaf:	89 f0                	mov    %esi,%eax
	else if (extmem)
f0100ab1:	85 ff                	test   %edi,%edi
f0100ab3:	74 bf                	je     f0100a74 <mem_init+0x44>
		totalmem = 1 * 1024 + extmem;
f0100ab5:	8d 87 00 04 00 00    	lea    0x400(%edi),%eax
f0100abb:	eb b7                	jmp    f0100a74 <mem_init+0x44>

f0100abd <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100abd:	f3 0f 1e fb          	endbr32 
f0100ac1:	55                   	push   %ebp
f0100ac2:	89 e5                	mov    %esp,%ebp
f0100ac4:	57                   	push   %edi
f0100ac5:	56                   	push   %esi
f0100ac6:	53                   	push   %ebx
f0100ac7:	83 ec 04             	sub    $0x4,%esp
f0100aca:	e8 83 fc ff ff       	call   f0100752 <__x86.get_pc_thunk.si>
f0100acf:	81 c6 39 18 01 00    	add    $0x11839,%esi
f0100ad5:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0100ad8:	8b 9e 90 1f 00 00    	mov    0x1f90(%esi),%ebx
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	for (i = 0; i < npages; i++) {
f0100ade:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ae3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ae8:	c7 c7 a8 46 11 f0    	mov    $0xf01146a8,%edi
		pages[i].pp_ref = 0;
f0100aee:	c7 c6 b0 46 11 f0    	mov    $0xf01146b0,%esi
	for (i = 0; i < npages; i++) {
f0100af4:	39 07                	cmp    %eax,(%edi)
f0100af6:	76 21                	jbe    f0100b19 <page_init+0x5c>
f0100af8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		pages[i].pp_ref = 0;
f0100aff:	89 d1                	mov    %edx,%ecx
f0100b01:	03 0e                	add    (%esi),%ecx
f0100b03:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100b09:	89 19                	mov    %ebx,(%ecx)
		page_free_list = &pages[i];
f0100b0b:	89 d3                	mov    %edx,%ebx
f0100b0d:	03 1e                	add    (%esi),%ebx
	for (i = 0; i < npages; i++) {
f0100b0f:	83 c0 01             	add    $0x1,%eax
f0100b12:	ba 01 00 00 00       	mov    $0x1,%edx
f0100b17:	eb db                	jmp    f0100af4 <page_init+0x37>
f0100b19:	84 d2                	test   %dl,%dl
f0100b1b:	74 09                	je     f0100b26 <page_init+0x69>
f0100b1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b20:	89 98 90 1f 00 00    	mov    %ebx,0x1f90(%eax)
	}
}
f0100b26:	83 c4 04             	add    $0x4,%esp
f0100b29:	5b                   	pop    %ebx
f0100b2a:	5e                   	pop    %esi
f0100b2b:	5f                   	pop    %edi
f0100b2c:	5d                   	pop    %ebp
f0100b2d:	c3                   	ret    

f0100b2e <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100b2e:	f3 0f 1e fb          	endbr32 
	// Fill this function in
	return 0;
}
f0100b32:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b37:	c3                   	ret    

f0100b38 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100b38:	f3 0f 1e fb          	endbr32 
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
}
f0100b3c:	c3                   	ret    

f0100b3d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100b3d:	f3 0f 1e fb          	endbr32 
f0100b41:	55                   	push   %ebp
f0100b42:	89 e5                	mov    %esp,%ebp
f0100b44:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100b47:	66 83 68 04 01       	subw   $0x1,0x4(%eax)
		page_free(pp);
}
f0100b4c:	5d                   	pop    %ebp
f0100b4d:	c3                   	ret    

f0100b4e <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100b4e:	f3 0f 1e fb          	endbr32 
	// Fill this function in
	return NULL;
}
f0100b52:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b57:	c3                   	ret    

f0100b58 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100b58:	f3 0f 1e fb          	endbr32 
	// Fill this function in
	return 0;
}
f0100b5c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b61:	c3                   	ret    

f0100b62 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100b62:	f3 0f 1e fb          	endbr32 
	// Fill this function in
	return NULL;
}
f0100b66:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b6b:	c3                   	ret    

f0100b6c <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100b6c:	f3 0f 1e fb          	endbr32 
	// Fill this function in
}
f0100b70:	c3                   	ret    

f0100b71 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100b71:	f3 0f 1e fb          	endbr32 
f0100b75:	55                   	push   %ebp
f0100b76:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100b78:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100b7b:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100b7e:	5d                   	pop    %ebp
f0100b7f:	c3                   	ret    

f0100b80 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0100b80:	f3 0f 1e fb          	endbr32 
f0100b84:	55                   	push   %ebp
f0100b85:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100b87:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b8a:	ba 70 00 00 00       	mov    $0x70,%edx
f0100b8f:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100b90:	ba 71 00 00 00       	mov    $0x71,%edx
f0100b95:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100b96:	0f b6 c0             	movzbl %al,%eax
}
f0100b99:	5d                   	pop    %ebp
f0100b9a:	c3                   	ret    

f0100b9b <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0100b9b:	f3 0f 1e fb          	endbr32 
f0100b9f:	55                   	push   %ebp
f0100ba0:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100ba2:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ba5:	ba 70 00 00 00       	mov    $0x70,%edx
f0100baa:	ee                   	out    %al,(%dx)
f0100bab:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bae:	ba 71 00 00 00       	mov    $0x71,%edx
f0100bb3:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100bb4:	5d                   	pop    %ebp
f0100bb5:	c3                   	ret    

f0100bb6 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100bb6:	f3 0f 1e fb          	endbr32 
f0100bba:	55                   	push   %ebp
f0100bbb:	89 e5                	mov    %esp,%ebp
f0100bbd:	53                   	push   %ebx
f0100bbe:	83 ec 10             	sub    $0x10,%esp
f0100bc1:	e8 d4 f5 ff ff       	call   f010019a <__x86.get_pc_thunk.bx>
f0100bc6:	81 c3 42 17 01 00    	add    $0x11742,%ebx
	cputchar(ch);
f0100bcc:	ff 75 08             	pushl  0x8(%ebp)
f0100bcf:	e8 47 fb ff ff       	call   f010071b <cputchar>
	*cnt++;
}
f0100bd4:	83 c4 10             	add    $0x10,%esp
f0100bd7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100bda:	c9                   	leave  
f0100bdb:	c3                   	ret    

f0100bdc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100bdc:	f3 0f 1e fb          	endbr32 
f0100be0:	55                   	push   %ebp
f0100be1:	89 e5                	mov    %esp,%ebp
f0100be3:	53                   	push   %ebx
f0100be4:	83 ec 14             	sub    $0x14,%esp
f0100be7:	e8 ae f5 ff ff       	call   f010019a <__x86.get_pc_thunk.bx>
f0100bec:	81 c3 1c 17 01 00    	add    $0x1171c,%ebx
	int cnt = 0;
f0100bf2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100bf9:	ff 75 0c             	pushl  0xc(%ebp)
f0100bfc:	ff 75 08             	pushl  0x8(%ebp)
f0100bff:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100c02:	50                   	push   %eax
f0100c03:	8d 83 ae e8 fe ff    	lea    -0x11752(%ebx),%eax
f0100c09:	50                   	push   %eax
f0100c0a:	e8 27 04 00 00       	call   f0101036 <vprintfmt>
	return cnt;
}
f0100c0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100c12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100c15:	c9                   	leave  
f0100c16:	c3                   	ret    

f0100c17 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100c17:	f3 0f 1e fb          	endbr32 
f0100c1b:	55                   	push   %ebp
f0100c1c:	89 e5                	mov    %esp,%ebp
f0100c1e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100c21:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100c24:	50                   	push   %eax
f0100c25:	ff 75 08             	pushl  0x8(%ebp)
f0100c28:	e8 af ff ff ff       	call   f0100bdc <vcprintf>
	va_end(ap);

	return cnt;
}
f0100c2d:	c9                   	leave  
f0100c2e:	c3                   	ret    

f0100c2f <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100c2f:	55                   	push   %ebp
f0100c30:	89 e5                	mov    %esp,%ebp
f0100c32:	57                   	push   %edi
f0100c33:	56                   	push   %esi
f0100c34:	53                   	push   %ebx
f0100c35:	83 ec 14             	sub    $0x14,%esp
f0100c38:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100c3b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100c3e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100c41:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100c44:	8b 1a                	mov    (%edx),%ebx
f0100c46:	8b 01                	mov    (%ecx),%eax
f0100c48:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100c4b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100c52:	eb 23                	jmp    f0100c77 <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100c54:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0100c57:	eb 1e                	jmp    f0100c77 <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100c59:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c5c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100c5f:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100c63:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100c66:	73 46                	jae    f0100cae <stab_binsearch+0x7f>
			*region_left = m;
f0100c68:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100c6b:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100c6d:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0100c70:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100c77:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100c7a:	7f 5f                	jg     f0100cdb <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0100c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100c7f:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0100c82:	89 d0                	mov    %edx,%eax
f0100c84:	c1 e8 1f             	shr    $0x1f,%eax
f0100c87:	01 d0                	add    %edx,%eax
f0100c89:	89 c7                	mov    %eax,%edi
f0100c8b:	d1 ff                	sar    %edi
f0100c8d:	83 e0 fe             	and    $0xfffffffe,%eax
f0100c90:	01 f8                	add    %edi,%eax
f0100c92:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100c95:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100c99:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0100c9b:	39 c3                	cmp    %eax,%ebx
f0100c9d:	7f b5                	jg     f0100c54 <stab_binsearch+0x25>
f0100c9f:	0f b6 0a             	movzbl (%edx),%ecx
f0100ca2:	83 ea 0c             	sub    $0xc,%edx
f0100ca5:	39 f1                	cmp    %esi,%ecx
f0100ca7:	74 b0                	je     f0100c59 <stab_binsearch+0x2a>
			m--;
f0100ca9:	83 e8 01             	sub    $0x1,%eax
f0100cac:	eb ed                	jmp    f0100c9b <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0100cae:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100cb1:	76 14                	jbe    f0100cc7 <stab_binsearch+0x98>
			*region_right = m - 1;
f0100cb3:	83 e8 01             	sub    $0x1,%eax
f0100cb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100cb9:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100cbc:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0100cbe:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100cc5:	eb b0                	jmp    f0100c77 <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100cc7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100cca:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0100ccc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100cd0:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0100cd2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100cd9:	eb 9c                	jmp    f0100c77 <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0100cdb:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100cdf:	75 15                	jne    f0100cf6 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0100ce1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ce4:	8b 00                	mov    (%eax),%eax
f0100ce6:	83 e8 01             	sub    $0x1,%eax
f0100ce9:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100cec:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0100cee:	83 c4 14             	add    $0x14,%esp
f0100cf1:	5b                   	pop    %ebx
f0100cf2:	5e                   	pop    %esi
f0100cf3:	5f                   	pop    %edi
f0100cf4:	5d                   	pop    %ebp
f0100cf5:	c3                   	ret    
		for (l = *region_right;
f0100cf6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cf9:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100cfb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100cfe:	8b 0f                	mov    (%edi),%ecx
f0100d00:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d03:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100d06:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f0100d0a:	eb 03                	jmp    f0100d0f <stab_binsearch+0xe0>
		     l--)
f0100d0c:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100d0f:	39 c1                	cmp    %eax,%ecx
f0100d11:	7d 0a                	jge    f0100d1d <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f0100d13:	0f b6 1a             	movzbl (%edx),%ebx
f0100d16:	83 ea 0c             	sub    $0xc,%edx
f0100d19:	39 f3                	cmp    %esi,%ebx
f0100d1b:	75 ef                	jne    f0100d0c <stab_binsearch+0xdd>
		*region_left = l;
f0100d1d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d20:	89 07                	mov    %eax,(%edi)
}
f0100d22:	eb ca                	jmp    f0100cee <stab_binsearch+0xbf>

f0100d24 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100d24:	f3 0f 1e fb          	endbr32 
f0100d28:	55                   	push   %ebp
f0100d29:	89 e5                	mov    %esp,%ebp
f0100d2b:	57                   	push   %edi
f0100d2c:	56                   	push   %esi
f0100d2d:	53                   	push   %ebx
f0100d2e:	83 ec 2c             	sub    $0x2c,%esp
f0100d31:	e8 fc 01 00 00       	call   f0100f32 <__x86.get_pc_thunk.cx>
f0100d36:	81 c1 d2 15 01 00    	add    $0x115d2,%ecx
f0100d3c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100d3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0100d42:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100d45:	8d 81 cd fe fe ff    	lea    -0x10133(%ecx),%eax
f0100d4b:	89 07                	mov    %eax,(%edi)
	info->eip_line = 0;
f0100d4d:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f0100d54:	89 47 08             	mov    %eax,0x8(%edi)
	info->eip_fn_namelen = 9;
f0100d57:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f0100d5e:	89 5f 10             	mov    %ebx,0x10(%edi)
	info->eip_fn_narg = 0;
f0100d61:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100d68:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0100d6e:	0f 86 f4 00 00 00    	jbe    f0100e68 <debuginfo_eip+0x144>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100d74:	c7 c0 a9 6e 10 f0    	mov    $0xf0106ea9,%eax
f0100d7a:	39 81 fc ff ff ff    	cmp    %eax,-0x4(%ecx)
f0100d80:	0f 86 88 01 00 00    	jbe    f0100f0e <debuginfo_eip+0x1ea>
f0100d86:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0100d89:	c7 c0 a7 85 10 f0    	mov    $0xf01085a7,%eax
f0100d8f:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100d93:	0f 85 7c 01 00 00    	jne    f0100f15 <debuginfo_eip+0x1f1>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100d99:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100da0:	c7 c0 f0 23 10 f0    	mov    $0xf01023f0,%eax
f0100da6:	c7 c2 a8 6e 10 f0    	mov    $0xf0106ea8,%edx
f0100dac:	29 c2                	sub    %eax,%edx
f0100dae:	c1 fa 02             	sar    $0x2,%edx
f0100db1:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100db7:	83 ea 01             	sub    $0x1,%edx
f0100dba:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100dbd:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100dc0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100dc3:	83 ec 08             	sub    $0x8,%esp
f0100dc6:	53                   	push   %ebx
f0100dc7:	6a 64                	push   $0x64
f0100dc9:	e8 61 fe ff ff       	call   f0100c2f <stab_binsearch>
	if (lfile == 0)
f0100dce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100dd1:	83 c4 10             	add    $0x10,%esp
f0100dd4:	85 c0                	test   %eax,%eax
f0100dd6:	0f 84 40 01 00 00    	je     f0100f1c <debuginfo_eip+0x1f8>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100ddc:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100ddf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100de2:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100de5:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100de8:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100deb:	83 ec 08             	sub    $0x8,%esp
f0100dee:	53                   	push   %ebx
f0100def:	6a 24                	push   $0x24
f0100df1:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0100df4:	c7 c0 f0 23 10 f0    	mov    $0xf01023f0,%eax
f0100dfa:	e8 30 fe ff ff       	call   f0100c2f <stab_binsearch>

	if (lfun <= rfun) {
f0100dff:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0100e02:	83 c4 10             	add    $0x10,%esp
f0100e05:	3b 75 d8             	cmp    -0x28(%ebp),%esi
f0100e08:	7f 79                	jg     f0100e83 <debuginfo_eip+0x15f>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100e0a:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100e0d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e10:	c7 c2 f0 23 10 f0    	mov    $0xf01023f0,%edx
f0100e16:	8d 0c 82             	lea    (%edx,%eax,4),%ecx
f0100e19:	8b 11                	mov    (%ecx),%edx
f0100e1b:	c7 c0 a7 85 10 f0    	mov    $0xf01085a7,%eax
f0100e21:	81 e8 a9 6e 10 f0    	sub    $0xf0106ea9,%eax
f0100e27:	39 c2                	cmp    %eax,%edx
f0100e29:	73 09                	jae    f0100e34 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100e2b:	81 c2 a9 6e 10 f0    	add    $0xf0106ea9,%edx
f0100e31:	89 57 08             	mov    %edx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100e34:	8b 41 08             	mov    0x8(%ecx),%eax
f0100e37:	89 47 10             	mov    %eax,0x10(%edi)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100e3a:	83 ec 08             	sub    $0x8,%esp
f0100e3d:	6a 3a                	push   $0x3a
f0100e3f:	ff 77 08             	pushl  0x8(%edi)
f0100e42:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e45:	e8 80 09 00 00       	call   f01017ca <strfind>
f0100e4a:	2b 47 08             	sub    0x8(%edi),%eax
f0100e4d:	89 47 0c             	mov    %eax,0xc(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100e50:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100e53:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100e56:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0100e59:	c7 c2 f0 23 10 f0    	mov    $0xf01023f0,%edx
f0100e5f:	8d 44 82 04          	lea    0x4(%edx,%eax,4),%eax
f0100e63:	83 c4 10             	add    $0x10,%esp
f0100e66:	eb 29                	jmp    f0100e91 <debuginfo_eip+0x16d>
  	        panic("User address");
f0100e68:	83 ec 04             	sub    $0x4,%esp
f0100e6b:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100e6e:	8d 83 d7 fe fe ff    	lea    -0x10129(%ebx),%eax
f0100e74:	50                   	push   %eax
f0100e75:	6a 7f                	push   $0x7f
f0100e77:	8d 83 e4 fe fe ff    	lea    -0x1011c(%ebx),%eax
f0100e7d:	50                   	push   %eax
f0100e7e:	e8 59 f2 ff ff       	call   f01000dc <_panic>
		info->eip_fn_addr = addr;
f0100e83:	89 5f 10             	mov    %ebx,0x10(%edi)
		lline = lfile;
f0100e86:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100e89:	eb af                	jmp    f0100e3a <debuginfo_eip+0x116>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0100e8b:	83 ee 01             	sub    $0x1,%esi
f0100e8e:	83 e8 0c             	sub    $0xc,%eax
	while (lline >= lfile
f0100e91:	39 f3                	cmp    %esi,%ebx
f0100e93:	7f 3a                	jg     f0100ecf <debuginfo_eip+0x1ab>
	       && stabs[lline].n_type != N_SOL
f0100e95:	0f b6 10             	movzbl (%eax),%edx
f0100e98:	80 fa 84             	cmp    $0x84,%dl
f0100e9b:	74 0b                	je     f0100ea8 <debuginfo_eip+0x184>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100e9d:	80 fa 64             	cmp    $0x64,%dl
f0100ea0:	75 e9                	jne    f0100e8b <debuginfo_eip+0x167>
f0100ea2:	83 78 04 00          	cmpl   $0x0,0x4(%eax)
f0100ea6:	74 e3                	je     f0100e8b <debuginfo_eip+0x167>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100ea8:	8d 14 76             	lea    (%esi,%esi,2),%edx
f0100eab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0100eae:	c7 c0 f0 23 10 f0    	mov    $0xf01023f0,%eax
f0100eb4:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100eb7:	c7 c0 a7 85 10 f0    	mov    $0xf01085a7,%eax
f0100ebd:	81 e8 a9 6e 10 f0    	sub    $0xf0106ea9,%eax
f0100ec3:	39 c2                	cmp    %eax,%edx
f0100ec5:	73 08                	jae    f0100ecf <debuginfo_eip+0x1ab>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100ec7:	81 c2 a9 6e 10 f0    	add    $0xf0106ea9,%edx
f0100ecd:	89 17                	mov    %edx,(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100ecf:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ed2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100ed5:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f0100eda:	39 c8                	cmp    %ecx,%eax
f0100edc:	7d 4a                	jge    f0100f28 <debuginfo_eip+0x204>
		for (lline = lfun + 1;
f0100ede:	8d 50 01             	lea    0x1(%eax),%edx
f0100ee1:	8d 1c 40             	lea    (%eax,%eax,2),%ebx
f0100ee4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100ee7:	c7 c0 f0 23 10 f0    	mov    $0xf01023f0,%eax
f0100eed:	8d 44 98 10          	lea    0x10(%eax,%ebx,4),%eax
f0100ef1:	eb 07                	jmp    f0100efa <debuginfo_eip+0x1d6>
			info->eip_fn_narg++;
f0100ef3:	83 47 14 01          	addl   $0x1,0x14(%edi)
		     lline++)
f0100ef7:	83 c2 01             	add    $0x1,%edx
		for (lline = lfun + 1;
f0100efa:	39 d1                	cmp    %edx,%ecx
f0100efc:	74 25                	je     f0100f23 <debuginfo_eip+0x1ff>
f0100efe:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100f01:	80 78 f4 a0          	cmpb   $0xa0,-0xc(%eax)
f0100f05:	74 ec                	je     f0100ef3 <debuginfo_eip+0x1cf>
	return 0;
f0100f07:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f0c:	eb 1a                	jmp    f0100f28 <debuginfo_eip+0x204>
		return -1;
f0100f0e:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100f13:	eb 13                	jmp    f0100f28 <debuginfo_eip+0x204>
f0100f15:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100f1a:	eb 0c                	jmp    f0100f28 <debuginfo_eip+0x204>
		return -1;
f0100f1c:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100f21:	eb 05                	jmp    f0100f28 <debuginfo_eip+0x204>
	return 0;
f0100f23:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100f28:	89 d0                	mov    %edx,%eax
f0100f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f2d:	5b                   	pop    %ebx
f0100f2e:	5e                   	pop    %esi
f0100f2f:	5f                   	pop    %edi
f0100f30:	5d                   	pop    %ebp
f0100f31:	c3                   	ret    

f0100f32 <__x86.get_pc_thunk.cx>:
f0100f32:	8b 0c 24             	mov    (%esp),%ecx
f0100f35:	c3                   	ret    

f0100f36 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100f36:	55                   	push   %ebp
f0100f37:	89 e5                	mov    %esp,%ebp
f0100f39:	57                   	push   %edi
f0100f3a:	56                   	push   %esi
f0100f3b:	53                   	push   %ebx
f0100f3c:	83 ec 2c             	sub    $0x2c,%esp
f0100f3f:	e8 ee ff ff ff       	call   f0100f32 <__x86.get_pc_thunk.cx>
f0100f44:	81 c1 c4 13 01 00    	add    $0x113c4,%ecx
f0100f4a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0100f4d:	89 c7                	mov    %eax,%edi
f0100f4f:	89 d6                	mov    %edx,%esi
f0100f51:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f54:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100f57:	89 d1                	mov    %edx,%ecx
f0100f59:	89 c2                	mov    %eax,%edx
f0100f5b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f5e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0100f61:	8b 45 10             	mov    0x10(%ebp),%eax
f0100f64:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100f67:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f6a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100f71:	39 c2                	cmp    %eax,%edx
f0100f73:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0100f76:	72 41                	jb     f0100fb9 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100f78:	83 ec 0c             	sub    $0xc,%esp
f0100f7b:	ff 75 18             	pushl  0x18(%ebp)
f0100f7e:	83 eb 01             	sub    $0x1,%ebx
f0100f81:	53                   	push   %ebx
f0100f82:	50                   	push   %eax
f0100f83:	83 ec 08             	sub    $0x8,%esp
f0100f86:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100f89:	ff 75 e0             	pushl  -0x20(%ebp)
f0100f8c:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f8f:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f92:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100f95:	e8 66 0a 00 00       	call   f0101a00 <__udivdi3>
f0100f9a:	83 c4 18             	add    $0x18,%esp
f0100f9d:	52                   	push   %edx
f0100f9e:	50                   	push   %eax
f0100f9f:	89 f2                	mov    %esi,%edx
f0100fa1:	89 f8                	mov    %edi,%eax
f0100fa3:	e8 8e ff ff ff       	call   f0100f36 <printnum>
f0100fa8:	83 c4 20             	add    $0x20,%esp
f0100fab:	eb 13                	jmp    f0100fc0 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100fad:	83 ec 08             	sub    $0x8,%esp
f0100fb0:	56                   	push   %esi
f0100fb1:	ff 75 18             	pushl  0x18(%ebp)
f0100fb4:	ff d7                	call   *%edi
f0100fb6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100fb9:	83 eb 01             	sub    $0x1,%ebx
f0100fbc:	85 db                	test   %ebx,%ebx
f0100fbe:	7f ed                	jg     f0100fad <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100fc0:	83 ec 08             	sub    $0x8,%esp
f0100fc3:	56                   	push   %esi
f0100fc4:	83 ec 04             	sub    $0x4,%esp
f0100fc7:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100fca:	ff 75 e0             	pushl  -0x20(%ebp)
f0100fcd:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100fd0:	ff 75 d0             	pushl  -0x30(%ebp)
f0100fd3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0100fd6:	e8 35 0b 00 00       	call   f0101b10 <__umoddi3>
f0100fdb:	83 c4 14             	add    $0x14,%esp
f0100fde:	0f be 84 03 f2 fe fe 	movsbl -0x1010e(%ebx,%eax,1),%eax
f0100fe5:	ff 
f0100fe6:	50                   	push   %eax
f0100fe7:	ff d7                	call   *%edi
}
f0100fe9:	83 c4 10             	add    $0x10,%esp
f0100fec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fef:	5b                   	pop    %ebx
f0100ff0:	5e                   	pop    %esi
f0100ff1:	5f                   	pop    %edi
f0100ff2:	5d                   	pop    %ebp
f0100ff3:	c3                   	ret    

f0100ff4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100ff4:	f3 0f 1e fb          	endbr32 
f0100ff8:	55                   	push   %ebp
f0100ff9:	89 e5                	mov    %esp,%ebp
f0100ffb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100ffe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101002:	8b 10                	mov    (%eax),%edx
f0101004:	3b 50 04             	cmp    0x4(%eax),%edx
f0101007:	73 0a                	jae    f0101013 <sprintputch+0x1f>
		*b->buf++ = ch;
f0101009:	8d 4a 01             	lea    0x1(%edx),%ecx
f010100c:	89 08                	mov    %ecx,(%eax)
f010100e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101011:	88 02                	mov    %al,(%edx)
}
f0101013:	5d                   	pop    %ebp
f0101014:	c3                   	ret    

f0101015 <printfmt>:
{
f0101015:	f3 0f 1e fb          	endbr32 
f0101019:	55                   	push   %ebp
f010101a:	89 e5                	mov    %esp,%ebp
f010101c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f010101f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101022:	50                   	push   %eax
f0101023:	ff 75 10             	pushl  0x10(%ebp)
f0101026:	ff 75 0c             	pushl  0xc(%ebp)
f0101029:	ff 75 08             	pushl  0x8(%ebp)
f010102c:	e8 05 00 00 00       	call   f0101036 <vprintfmt>
}
f0101031:	83 c4 10             	add    $0x10,%esp
f0101034:	c9                   	leave  
f0101035:	c3                   	ret    

f0101036 <vprintfmt>:
{
f0101036:	f3 0f 1e fb          	endbr32 
f010103a:	55                   	push   %ebp
f010103b:	89 e5                	mov    %esp,%ebp
f010103d:	57                   	push   %edi
f010103e:	56                   	push   %esi
f010103f:	53                   	push   %ebx
f0101040:	83 ec 3c             	sub    $0x3c,%esp
f0101043:	e8 06 f7 ff ff       	call   f010074e <__x86.get_pc_thunk.ax>
f0101048:	05 c0 12 01 00       	add    $0x112c0,%eax
f010104d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101050:	8b 75 08             	mov    0x8(%ebp),%esi
f0101053:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101056:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101059:	8d 80 20 1d 00 00    	lea    0x1d20(%eax),%eax
f010105f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0101062:	e9 95 03 00 00       	jmp    f01013fc <.L25+0x48>
		padc = ' ';
f0101067:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
f010106b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f0101072:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0101079:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		lflag = 0;
f0101080:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101085:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0101088:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010108b:	8d 43 01             	lea    0x1(%ebx),%eax
f010108e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101091:	0f b6 13             	movzbl (%ebx),%edx
f0101094:	8d 42 dd             	lea    -0x23(%edx),%eax
f0101097:	3c 55                	cmp    $0x55,%al
f0101099:	0f 87 e9 03 00 00    	ja     f0101488 <.L20>
f010109f:	0f b6 c0             	movzbl %al,%eax
f01010a2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01010a5:	89 ce                	mov    %ecx,%esi
f01010a7:	03 b4 81 80 ff fe ff 	add    -0x10080(%ecx,%eax,4),%esi
f01010ae:	3e ff e6             	notrack jmp *%esi

f01010b1 <.L66>:
f01010b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
f01010b4:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
f01010b8:	eb d1                	jmp    f010108b <vprintfmt+0x55>

f01010ba <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
f01010ba:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01010bd:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
f01010c1:	eb c8                	jmp    f010108b <vprintfmt+0x55>

f01010c3 <.L31>:
f01010c3:	0f b6 d2             	movzbl %dl,%edx
f01010c6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
f01010c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01010ce:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
f01010d1:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01010d4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f01010d8:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
f01010db:	8d 4a d0             	lea    -0x30(%edx),%ecx
f01010de:	83 f9 09             	cmp    $0x9,%ecx
f01010e1:	77 58                	ja     f010113b <.L36+0xf>
			for (precision = 0; ; ++fmt) {
f01010e3:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f01010e6:	eb e9                	jmp    f01010d1 <.L31+0xe>

f01010e8 <.L34>:
			precision = va_arg(ap, int);
f01010e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01010eb:	8b 00                	mov    (%eax),%eax
f01010ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f3:	8d 40 04             	lea    0x4(%eax),%eax
f01010f6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
f01010fc:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0101100:	79 89                	jns    f010108b <vprintfmt+0x55>
				width = precision, precision = -1;
f0101102:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101105:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101108:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f010110f:	e9 77 ff ff ff       	jmp    f010108b <vprintfmt+0x55>

f0101114 <.L33>:
f0101114:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101117:	85 c0                	test   %eax,%eax
f0101119:	ba 00 00 00 00       	mov    $0x0,%edx
f010111e:	0f 49 d0             	cmovns %eax,%edx
f0101121:	89 55 d0             	mov    %edx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101124:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f0101127:	e9 5f ff ff ff       	jmp    f010108b <vprintfmt+0x55>

f010112c <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
f010112c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
f010112f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f0101136:	e9 50 ff ff ff       	jmp    f010108b <vprintfmt+0x55>
f010113b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010113e:	89 75 08             	mov    %esi,0x8(%ebp)
f0101141:	eb b9                	jmp    f01010fc <.L34+0x14>

f0101143 <.L27>:
			lflag++;
f0101143:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101147:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
f010114a:	e9 3c ff ff ff       	jmp    f010108b <vprintfmt+0x55>

f010114f <.L30>:
f010114f:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(va_arg(ap, int), putdat);
f0101152:	8b 45 14             	mov    0x14(%ebp),%eax
f0101155:	8d 58 04             	lea    0x4(%eax),%ebx
f0101158:	83 ec 08             	sub    $0x8,%esp
f010115b:	57                   	push   %edi
f010115c:	ff 30                	pushl  (%eax)
f010115e:	ff d6                	call   *%esi
			break;
f0101160:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0101163:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
f0101166:	e9 8e 02 00 00       	jmp    f01013f9 <.L25+0x45>

f010116b <.L28>:
f010116b:	8b 75 08             	mov    0x8(%ebp),%esi
			err = va_arg(ap, int);
f010116e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101171:	8d 58 04             	lea    0x4(%eax),%ebx
f0101174:	8b 00                	mov    (%eax),%eax
f0101176:	99                   	cltd   
f0101177:	31 d0                	xor    %edx,%eax
f0101179:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010117b:	83 f8 06             	cmp    $0x6,%eax
f010117e:	7f 27                	jg     f01011a7 <.L28+0x3c>
f0101180:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0101183:	8b 14 82             	mov    (%edx,%eax,4),%edx
f0101186:	85 d2                	test   %edx,%edx
f0101188:	74 1d                	je     f01011a7 <.L28+0x3c>
				printfmt(putch, putdat, "%s", p);
f010118a:	52                   	push   %edx
f010118b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010118e:	8d 80 13 ff fe ff    	lea    -0x100ed(%eax),%eax
f0101194:	50                   	push   %eax
f0101195:	57                   	push   %edi
f0101196:	56                   	push   %esi
f0101197:	e8 79 fe ff ff       	call   f0101015 <printfmt>
f010119c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010119f:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01011a2:	e9 52 02 00 00       	jmp    f01013f9 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
f01011a7:	50                   	push   %eax
f01011a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011ab:	8d 80 0a ff fe ff    	lea    -0x100f6(%eax),%eax
f01011b1:	50                   	push   %eax
f01011b2:	57                   	push   %edi
f01011b3:	56                   	push   %esi
f01011b4:	e8 5c fe ff ff       	call   f0101015 <printfmt>
f01011b9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01011bc:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f01011bf:	e9 35 02 00 00       	jmp    f01013f9 <.L25+0x45>

f01011c4 <.L24>:
f01011c4:	8b 75 08             	mov    0x8(%ebp),%esi
			if ((p = va_arg(ap, char *)) == NULL)
f01011c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01011ca:	83 c0 04             	add    $0x4,%eax
f01011cd:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01011d0:	8b 45 14             	mov    0x14(%ebp),%eax
f01011d3:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f01011d5:	85 d2                	test   %edx,%edx
f01011d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01011da:	8d 80 03 ff fe ff    	lea    -0x100fd(%eax),%eax
f01011e0:	0f 45 c2             	cmovne %edx,%eax
f01011e3:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
f01011e6:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f01011ea:	7e 06                	jle    f01011f2 <.L24+0x2e>
f01011ec:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
f01011f0:	75 0d                	jne    f01011ff <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
f01011f2:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01011f5:	89 c3                	mov    %eax,%ebx
f01011f7:	03 45 d0             	add    -0x30(%ebp),%eax
f01011fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01011fd:	eb 58                	jmp    f0101257 <.L24+0x93>
f01011ff:	83 ec 08             	sub    $0x8,%esp
f0101202:	ff 75 d8             	pushl  -0x28(%ebp)
f0101205:	ff 75 c8             	pushl  -0x38(%ebp)
f0101208:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010120b:	e8 49 04 00 00       	call   f0101659 <strnlen>
f0101210:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101213:	29 c2                	sub    %eax,%edx
f0101215:	89 55 bc             	mov    %edx,-0x44(%ebp)
f0101218:	83 c4 10             	add    $0x10,%esp
f010121b:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
f010121d:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
f0101221:	89 45 d0             	mov    %eax,-0x30(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f0101224:	85 db                	test   %ebx,%ebx
f0101226:	7e 11                	jle    f0101239 <.L24+0x75>
					putch(padc, putdat);
f0101228:	83 ec 08             	sub    $0x8,%esp
f010122b:	57                   	push   %edi
f010122c:	ff 75 d0             	pushl  -0x30(%ebp)
f010122f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101231:	83 eb 01             	sub    $0x1,%ebx
f0101234:	83 c4 10             	add    $0x10,%esp
f0101237:	eb eb                	jmp    f0101224 <.L24+0x60>
f0101239:	8b 55 bc             	mov    -0x44(%ebp),%edx
f010123c:	85 d2                	test   %edx,%edx
f010123e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101243:	0f 49 c2             	cmovns %edx,%eax
f0101246:	29 c2                	sub    %eax,%edx
f0101248:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010124b:	eb a5                	jmp    f01011f2 <.L24+0x2e>
					putch(ch, putdat);
f010124d:	83 ec 08             	sub    $0x8,%esp
f0101250:	57                   	push   %edi
f0101251:	52                   	push   %edx
f0101252:	ff d6                	call   *%esi
f0101254:	83 c4 10             	add    $0x10,%esp
f0101257:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010125a:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010125c:	83 c3 01             	add    $0x1,%ebx
f010125f:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101263:	0f be d0             	movsbl %al,%edx
f0101266:	85 d2                	test   %edx,%edx
f0101268:	74 4b                	je     f01012b5 <.L24+0xf1>
f010126a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010126e:	78 06                	js     f0101276 <.L24+0xb2>
f0101270:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f0101274:	78 1e                	js     f0101294 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
f0101276:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010127a:	74 d1                	je     f010124d <.L24+0x89>
f010127c:	0f be c0             	movsbl %al,%eax
f010127f:	83 e8 20             	sub    $0x20,%eax
f0101282:	83 f8 5e             	cmp    $0x5e,%eax
f0101285:	76 c6                	jbe    f010124d <.L24+0x89>
					putch('?', putdat);
f0101287:	83 ec 08             	sub    $0x8,%esp
f010128a:	57                   	push   %edi
f010128b:	6a 3f                	push   $0x3f
f010128d:	ff d6                	call   *%esi
f010128f:	83 c4 10             	add    $0x10,%esp
f0101292:	eb c3                	jmp    f0101257 <.L24+0x93>
f0101294:	89 cb                	mov    %ecx,%ebx
f0101296:	eb 0e                	jmp    f01012a6 <.L24+0xe2>
				putch(' ', putdat);
f0101298:	83 ec 08             	sub    $0x8,%esp
f010129b:	57                   	push   %edi
f010129c:	6a 20                	push   $0x20
f010129e:	ff d6                	call   *%esi
			for (; width > 0; width--)
f01012a0:	83 eb 01             	sub    $0x1,%ebx
f01012a3:	83 c4 10             	add    $0x10,%esp
f01012a6:	85 db                	test   %ebx,%ebx
f01012a8:	7f ee                	jg     f0101298 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
f01012aa:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01012ad:	89 45 14             	mov    %eax,0x14(%ebp)
f01012b0:	e9 44 01 00 00       	jmp    f01013f9 <.L25+0x45>
f01012b5:	89 cb                	mov    %ecx,%ebx
f01012b7:	eb ed                	jmp    f01012a6 <.L24+0xe2>

f01012b9 <.L29>:
f01012b9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01012bc:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f01012bf:	83 f9 01             	cmp    $0x1,%ecx
f01012c2:	7f 1b                	jg     f01012df <.L29+0x26>
	else if (lflag)
f01012c4:	85 c9                	test   %ecx,%ecx
f01012c6:	74 63                	je     f010132b <.L29+0x72>
		return va_arg(*ap, long);
f01012c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01012cb:	8b 00                	mov    (%eax),%eax
f01012cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012d0:	99                   	cltd   
f01012d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01012d7:	8d 40 04             	lea    0x4(%eax),%eax
f01012da:	89 45 14             	mov    %eax,0x14(%ebp)
f01012dd:	eb 17                	jmp    f01012f6 <.L29+0x3d>
		return va_arg(*ap, long long);
f01012df:	8b 45 14             	mov    0x14(%ebp),%eax
f01012e2:	8b 50 04             	mov    0x4(%eax),%edx
f01012e5:	8b 00                	mov    (%eax),%eax
f01012e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01012ea:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01012ed:	8b 45 14             	mov    0x14(%ebp),%eax
f01012f0:	8d 40 08             	lea    0x8(%eax),%eax
f01012f3:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f01012f6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01012f9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01012fc:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f0101301:	85 c9                	test   %ecx,%ecx
f0101303:	0f 89 d6 00 00 00    	jns    f01013df <.L25+0x2b>
				putch('-', putdat);
f0101309:	83 ec 08             	sub    $0x8,%esp
f010130c:	57                   	push   %edi
f010130d:	6a 2d                	push   $0x2d
f010130f:	ff d6                	call   *%esi
				num = -(long long) num;
f0101311:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101314:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101317:	f7 da                	neg    %edx
f0101319:	83 d1 00             	adc    $0x0,%ecx
f010131c:	f7 d9                	neg    %ecx
f010131e:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101321:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101326:	e9 b4 00 00 00       	jmp    f01013df <.L25+0x2b>
		return va_arg(*ap, int);
f010132b:	8b 45 14             	mov    0x14(%ebp),%eax
f010132e:	8b 00                	mov    (%eax),%eax
f0101330:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101333:	99                   	cltd   
f0101334:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101337:	8b 45 14             	mov    0x14(%ebp),%eax
f010133a:	8d 40 04             	lea    0x4(%eax),%eax
f010133d:	89 45 14             	mov    %eax,0x14(%ebp)
f0101340:	eb b4                	jmp    f01012f6 <.L29+0x3d>

f0101342 <.L23>:
f0101342:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101345:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101348:	83 f9 01             	cmp    $0x1,%ecx
f010134b:	7f 1b                	jg     f0101368 <.L23+0x26>
	else if (lflag)
f010134d:	85 c9                	test   %ecx,%ecx
f010134f:	74 2c                	je     f010137d <.L23+0x3b>
		return va_arg(*ap, unsigned long);
f0101351:	8b 45 14             	mov    0x14(%ebp),%eax
f0101354:	8b 10                	mov    (%eax),%edx
f0101356:	b9 00 00 00 00       	mov    $0x0,%ecx
f010135b:	8d 40 04             	lea    0x4(%eax),%eax
f010135e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101361:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f0101366:	eb 77                	jmp    f01013df <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101368:	8b 45 14             	mov    0x14(%ebp),%eax
f010136b:	8b 10                	mov    (%eax),%edx
f010136d:	8b 48 04             	mov    0x4(%eax),%ecx
f0101370:	8d 40 08             	lea    0x8(%eax),%eax
f0101373:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0101376:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f010137b:	eb 62                	jmp    f01013df <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f010137d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101380:	8b 10                	mov    (%eax),%edx
f0101382:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101387:	8d 40 04             	lea    0x4(%eax),%eax
f010138a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010138d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f0101392:	eb 4b                	jmp    f01013df <.L25+0x2b>

f0101394 <.L26>:
f0101394:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('X', putdat);
f0101397:	83 ec 08             	sub    $0x8,%esp
f010139a:	57                   	push   %edi
f010139b:	6a 58                	push   $0x58
f010139d:	ff d6                	call   *%esi
			putch('X', putdat);
f010139f:	83 c4 08             	add    $0x8,%esp
f01013a2:	57                   	push   %edi
f01013a3:	6a 58                	push   $0x58
f01013a5:	ff d6                	call   *%esi
			putch('X', putdat);
f01013a7:	83 c4 08             	add    $0x8,%esp
f01013aa:	57                   	push   %edi
f01013ab:	6a 58                	push   $0x58
f01013ad:	ff d6                	call   *%esi
			break;
f01013af:	83 c4 10             	add    $0x10,%esp
f01013b2:	eb 45                	jmp    f01013f9 <.L25+0x45>

f01013b4 <.L25>:
f01013b4:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('0', putdat);
f01013b7:	83 ec 08             	sub    $0x8,%esp
f01013ba:	57                   	push   %edi
f01013bb:	6a 30                	push   $0x30
f01013bd:	ff d6                	call   *%esi
			putch('x', putdat);
f01013bf:	83 c4 08             	add    $0x8,%esp
f01013c2:	57                   	push   %edi
f01013c3:	6a 78                	push   $0x78
f01013c5:	ff d6                	call   *%esi
			num = (unsigned long long)
f01013c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01013ca:	8b 10                	mov    (%eax),%edx
f01013cc:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f01013d1:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f01013d4:	8d 40 04             	lea    0x4(%eax),%eax
f01013d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013da:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01013df:	83 ec 0c             	sub    $0xc,%esp
f01013e2:	0f be 5d cf          	movsbl -0x31(%ebp),%ebx
f01013e6:	53                   	push   %ebx
f01013e7:	ff 75 d0             	pushl  -0x30(%ebp)
f01013ea:	50                   	push   %eax
f01013eb:	51                   	push   %ecx
f01013ec:	52                   	push   %edx
f01013ed:	89 fa                	mov    %edi,%edx
f01013ef:	89 f0                	mov    %esi,%eax
f01013f1:	e8 40 fb ff ff       	call   f0100f36 <printnum>
			break;
f01013f6:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f01013f9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01013fc:	83 c3 01             	add    $0x1,%ebx
f01013ff:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
f0101403:	83 f8 25             	cmp    $0x25,%eax
f0101406:	0f 84 5b fc ff ff    	je     f0101067 <vprintfmt+0x31>
			if (ch == '\0')
f010140c:	85 c0                	test   %eax,%eax
f010140e:	0f 84 97 00 00 00    	je     f01014ab <.L20+0x23>
			putch(ch, putdat);
f0101414:	83 ec 08             	sub    $0x8,%esp
f0101417:	57                   	push   %edi
f0101418:	50                   	push   %eax
f0101419:	ff d6                	call   *%esi
f010141b:	83 c4 10             	add    $0x10,%esp
f010141e:	eb dc                	jmp    f01013fc <.L25+0x48>

f0101420 <.L21>:
f0101420:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0101423:	8b 75 08             	mov    0x8(%ebp),%esi
	if (lflag >= 2)
f0101426:	83 f9 01             	cmp    $0x1,%ecx
f0101429:	7f 1b                	jg     f0101446 <.L21+0x26>
	else if (lflag)
f010142b:	85 c9                	test   %ecx,%ecx
f010142d:	74 2c                	je     f010145b <.L21+0x3b>
		return va_arg(*ap, unsigned long);
f010142f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101432:	8b 10                	mov    (%eax),%edx
f0101434:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101439:	8d 40 04             	lea    0x4(%eax),%eax
f010143c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010143f:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f0101444:	eb 99                	jmp    f01013df <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
f0101446:	8b 45 14             	mov    0x14(%ebp),%eax
f0101449:	8b 10                	mov    (%eax),%edx
f010144b:	8b 48 04             	mov    0x4(%eax),%ecx
f010144e:	8d 40 08             	lea    0x8(%eax),%eax
f0101451:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101454:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f0101459:	eb 84                	jmp    f01013df <.L25+0x2b>
		return va_arg(*ap, unsigned int);
f010145b:	8b 45 14             	mov    0x14(%ebp),%eax
f010145e:	8b 10                	mov    (%eax),%edx
f0101460:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101465:	8d 40 04             	lea    0x4(%eax),%eax
f0101468:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010146b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f0101470:	e9 6a ff ff ff       	jmp    f01013df <.L25+0x2b>

f0101475 <.L35>:
f0101475:	8b 75 08             	mov    0x8(%ebp),%esi
			putch(ch, putdat);
f0101478:	83 ec 08             	sub    $0x8,%esp
f010147b:	57                   	push   %edi
f010147c:	6a 25                	push   $0x25
f010147e:	ff d6                	call   *%esi
			break;
f0101480:	83 c4 10             	add    $0x10,%esp
f0101483:	e9 71 ff ff ff       	jmp    f01013f9 <.L25+0x45>

f0101488 <.L20>:
f0101488:	8b 75 08             	mov    0x8(%ebp),%esi
			putch('%', putdat);
f010148b:	83 ec 08             	sub    $0x8,%esp
f010148e:	57                   	push   %edi
f010148f:	6a 25                	push   $0x25
f0101491:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101493:	83 c4 10             	add    $0x10,%esp
f0101496:	89 d8                	mov    %ebx,%eax
f0101498:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010149c:	74 05                	je     f01014a3 <.L20+0x1b>
f010149e:	83 e8 01             	sub    $0x1,%eax
f01014a1:	eb f5                	jmp    f0101498 <.L20+0x10>
f01014a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01014a6:	e9 4e ff ff ff       	jmp    f01013f9 <.L25+0x45>
}
f01014ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01014ae:	5b                   	pop    %ebx
f01014af:	5e                   	pop    %esi
f01014b0:	5f                   	pop    %edi
f01014b1:	5d                   	pop    %ebp
f01014b2:	c3                   	ret    

f01014b3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01014b3:	f3 0f 1e fb          	endbr32 
f01014b7:	55                   	push   %ebp
f01014b8:	89 e5                	mov    %esp,%ebp
f01014ba:	53                   	push   %ebx
f01014bb:	83 ec 14             	sub    $0x14,%esp
f01014be:	e8 d7 ec ff ff       	call   f010019a <__x86.get_pc_thunk.bx>
f01014c3:	81 c3 45 0e 01 00    	add    $0x10e45,%ebx
f01014c9:	8b 45 08             	mov    0x8(%ebp),%eax
f01014cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01014cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01014d2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01014d6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01014d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01014e0:	85 c0                	test   %eax,%eax
f01014e2:	74 2b                	je     f010150f <vsnprintf+0x5c>
f01014e4:	85 d2                	test   %edx,%edx
f01014e6:	7e 27                	jle    f010150f <vsnprintf+0x5c>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01014e8:	ff 75 14             	pushl  0x14(%ebp)
f01014eb:	ff 75 10             	pushl  0x10(%ebp)
f01014ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01014f1:	50                   	push   %eax
f01014f2:	8d 83 ec ec fe ff    	lea    -0x11314(%ebx),%eax
f01014f8:	50                   	push   %eax
f01014f9:	e8 38 fb ff ff       	call   f0101036 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01014fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101501:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101504:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101507:	83 c4 10             	add    $0x10,%esp
}
f010150a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010150d:	c9                   	leave  
f010150e:	c3                   	ret    
		return -E_INVAL;
f010150f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0101514:	eb f4                	jmp    f010150a <vsnprintf+0x57>

f0101516 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101516:	f3 0f 1e fb          	endbr32 
f010151a:	55                   	push   %ebp
f010151b:	89 e5                	mov    %esp,%ebp
f010151d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101520:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101523:	50                   	push   %eax
f0101524:	ff 75 10             	pushl  0x10(%ebp)
f0101527:	ff 75 0c             	pushl  0xc(%ebp)
f010152a:	ff 75 08             	pushl  0x8(%ebp)
f010152d:	e8 81 ff ff ff       	call   f01014b3 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101532:	c9                   	leave  
f0101533:	c3                   	ret    

f0101534 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101534:	f3 0f 1e fb          	endbr32 
f0101538:	55                   	push   %ebp
f0101539:	89 e5                	mov    %esp,%ebp
f010153b:	57                   	push   %edi
f010153c:	56                   	push   %esi
f010153d:	53                   	push   %ebx
f010153e:	83 ec 1c             	sub    $0x1c,%esp
f0101541:	e8 54 ec ff ff       	call   f010019a <__x86.get_pc_thunk.bx>
f0101546:	81 c3 c2 0d 01 00    	add    $0x10dc2,%ebx
f010154c:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010154f:	85 c0                	test   %eax,%eax
f0101551:	74 13                	je     f0101566 <readline+0x32>
		cprintf("%s", prompt);
f0101553:	83 ec 08             	sub    $0x8,%esp
f0101556:	50                   	push   %eax
f0101557:	8d 83 13 ff fe ff    	lea    -0x100ed(%ebx),%eax
f010155d:	50                   	push   %eax
f010155e:	e8 b4 f6 ff ff       	call   f0100c17 <cprintf>
f0101563:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101566:	83 ec 0c             	sub    $0xc,%esp
f0101569:	6a 00                	push   $0x0
f010156b:	e8 d4 f1 ff ff       	call   f0100744 <iscons>
f0101570:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101573:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101576:	bf 00 00 00 00       	mov    $0x0,%edi
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f010157b:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f0101581:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101584:	eb 51                	jmp    f01015d7 <readline+0xa3>
			cprintf("read error: %e\n", c);
f0101586:	83 ec 08             	sub    $0x8,%esp
f0101589:	50                   	push   %eax
f010158a:	8d 83 d8 00 ff ff    	lea    -0xff28(%ebx),%eax
f0101590:	50                   	push   %eax
f0101591:	e8 81 f6 ff ff       	call   f0100c17 <cprintf>
			return NULL;
f0101596:	83 c4 10             	add    $0x10,%esp
f0101599:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010159e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01015a1:	5b                   	pop    %ebx
f01015a2:	5e                   	pop    %esi
f01015a3:	5f                   	pop    %edi
f01015a4:	5d                   	pop    %ebp
f01015a5:	c3                   	ret    
			if (echoing)
f01015a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015aa:	75 05                	jne    f01015b1 <readline+0x7d>
			i--;
f01015ac:	83 ef 01             	sub    $0x1,%edi
f01015af:	eb 26                	jmp    f01015d7 <readline+0xa3>
				cputchar('\b');
f01015b1:	83 ec 0c             	sub    $0xc,%esp
f01015b4:	6a 08                	push   $0x8
f01015b6:	e8 60 f1 ff ff       	call   f010071b <cputchar>
f01015bb:	83 c4 10             	add    $0x10,%esp
f01015be:	eb ec                	jmp    f01015ac <readline+0x78>
				cputchar(c);
f01015c0:	83 ec 0c             	sub    $0xc,%esp
f01015c3:	56                   	push   %esi
f01015c4:	e8 52 f1 ff ff       	call   f010071b <cputchar>
f01015c9:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01015cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01015cf:	89 f0                	mov    %esi,%eax
f01015d1:	88 04 39             	mov    %al,(%ecx,%edi,1)
f01015d4:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f01015d7:	e8 53 f1 ff ff       	call   f010072f <getchar>
f01015dc:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f01015de:	85 c0                	test   %eax,%eax
f01015e0:	78 a4                	js     f0101586 <readline+0x52>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01015e2:	83 f8 08             	cmp    $0x8,%eax
f01015e5:	0f 94 c2             	sete   %dl
f01015e8:	83 f8 7f             	cmp    $0x7f,%eax
f01015eb:	0f 94 c0             	sete   %al
f01015ee:	08 c2                	or     %al,%dl
f01015f0:	74 04                	je     f01015f6 <readline+0xc2>
f01015f2:	85 ff                	test   %edi,%edi
f01015f4:	7f b0                	jg     f01015a6 <readline+0x72>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01015f6:	83 fe 1f             	cmp    $0x1f,%esi
f01015f9:	7e 10                	jle    f010160b <readline+0xd7>
f01015fb:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0101601:	7f 08                	jg     f010160b <readline+0xd7>
			if (echoing)
f0101603:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101607:	74 c3                	je     f01015cc <readline+0x98>
f0101609:	eb b5                	jmp    f01015c0 <readline+0x8c>
		} else if (c == '\n' || c == '\r') {
f010160b:	83 fe 0a             	cmp    $0xa,%esi
f010160e:	74 05                	je     f0101615 <readline+0xe1>
f0101610:	83 fe 0d             	cmp    $0xd,%esi
f0101613:	75 c2                	jne    f01015d7 <readline+0xa3>
			if (echoing)
f0101615:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101619:	75 13                	jne    f010162e <readline+0xfa>
			buf[i] = 0;
f010161b:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f0101622:	00 
			return buf;
f0101623:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f0101629:	e9 70 ff ff ff       	jmp    f010159e <readline+0x6a>
				cputchar('\n');
f010162e:	83 ec 0c             	sub    $0xc,%esp
f0101631:	6a 0a                	push   $0xa
f0101633:	e8 e3 f0 ff ff       	call   f010071b <cputchar>
f0101638:	83 c4 10             	add    $0x10,%esp
f010163b:	eb de                	jmp    f010161b <readline+0xe7>

f010163d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010163d:	f3 0f 1e fb          	endbr32 
f0101641:	55                   	push   %ebp
f0101642:	89 e5                	mov    %esp,%ebp
f0101644:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101647:	b8 00 00 00 00       	mov    $0x0,%eax
f010164c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101650:	74 05                	je     f0101657 <strlen+0x1a>
		n++;
f0101652:	83 c0 01             	add    $0x1,%eax
f0101655:	eb f5                	jmp    f010164c <strlen+0xf>
	return n;
}
f0101657:	5d                   	pop    %ebp
f0101658:	c3                   	ret    

f0101659 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101659:	f3 0f 1e fb          	endbr32 
f010165d:	55                   	push   %ebp
f010165e:	89 e5                	mov    %esp,%ebp
f0101660:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101663:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101666:	b8 00 00 00 00       	mov    $0x0,%eax
f010166b:	39 d0                	cmp    %edx,%eax
f010166d:	74 0d                	je     f010167c <strnlen+0x23>
f010166f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0101673:	74 05                	je     f010167a <strnlen+0x21>
		n++;
f0101675:	83 c0 01             	add    $0x1,%eax
f0101678:	eb f1                	jmp    f010166b <strnlen+0x12>
f010167a:	89 c2                	mov    %eax,%edx
	return n;
}
f010167c:	89 d0                	mov    %edx,%eax
f010167e:	5d                   	pop    %ebp
f010167f:	c3                   	ret    

f0101680 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101680:	f3 0f 1e fb          	endbr32 
f0101684:	55                   	push   %ebp
f0101685:	89 e5                	mov    %esp,%ebp
f0101687:	53                   	push   %ebx
f0101688:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010168b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010168e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101693:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f0101697:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f010169a:	83 c0 01             	add    $0x1,%eax
f010169d:	84 d2                	test   %dl,%dl
f010169f:	75 f2                	jne    f0101693 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f01016a1:	89 c8                	mov    %ecx,%eax
f01016a3:	5b                   	pop    %ebx
f01016a4:	5d                   	pop    %ebp
f01016a5:	c3                   	ret    

f01016a6 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01016a6:	f3 0f 1e fb          	endbr32 
f01016aa:	55                   	push   %ebp
f01016ab:	89 e5                	mov    %esp,%ebp
f01016ad:	53                   	push   %ebx
f01016ae:	83 ec 10             	sub    $0x10,%esp
f01016b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01016b4:	53                   	push   %ebx
f01016b5:	e8 83 ff ff ff       	call   f010163d <strlen>
f01016ba:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f01016bd:	ff 75 0c             	pushl  0xc(%ebp)
f01016c0:	01 d8                	add    %ebx,%eax
f01016c2:	50                   	push   %eax
f01016c3:	e8 b8 ff ff ff       	call   f0101680 <strcpy>
	return dst;
}
f01016c8:	89 d8                	mov    %ebx,%eax
f01016ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01016cd:	c9                   	leave  
f01016ce:	c3                   	ret    

f01016cf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01016cf:	f3 0f 1e fb          	endbr32 
f01016d3:	55                   	push   %ebp
f01016d4:	89 e5                	mov    %esp,%ebp
f01016d6:	56                   	push   %esi
f01016d7:	53                   	push   %ebx
f01016d8:	8b 75 08             	mov    0x8(%ebp),%esi
f01016db:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016de:	89 f3                	mov    %esi,%ebx
f01016e0:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01016e3:	89 f0                	mov    %esi,%eax
f01016e5:	39 d8                	cmp    %ebx,%eax
f01016e7:	74 11                	je     f01016fa <strncpy+0x2b>
		*dst++ = *src;
f01016e9:	83 c0 01             	add    $0x1,%eax
f01016ec:	0f b6 0a             	movzbl (%edx),%ecx
f01016ef:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01016f2:	80 f9 01             	cmp    $0x1,%cl
f01016f5:	83 da ff             	sbb    $0xffffffff,%edx
f01016f8:	eb eb                	jmp    f01016e5 <strncpy+0x16>
	}
	return ret;
}
f01016fa:	89 f0                	mov    %esi,%eax
f01016fc:	5b                   	pop    %ebx
f01016fd:	5e                   	pop    %esi
f01016fe:	5d                   	pop    %ebp
f01016ff:	c3                   	ret    

f0101700 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101700:	f3 0f 1e fb          	endbr32 
f0101704:	55                   	push   %ebp
f0101705:	89 e5                	mov    %esp,%ebp
f0101707:	56                   	push   %esi
f0101708:	53                   	push   %ebx
f0101709:	8b 75 08             	mov    0x8(%ebp),%esi
f010170c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010170f:	8b 55 10             	mov    0x10(%ebp),%edx
f0101712:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101714:	85 d2                	test   %edx,%edx
f0101716:	74 21                	je     f0101739 <strlcpy+0x39>
f0101718:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f010171c:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f010171e:	39 c2                	cmp    %eax,%edx
f0101720:	74 14                	je     f0101736 <strlcpy+0x36>
f0101722:	0f b6 19             	movzbl (%ecx),%ebx
f0101725:	84 db                	test   %bl,%bl
f0101727:	74 0b                	je     f0101734 <strlcpy+0x34>
			*dst++ = *src++;
f0101729:	83 c1 01             	add    $0x1,%ecx
f010172c:	83 c2 01             	add    $0x1,%edx
f010172f:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101732:	eb ea                	jmp    f010171e <strlcpy+0x1e>
f0101734:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0101736:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101739:	29 f0                	sub    %esi,%eax
}
f010173b:	5b                   	pop    %ebx
f010173c:	5e                   	pop    %esi
f010173d:	5d                   	pop    %ebp
f010173e:	c3                   	ret    

f010173f <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010173f:	f3 0f 1e fb          	endbr32 
f0101743:	55                   	push   %ebp
f0101744:	89 e5                	mov    %esp,%ebp
f0101746:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101749:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010174c:	0f b6 01             	movzbl (%ecx),%eax
f010174f:	84 c0                	test   %al,%al
f0101751:	74 0c                	je     f010175f <strcmp+0x20>
f0101753:	3a 02                	cmp    (%edx),%al
f0101755:	75 08                	jne    f010175f <strcmp+0x20>
		p++, q++;
f0101757:	83 c1 01             	add    $0x1,%ecx
f010175a:	83 c2 01             	add    $0x1,%edx
f010175d:	eb ed                	jmp    f010174c <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010175f:	0f b6 c0             	movzbl %al,%eax
f0101762:	0f b6 12             	movzbl (%edx),%edx
f0101765:	29 d0                	sub    %edx,%eax
}
f0101767:	5d                   	pop    %ebp
f0101768:	c3                   	ret    

f0101769 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101769:	f3 0f 1e fb          	endbr32 
f010176d:	55                   	push   %ebp
f010176e:	89 e5                	mov    %esp,%ebp
f0101770:	53                   	push   %ebx
f0101771:	8b 45 08             	mov    0x8(%ebp),%eax
f0101774:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101777:	89 c3                	mov    %eax,%ebx
f0101779:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010177c:	eb 06                	jmp    f0101784 <strncmp+0x1b>
		n--, p++, q++;
f010177e:	83 c0 01             	add    $0x1,%eax
f0101781:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0101784:	39 d8                	cmp    %ebx,%eax
f0101786:	74 16                	je     f010179e <strncmp+0x35>
f0101788:	0f b6 08             	movzbl (%eax),%ecx
f010178b:	84 c9                	test   %cl,%cl
f010178d:	74 04                	je     f0101793 <strncmp+0x2a>
f010178f:	3a 0a                	cmp    (%edx),%cl
f0101791:	74 eb                	je     f010177e <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101793:	0f b6 00             	movzbl (%eax),%eax
f0101796:	0f b6 12             	movzbl (%edx),%edx
f0101799:	29 d0                	sub    %edx,%eax
}
f010179b:	5b                   	pop    %ebx
f010179c:	5d                   	pop    %ebp
f010179d:	c3                   	ret    
		return 0;
f010179e:	b8 00 00 00 00       	mov    $0x0,%eax
f01017a3:	eb f6                	jmp    f010179b <strncmp+0x32>

f01017a5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01017a5:	f3 0f 1e fb          	endbr32 
f01017a9:	55                   	push   %ebp
f01017aa:	89 e5                	mov    %esp,%ebp
f01017ac:	8b 45 08             	mov    0x8(%ebp),%eax
f01017af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01017b3:	0f b6 10             	movzbl (%eax),%edx
f01017b6:	84 d2                	test   %dl,%dl
f01017b8:	74 09                	je     f01017c3 <strchr+0x1e>
		if (*s == c)
f01017ba:	38 ca                	cmp    %cl,%dl
f01017bc:	74 0a                	je     f01017c8 <strchr+0x23>
	for (; *s; s++)
f01017be:	83 c0 01             	add    $0x1,%eax
f01017c1:	eb f0                	jmp    f01017b3 <strchr+0xe>
			return (char *) s;
	return 0;
f01017c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01017c8:	5d                   	pop    %ebp
f01017c9:	c3                   	ret    

f01017ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01017ca:	f3 0f 1e fb          	endbr32 
f01017ce:	55                   	push   %ebp
f01017cf:	89 e5                	mov    %esp,%ebp
f01017d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01017d4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01017d8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01017db:	38 ca                	cmp    %cl,%dl
f01017dd:	74 09                	je     f01017e8 <strfind+0x1e>
f01017df:	84 d2                	test   %dl,%dl
f01017e1:	74 05                	je     f01017e8 <strfind+0x1e>
	for (; *s; s++)
f01017e3:	83 c0 01             	add    $0x1,%eax
f01017e6:	eb f0                	jmp    f01017d8 <strfind+0xe>
			break;
	return (char *) s;
}
f01017e8:	5d                   	pop    %ebp
f01017e9:	c3                   	ret    

f01017ea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01017ea:	f3 0f 1e fb          	endbr32 
f01017ee:	55                   	push   %ebp
f01017ef:	89 e5                	mov    %esp,%ebp
f01017f1:	57                   	push   %edi
f01017f2:	56                   	push   %esi
f01017f3:	53                   	push   %ebx
f01017f4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01017f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01017fa:	85 c9                	test   %ecx,%ecx
f01017fc:	74 31                	je     f010182f <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01017fe:	89 f8                	mov    %edi,%eax
f0101800:	09 c8                	or     %ecx,%eax
f0101802:	a8 03                	test   $0x3,%al
f0101804:	75 23                	jne    f0101829 <memset+0x3f>
		c &= 0xFF;
f0101806:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010180a:	89 d3                	mov    %edx,%ebx
f010180c:	c1 e3 08             	shl    $0x8,%ebx
f010180f:	89 d0                	mov    %edx,%eax
f0101811:	c1 e0 18             	shl    $0x18,%eax
f0101814:	89 d6                	mov    %edx,%esi
f0101816:	c1 e6 10             	shl    $0x10,%esi
f0101819:	09 f0                	or     %esi,%eax
f010181b:	09 c2                	or     %eax,%edx
f010181d:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010181f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101822:	89 d0                	mov    %edx,%eax
f0101824:	fc                   	cld    
f0101825:	f3 ab                	rep stos %eax,%es:(%edi)
f0101827:	eb 06                	jmp    f010182f <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101829:	8b 45 0c             	mov    0xc(%ebp),%eax
f010182c:	fc                   	cld    
f010182d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010182f:	89 f8                	mov    %edi,%eax
f0101831:	5b                   	pop    %ebx
f0101832:	5e                   	pop    %esi
f0101833:	5f                   	pop    %edi
f0101834:	5d                   	pop    %ebp
f0101835:	c3                   	ret    

f0101836 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101836:	f3 0f 1e fb          	endbr32 
f010183a:	55                   	push   %ebp
f010183b:	89 e5                	mov    %esp,%ebp
f010183d:	57                   	push   %edi
f010183e:	56                   	push   %esi
f010183f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101842:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101845:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101848:	39 c6                	cmp    %eax,%esi
f010184a:	73 32                	jae    f010187e <memmove+0x48>
f010184c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010184f:	39 c2                	cmp    %eax,%edx
f0101851:	76 2b                	jbe    f010187e <memmove+0x48>
		s += n;
		d += n;
f0101853:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101856:	89 fe                	mov    %edi,%esi
f0101858:	09 ce                	or     %ecx,%esi
f010185a:	09 d6                	or     %edx,%esi
f010185c:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101862:	75 0e                	jne    f0101872 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101864:	83 ef 04             	sub    $0x4,%edi
f0101867:	8d 72 fc             	lea    -0x4(%edx),%esi
f010186a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f010186d:	fd                   	std    
f010186e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101870:	eb 09                	jmp    f010187b <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101872:	83 ef 01             	sub    $0x1,%edi
f0101875:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0101878:	fd                   	std    
f0101879:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010187b:	fc                   	cld    
f010187c:	eb 1a                	jmp    f0101898 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010187e:	89 c2                	mov    %eax,%edx
f0101880:	09 ca                	or     %ecx,%edx
f0101882:	09 f2                	or     %esi,%edx
f0101884:	f6 c2 03             	test   $0x3,%dl
f0101887:	75 0a                	jne    f0101893 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0101889:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f010188c:	89 c7                	mov    %eax,%edi
f010188e:	fc                   	cld    
f010188f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101891:	eb 05                	jmp    f0101898 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0101893:	89 c7                	mov    %eax,%edi
f0101895:	fc                   	cld    
f0101896:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101898:	5e                   	pop    %esi
f0101899:	5f                   	pop    %edi
f010189a:	5d                   	pop    %ebp
f010189b:	c3                   	ret    

f010189c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010189c:	f3 0f 1e fb          	endbr32 
f01018a0:	55                   	push   %ebp
f01018a1:	89 e5                	mov    %esp,%ebp
f01018a3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01018a6:	ff 75 10             	pushl  0x10(%ebp)
f01018a9:	ff 75 0c             	pushl  0xc(%ebp)
f01018ac:	ff 75 08             	pushl  0x8(%ebp)
f01018af:	e8 82 ff ff ff       	call   f0101836 <memmove>
}
f01018b4:	c9                   	leave  
f01018b5:	c3                   	ret    

f01018b6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01018b6:	f3 0f 1e fb          	endbr32 
f01018ba:	55                   	push   %ebp
f01018bb:	89 e5                	mov    %esp,%ebp
f01018bd:	56                   	push   %esi
f01018be:	53                   	push   %ebx
f01018bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01018c2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01018c5:	89 c6                	mov    %eax,%esi
f01018c7:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01018ca:	39 f0                	cmp    %esi,%eax
f01018cc:	74 1c                	je     f01018ea <memcmp+0x34>
		if (*s1 != *s2)
f01018ce:	0f b6 08             	movzbl (%eax),%ecx
f01018d1:	0f b6 1a             	movzbl (%edx),%ebx
f01018d4:	38 d9                	cmp    %bl,%cl
f01018d6:	75 08                	jne    f01018e0 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f01018d8:	83 c0 01             	add    $0x1,%eax
f01018db:	83 c2 01             	add    $0x1,%edx
f01018de:	eb ea                	jmp    f01018ca <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f01018e0:	0f b6 c1             	movzbl %cl,%eax
f01018e3:	0f b6 db             	movzbl %bl,%ebx
f01018e6:	29 d8                	sub    %ebx,%eax
f01018e8:	eb 05                	jmp    f01018ef <memcmp+0x39>
	}

	return 0;
f01018ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01018ef:	5b                   	pop    %ebx
f01018f0:	5e                   	pop    %esi
f01018f1:	5d                   	pop    %ebp
f01018f2:	c3                   	ret    

f01018f3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01018f3:	f3 0f 1e fb          	endbr32 
f01018f7:	55                   	push   %ebp
f01018f8:	89 e5                	mov    %esp,%ebp
f01018fa:	8b 45 08             	mov    0x8(%ebp),%eax
f01018fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101900:	89 c2                	mov    %eax,%edx
f0101902:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0101905:	39 d0                	cmp    %edx,%eax
f0101907:	73 09                	jae    f0101912 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101909:	38 08                	cmp    %cl,(%eax)
f010190b:	74 05                	je     f0101912 <memfind+0x1f>
	for (; s < ends; s++)
f010190d:	83 c0 01             	add    $0x1,%eax
f0101910:	eb f3                	jmp    f0101905 <memfind+0x12>
			break;
	return (void *) s;
}
f0101912:	5d                   	pop    %ebp
f0101913:	c3                   	ret    

f0101914 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101914:	f3 0f 1e fb          	endbr32 
f0101918:	55                   	push   %ebp
f0101919:	89 e5                	mov    %esp,%ebp
f010191b:	57                   	push   %edi
f010191c:	56                   	push   %esi
f010191d:	53                   	push   %ebx
f010191e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101921:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101924:	eb 03                	jmp    f0101929 <strtol+0x15>
		s++;
f0101926:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0101929:	0f b6 01             	movzbl (%ecx),%eax
f010192c:	3c 20                	cmp    $0x20,%al
f010192e:	74 f6                	je     f0101926 <strtol+0x12>
f0101930:	3c 09                	cmp    $0x9,%al
f0101932:	74 f2                	je     f0101926 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0101934:	3c 2b                	cmp    $0x2b,%al
f0101936:	74 2a                	je     f0101962 <strtol+0x4e>
	int neg = 0;
f0101938:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f010193d:	3c 2d                	cmp    $0x2d,%al
f010193f:	74 2b                	je     f010196c <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101941:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101947:	75 0f                	jne    f0101958 <strtol+0x44>
f0101949:	80 39 30             	cmpb   $0x30,(%ecx)
f010194c:	74 28                	je     f0101976 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010194e:	85 db                	test   %ebx,%ebx
f0101950:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101955:	0f 44 d8             	cmove  %eax,%ebx
f0101958:	b8 00 00 00 00       	mov    $0x0,%eax
f010195d:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0101960:	eb 46                	jmp    f01019a8 <strtol+0x94>
		s++;
f0101962:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0101965:	bf 00 00 00 00       	mov    $0x0,%edi
f010196a:	eb d5                	jmp    f0101941 <strtol+0x2d>
		s++, neg = 1;
f010196c:	83 c1 01             	add    $0x1,%ecx
f010196f:	bf 01 00 00 00       	mov    $0x1,%edi
f0101974:	eb cb                	jmp    f0101941 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101976:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010197a:	74 0e                	je     f010198a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f010197c:	85 db                	test   %ebx,%ebx
f010197e:	75 d8                	jne    f0101958 <strtol+0x44>
		s++, base = 8;
f0101980:	83 c1 01             	add    $0x1,%ecx
f0101983:	bb 08 00 00 00       	mov    $0x8,%ebx
f0101988:	eb ce                	jmp    f0101958 <strtol+0x44>
		s += 2, base = 16;
f010198a:	83 c1 02             	add    $0x2,%ecx
f010198d:	bb 10 00 00 00       	mov    $0x10,%ebx
f0101992:	eb c4                	jmp    f0101958 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0101994:	0f be d2             	movsbl %dl,%edx
f0101997:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010199a:	3b 55 10             	cmp    0x10(%ebp),%edx
f010199d:	7d 3a                	jge    f01019d9 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f010199f:	83 c1 01             	add    $0x1,%ecx
f01019a2:	0f af 45 10          	imul   0x10(%ebp),%eax
f01019a6:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01019a8:	0f b6 11             	movzbl (%ecx),%edx
f01019ab:	8d 72 d0             	lea    -0x30(%edx),%esi
f01019ae:	89 f3                	mov    %esi,%ebx
f01019b0:	80 fb 09             	cmp    $0x9,%bl
f01019b3:	76 df                	jbe    f0101994 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f01019b5:	8d 72 9f             	lea    -0x61(%edx),%esi
f01019b8:	89 f3                	mov    %esi,%ebx
f01019ba:	80 fb 19             	cmp    $0x19,%bl
f01019bd:	77 08                	ja     f01019c7 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01019bf:	0f be d2             	movsbl %dl,%edx
f01019c2:	83 ea 57             	sub    $0x57,%edx
f01019c5:	eb d3                	jmp    f010199a <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f01019c7:	8d 72 bf             	lea    -0x41(%edx),%esi
f01019ca:	89 f3                	mov    %esi,%ebx
f01019cc:	80 fb 19             	cmp    $0x19,%bl
f01019cf:	77 08                	ja     f01019d9 <strtol+0xc5>
			dig = *s - 'A' + 10;
f01019d1:	0f be d2             	movsbl %dl,%edx
f01019d4:	83 ea 37             	sub    $0x37,%edx
f01019d7:	eb c1                	jmp    f010199a <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f01019d9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01019dd:	74 05                	je     f01019e4 <strtol+0xd0>
		*endptr = (char *) s;
f01019df:	8b 75 0c             	mov    0xc(%ebp),%esi
f01019e2:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f01019e4:	89 c2                	mov    %eax,%edx
f01019e6:	f7 da                	neg    %edx
f01019e8:	85 ff                	test   %edi,%edi
f01019ea:	0f 45 c2             	cmovne %edx,%eax
}
f01019ed:	5b                   	pop    %ebx
f01019ee:	5e                   	pop    %esi
f01019ef:	5f                   	pop    %edi
f01019f0:	5d                   	pop    %ebp
f01019f1:	c3                   	ret    
f01019f2:	66 90                	xchg   %ax,%ax
f01019f4:	66 90                	xchg   %ax,%ax
f01019f6:	66 90                	xchg   %ax,%ax
f01019f8:	66 90                	xchg   %ax,%ax
f01019fa:	66 90                	xchg   %ax,%ax
f01019fc:	66 90                	xchg   %ax,%ax
f01019fe:	66 90                	xchg   %ax,%ax

f0101a00 <__udivdi3>:
f0101a00:	f3 0f 1e fb          	endbr32 
f0101a04:	55                   	push   %ebp
f0101a05:	57                   	push   %edi
f0101a06:	56                   	push   %esi
f0101a07:	53                   	push   %ebx
f0101a08:	83 ec 1c             	sub    $0x1c,%esp
f0101a0b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0101a0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101a13:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101a17:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101a1b:	85 d2                	test   %edx,%edx
f0101a1d:	75 19                	jne    f0101a38 <__udivdi3+0x38>
f0101a1f:	39 f3                	cmp    %esi,%ebx
f0101a21:	76 4d                	jbe    f0101a70 <__udivdi3+0x70>
f0101a23:	31 ff                	xor    %edi,%edi
f0101a25:	89 e8                	mov    %ebp,%eax
f0101a27:	89 f2                	mov    %esi,%edx
f0101a29:	f7 f3                	div    %ebx
f0101a2b:	89 fa                	mov    %edi,%edx
f0101a2d:	83 c4 1c             	add    $0x1c,%esp
f0101a30:	5b                   	pop    %ebx
f0101a31:	5e                   	pop    %esi
f0101a32:	5f                   	pop    %edi
f0101a33:	5d                   	pop    %ebp
f0101a34:	c3                   	ret    
f0101a35:	8d 76 00             	lea    0x0(%esi),%esi
f0101a38:	39 f2                	cmp    %esi,%edx
f0101a3a:	76 14                	jbe    f0101a50 <__udivdi3+0x50>
f0101a3c:	31 ff                	xor    %edi,%edi
f0101a3e:	31 c0                	xor    %eax,%eax
f0101a40:	89 fa                	mov    %edi,%edx
f0101a42:	83 c4 1c             	add    $0x1c,%esp
f0101a45:	5b                   	pop    %ebx
f0101a46:	5e                   	pop    %esi
f0101a47:	5f                   	pop    %edi
f0101a48:	5d                   	pop    %ebp
f0101a49:	c3                   	ret    
f0101a4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a50:	0f bd fa             	bsr    %edx,%edi
f0101a53:	83 f7 1f             	xor    $0x1f,%edi
f0101a56:	75 48                	jne    f0101aa0 <__udivdi3+0xa0>
f0101a58:	39 f2                	cmp    %esi,%edx
f0101a5a:	72 06                	jb     f0101a62 <__udivdi3+0x62>
f0101a5c:	31 c0                	xor    %eax,%eax
f0101a5e:	39 eb                	cmp    %ebp,%ebx
f0101a60:	77 de                	ja     f0101a40 <__udivdi3+0x40>
f0101a62:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a67:	eb d7                	jmp    f0101a40 <__udivdi3+0x40>
f0101a69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a70:	89 d9                	mov    %ebx,%ecx
f0101a72:	85 db                	test   %ebx,%ebx
f0101a74:	75 0b                	jne    f0101a81 <__udivdi3+0x81>
f0101a76:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a7b:	31 d2                	xor    %edx,%edx
f0101a7d:	f7 f3                	div    %ebx
f0101a7f:	89 c1                	mov    %eax,%ecx
f0101a81:	31 d2                	xor    %edx,%edx
f0101a83:	89 f0                	mov    %esi,%eax
f0101a85:	f7 f1                	div    %ecx
f0101a87:	89 c6                	mov    %eax,%esi
f0101a89:	89 e8                	mov    %ebp,%eax
f0101a8b:	89 f7                	mov    %esi,%edi
f0101a8d:	f7 f1                	div    %ecx
f0101a8f:	89 fa                	mov    %edi,%edx
f0101a91:	83 c4 1c             	add    $0x1c,%esp
f0101a94:	5b                   	pop    %ebx
f0101a95:	5e                   	pop    %esi
f0101a96:	5f                   	pop    %edi
f0101a97:	5d                   	pop    %ebp
f0101a98:	c3                   	ret    
f0101a99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101aa0:	89 f9                	mov    %edi,%ecx
f0101aa2:	b8 20 00 00 00       	mov    $0x20,%eax
f0101aa7:	29 f8                	sub    %edi,%eax
f0101aa9:	d3 e2                	shl    %cl,%edx
f0101aab:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101aaf:	89 c1                	mov    %eax,%ecx
f0101ab1:	89 da                	mov    %ebx,%edx
f0101ab3:	d3 ea                	shr    %cl,%edx
f0101ab5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101ab9:	09 d1                	or     %edx,%ecx
f0101abb:	89 f2                	mov    %esi,%edx
f0101abd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101ac1:	89 f9                	mov    %edi,%ecx
f0101ac3:	d3 e3                	shl    %cl,%ebx
f0101ac5:	89 c1                	mov    %eax,%ecx
f0101ac7:	d3 ea                	shr    %cl,%edx
f0101ac9:	89 f9                	mov    %edi,%ecx
f0101acb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101acf:	89 eb                	mov    %ebp,%ebx
f0101ad1:	d3 e6                	shl    %cl,%esi
f0101ad3:	89 c1                	mov    %eax,%ecx
f0101ad5:	d3 eb                	shr    %cl,%ebx
f0101ad7:	09 de                	or     %ebx,%esi
f0101ad9:	89 f0                	mov    %esi,%eax
f0101adb:	f7 74 24 08          	divl   0x8(%esp)
f0101adf:	89 d6                	mov    %edx,%esi
f0101ae1:	89 c3                	mov    %eax,%ebx
f0101ae3:	f7 64 24 0c          	mull   0xc(%esp)
f0101ae7:	39 d6                	cmp    %edx,%esi
f0101ae9:	72 15                	jb     f0101b00 <__udivdi3+0x100>
f0101aeb:	89 f9                	mov    %edi,%ecx
f0101aed:	d3 e5                	shl    %cl,%ebp
f0101aef:	39 c5                	cmp    %eax,%ebp
f0101af1:	73 04                	jae    f0101af7 <__udivdi3+0xf7>
f0101af3:	39 d6                	cmp    %edx,%esi
f0101af5:	74 09                	je     f0101b00 <__udivdi3+0x100>
f0101af7:	89 d8                	mov    %ebx,%eax
f0101af9:	31 ff                	xor    %edi,%edi
f0101afb:	e9 40 ff ff ff       	jmp    f0101a40 <__udivdi3+0x40>
f0101b00:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0101b03:	31 ff                	xor    %edi,%edi
f0101b05:	e9 36 ff ff ff       	jmp    f0101a40 <__udivdi3+0x40>
f0101b0a:	66 90                	xchg   %ax,%ax
f0101b0c:	66 90                	xchg   %ax,%ax
f0101b0e:	66 90                	xchg   %ax,%ax

f0101b10 <__umoddi3>:
f0101b10:	f3 0f 1e fb          	endbr32 
f0101b14:	55                   	push   %ebp
f0101b15:	57                   	push   %edi
f0101b16:	56                   	push   %esi
f0101b17:	53                   	push   %ebx
f0101b18:	83 ec 1c             	sub    $0x1c,%esp
f0101b1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f0101b1f:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101b23:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101b27:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101b2b:	85 c0                	test   %eax,%eax
f0101b2d:	75 19                	jne    f0101b48 <__umoddi3+0x38>
f0101b2f:	39 df                	cmp    %ebx,%edi
f0101b31:	76 5d                	jbe    f0101b90 <__umoddi3+0x80>
f0101b33:	89 f0                	mov    %esi,%eax
f0101b35:	89 da                	mov    %ebx,%edx
f0101b37:	f7 f7                	div    %edi
f0101b39:	89 d0                	mov    %edx,%eax
f0101b3b:	31 d2                	xor    %edx,%edx
f0101b3d:	83 c4 1c             	add    $0x1c,%esp
f0101b40:	5b                   	pop    %ebx
f0101b41:	5e                   	pop    %esi
f0101b42:	5f                   	pop    %edi
f0101b43:	5d                   	pop    %ebp
f0101b44:	c3                   	ret    
f0101b45:	8d 76 00             	lea    0x0(%esi),%esi
f0101b48:	89 f2                	mov    %esi,%edx
f0101b4a:	39 d8                	cmp    %ebx,%eax
f0101b4c:	76 12                	jbe    f0101b60 <__umoddi3+0x50>
f0101b4e:	89 f0                	mov    %esi,%eax
f0101b50:	89 da                	mov    %ebx,%edx
f0101b52:	83 c4 1c             	add    $0x1c,%esp
f0101b55:	5b                   	pop    %ebx
f0101b56:	5e                   	pop    %esi
f0101b57:	5f                   	pop    %edi
f0101b58:	5d                   	pop    %ebp
f0101b59:	c3                   	ret    
f0101b5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101b60:	0f bd e8             	bsr    %eax,%ebp
f0101b63:	83 f5 1f             	xor    $0x1f,%ebp
f0101b66:	75 50                	jne    f0101bb8 <__umoddi3+0xa8>
f0101b68:	39 d8                	cmp    %ebx,%eax
f0101b6a:	0f 82 e0 00 00 00    	jb     f0101c50 <__umoddi3+0x140>
f0101b70:	89 d9                	mov    %ebx,%ecx
f0101b72:	39 f7                	cmp    %esi,%edi
f0101b74:	0f 86 d6 00 00 00    	jbe    f0101c50 <__umoddi3+0x140>
f0101b7a:	89 d0                	mov    %edx,%eax
f0101b7c:	89 ca                	mov    %ecx,%edx
f0101b7e:	83 c4 1c             	add    $0x1c,%esp
f0101b81:	5b                   	pop    %ebx
f0101b82:	5e                   	pop    %esi
f0101b83:	5f                   	pop    %edi
f0101b84:	5d                   	pop    %ebp
f0101b85:	c3                   	ret    
f0101b86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b8d:	8d 76 00             	lea    0x0(%esi),%esi
f0101b90:	89 fd                	mov    %edi,%ebp
f0101b92:	85 ff                	test   %edi,%edi
f0101b94:	75 0b                	jne    f0101ba1 <__umoddi3+0x91>
f0101b96:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b9b:	31 d2                	xor    %edx,%edx
f0101b9d:	f7 f7                	div    %edi
f0101b9f:	89 c5                	mov    %eax,%ebp
f0101ba1:	89 d8                	mov    %ebx,%eax
f0101ba3:	31 d2                	xor    %edx,%edx
f0101ba5:	f7 f5                	div    %ebp
f0101ba7:	89 f0                	mov    %esi,%eax
f0101ba9:	f7 f5                	div    %ebp
f0101bab:	89 d0                	mov    %edx,%eax
f0101bad:	31 d2                	xor    %edx,%edx
f0101baf:	eb 8c                	jmp    f0101b3d <__umoddi3+0x2d>
f0101bb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101bb8:	89 e9                	mov    %ebp,%ecx
f0101bba:	ba 20 00 00 00       	mov    $0x20,%edx
f0101bbf:	29 ea                	sub    %ebp,%edx
f0101bc1:	d3 e0                	shl    %cl,%eax
f0101bc3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101bc7:	89 d1                	mov    %edx,%ecx
f0101bc9:	89 f8                	mov    %edi,%eax
f0101bcb:	d3 e8                	shr    %cl,%eax
f0101bcd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0101bd1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101bd5:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101bd9:	09 c1                	or     %eax,%ecx
f0101bdb:	89 d8                	mov    %ebx,%eax
f0101bdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101be1:	89 e9                	mov    %ebp,%ecx
f0101be3:	d3 e7                	shl    %cl,%edi
f0101be5:	89 d1                	mov    %edx,%ecx
f0101be7:	d3 e8                	shr    %cl,%eax
f0101be9:	89 e9                	mov    %ebp,%ecx
f0101beb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0101bef:	d3 e3                	shl    %cl,%ebx
f0101bf1:	89 c7                	mov    %eax,%edi
f0101bf3:	89 d1                	mov    %edx,%ecx
f0101bf5:	89 f0                	mov    %esi,%eax
f0101bf7:	d3 e8                	shr    %cl,%eax
f0101bf9:	89 e9                	mov    %ebp,%ecx
f0101bfb:	89 fa                	mov    %edi,%edx
f0101bfd:	d3 e6                	shl    %cl,%esi
f0101bff:	09 d8                	or     %ebx,%eax
f0101c01:	f7 74 24 08          	divl   0x8(%esp)
f0101c05:	89 d1                	mov    %edx,%ecx
f0101c07:	89 f3                	mov    %esi,%ebx
f0101c09:	f7 64 24 0c          	mull   0xc(%esp)
f0101c0d:	89 c6                	mov    %eax,%esi
f0101c0f:	89 d7                	mov    %edx,%edi
f0101c11:	39 d1                	cmp    %edx,%ecx
f0101c13:	72 06                	jb     f0101c1b <__umoddi3+0x10b>
f0101c15:	75 10                	jne    f0101c27 <__umoddi3+0x117>
f0101c17:	39 c3                	cmp    %eax,%ebx
f0101c19:	73 0c                	jae    f0101c27 <__umoddi3+0x117>
f0101c1b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f0101c1f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f0101c23:	89 d7                	mov    %edx,%edi
f0101c25:	89 c6                	mov    %eax,%esi
f0101c27:	89 ca                	mov    %ecx,%edx
f0101c29:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101c2e:	29 f3                	sub    %esi,%ebx
f0101c30:	19 fa                	sbb    %edi,%edx
f0101c32:	89 d0                	mov    %edx,%eax
f0101c34:	d3 e0                	shl    %cl,%eax
f0101c36:	89 e9                	mov    %ebp,%ecx
f0101c38:	d3 eb                	shr    %cl,%ebx
f0101c3a:	d3 ea                	shr    %cl,%edx
f0101c3c:	09 d8                	or     %ebx,%eax
f0101c3e:	83 c4 1c             	add    $0x1c,%esp
f0101c41:	5b                   	pop    %ebx
f0101c42:	5e                   	pop    %esi
f0101c43:	5f                   	pop    %edi
f0101c44:	5d                   	pop    %ebp
f0101c45:	c3                   	ret    
f0101c46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101c4d:	8d 76 00             	lea    0x0(%esi),%esi
f0101c50:	29 fe                	sub    %edi,%esi
f0101c52:	19 c3                	sbb    %eax,%ebx
f0101c54:	89 f2                	mov    %esi,%edx
f0101c56:	89 d9                	mov    %ebx,%ecx
f0101c58:	e9 1d ff ff ff       	jmp    f0101b7a <__umoddi3+0x6a>
