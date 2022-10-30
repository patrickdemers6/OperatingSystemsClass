
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8d013103          	ld	sp,-1840(sp) # 800088d0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	8de70713          	addi	a4,a4,-1826 # 80008930 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	e5c78793          	addi	a5,a5,-420 # 80005ec0 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdb78f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dc478793          	addi	a5,a5,-572 # 80000e72 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	6ae080e7          	jalr	1710(ra) # 800027da <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	77a080e7          	jalr	1914(ra) # 800008b6 <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8e650513          	addi	a0,a0,-1818 # 80010a70 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a3e080e7          	jalr	-1474(ra) # 80000bd0 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8d648493          	addi	s1,s1,-1834 # 80010a70 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	96690913          	addi	s2,s2,-1690 # 80010b08 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305863          	blez	s3,80000220 <consoleread+0xbc>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71463          	bne	a4,a5,800001e4 <consoleread+0x80>
      if(myproc()->killed){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	842080e7          	jalr	-1982(ra) # 80001a02 <myproc>
    800001c8:	551c                	lw	a5,40(a0)
    800001ca:	e7b5                	bnez	a5,80000236 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001cc:	85a6                	mv	a1,s1
    800001ce:	854a                	mv	a0,s2
    800001d0:	00002097          	auipc	ra,0x2
    800001d4:	20a080e7          	jalr	522(ra) # 800023da <sleep>
    while(cons.r == cons.w){
    800001d8:	0984a783          	lw	a5,152(s1)
    800001dc:	09c4a703          	lw	a4,156(s1)
    800001e0:	fef700e3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e4:	0017871b          	addiw	a4,a5,1
    800001e8:	08e4ac23          	sw	a4,152(s1)
    800001ec:	07f7f713          	andi	a4,a5,127
    800001f0:	9726                	add	a4,a4,s1
    800001f2:	01874703          	lbu	a4,24(a4)
    800001f6:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001fa:	077d0563          	beq	s10,s7,80000264 <consoleread+0x100>
    cbuf = c;
    800001fe:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000202:	4685                	li	a3,1
    80000204:	f9f40613          	addi	a2,s0,-97
    80000208:	85d2                	mv	a1,s4
    8000020a:	8556                	mv	a0,s5
    8000020c:	00002097          	auipc	ra,0x2
    80000210:	578080e7          	jalr	1400(ra) # 80002784 <either_copyout>
    80000214:	01850663          	beq	a0,s8,80000220 <consoleread+0xbc>
    dst++;
    80000218:	0a05                	addi	s4,s4,1
    --n;
    8000021a:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    8000021c:	f99d1ae3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000220:	00011517          	auipc	a0,0x11
    80000224:	85050513          	addi	a0,a0,-1968 # 80010a70 <cons>
    80000228:	00001097          	auipc	ra,0x1
    8000022c:	a5c080e7          	jalr	-1444(ra) # 80000c84 <release>

  return target - n;
    80000230:	413b053b          	subw	a0,s6,s3
    80000234:	a811                	j	80000248 <consoleread+0xe4>
        release(&cons.lock);
    80000236:	00011517          	auipc	a0,0x11
    8000023a:	83a50513          	addi	a0,a0,-1990 # 80010a70 <cons>
    8000023e:	00001097          	auipc	ra,0x1
    80000242:	a46080e7          	jalr	-1466(ra) # 80000c84 <release>
        return -1;
    80000246:	557d                	li	a0,-1
}
    80000248:	70a6                	ld	ra,104(sp)
    8000024a:	7406                	ld	s0,96(sp)
    8000024c:	64e6                	ld	s1,88(sp)
    8000024e:	6946                	ld	s2,80(sp)
    80000250:	69a6                	ld	s3,72(sp)
    80000252:	6a06                	ld	s4,64(sp)
    80000254:	7ae2                	ld	s5,56(sp)
    80000256:	7b42                	ld	s6,48(sp)
    80000258:	7ba2                	ld	s7,40(sp)
    8000025a:	7c02                	ld	s8,32(sp)
    8000025c:	6ce2                	ld	s9,24(sp)
    8000025e:	6d42                	ld	s10,16(sp)
    80000260:	6165                	addi	sp,sp,112
    80000262:	8082                	ret
      if(n < target){
    80000264:	0009871b          	sext.w	a4,s3
    80000268:	fb677ce3          	bgeu	a4,s6,80000220 <consoleread+0xbc>
        cons.r--;
    8000026c:	00011717          	auipc	a4,0x11
    80000270:	88f72e23          	sw	a5,-1892(a4) # 80010b08 <cons+0x98>
    80000274:	b775                	j	80000220 <consoleread+0xbc>

0000000080000276 <consputc>:
{
    80000276:	1141                	addi	sp,sp,-16
    80000278:	e406                	sd	ra,8(sp)
    8000027a:	e022                	sd	s0,0(sp)
    8000027c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000027e:	10000793          	li	a5,256
    80000282:	00f50a63          	beq	a0,a5,80000296 <consputc+0x20>
    uartputc_sync(c);
    80000286:	00000097          	auipc	ra,0x0
    8000028a:	55e080e7          	jalr	1374(ra) # 800007e4 <uartputc_sync>
}
    8000028e:	60a2                	ld	ra,8(sp)
    80000290:	6402                	ld	s0,0(sp)
    80000292:	0141                	addi	sp,sp,16
    80000294:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000296:	4521                	li	a0,8
    80000298:	00000097          	auipc	ra,0x0
    8000029c:	54c080e7          	jalr	1356(ra) # 800007e4 <uartputc_sync>
    800002a0:	02000513          	li	a0,32
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	540080e7          	jalr	1344(ra) # 800007e4 <uartputc_sync>
    800002ac:	4521                	li	a0,8
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	536080e7          	jalr	1334(ra) # 800007e4 <uartputc_sync>
    800002b6:	bfe1                	j	8000028e <consputc+0x18>

00000000800002b8 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002b8:	1101                	addi	sp,sp,-32
    800002ba:	ec06                	sd	ra,24(sp)
    800002bc:	e822                	sd	s0,16(sp)
    800002be:	e426                	sd	s1,8(sp)
    800002c0:	e04a                	sd	s2,0(sp)
    800002c2:	1000                	addi	s0,sp,32
    800002c4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c6:	00010517          	auipc	a0,0x10
    800002ca:	7aa50513          	addi	a0,a0,1962 # 80010a70 <cons>
    800002ce:	00001097          	auipc	ra,0x1
    800002d2:	902080e7          	jalr	-1790(ra) # 80000bd0 <acquire>

  switch(c){
    800002d6:	47d5                	li	a5,21
    800002d8:	0af48663          	beq	s1,a5,80000384 <consoleintr+0xcc>
    800002dc:	0297ca63          	blt	a5,s1,80000310 <consoleintr+0x58>
    800002e0:	47a1                	li	a5,8
    800002e2:	0ef48763          	beq	s1,a5,800003d0 <consoleintr+0x118>
    800002e6:	47c1                	li	a5,16
    800002e8:	10f49a63          	bne	s1,a5,800003fc <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ec:	00002097          	auipc	ra,0x2
    800002f0:	544080e7          	jalr	1348(ra) # 80002830 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f4:	00010517          	auipc	a0,0x10
    800002f8:	77c50513          	addi	a0,a0,1916 # 80010a70 <cons>
    800002fc:	00001097          	auipc	ra,0x1
    80000300:	988080e7          	jalr	-1656(ra) # 80000c84 <release>
}
    80000304:	60e2                	ld	ra,24(sp)
    80000306:	6442                	ld	s0,16(sp)
    80000308:	64a2                	ld	s1,8(sp)
    8000030a:	6902                	ld	s2,0(sp)
    8000030c:	6105                	addi	sp,sp,32
    8000030e:	8082                	ret
  switch(c){
    80000310:	07f00793          	li	a5,127
    80000314:	0af48e63          	beq	s1,a5,800003d0 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000318:	00010717          	auipc	a4,0x10
    8000031c:	75870713          	addi	a4,a4,1880 # 80010a70 <cons>
    80000320:	0a072783          	lw	a5,160(a4)
    80000324:	09872703          	lw	a4,152(a4)
    80000328:	9f99                	subw	a5,a5,a4
    8000032a:	07f00713          	li	a4,127
    8000032e:	fcf763e3          	bltu	a4,a5,800002f4 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000332:	47b5                	li	a5,13
    80000334:	0cf48763          	beq	s1,a5,80000402 <consoleintr+0x14a>
      consputc(c);
    80000338:	8526                	mv	a0,s1
    8000033a:	00000097          	auipc	ra,0x0
    8000033e:	f3c080e7          	jalr	-196(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000342:	00010797          	auipc	a5,0x10
    80000346:	72e78793          	addi	a5,a5,1838 # 80010a70 <cons>
    8000034a:	0a07a703          	lw	a4,160(a5)
    8000034e:	0017069b          	addiw	a3,a4,1
    80000352:	0006861b          	sext.w	a2,a3
    80000356:	0ad7a023          	sw	a3,160(a5)
    8000035a:	07f77713          	andi	a4,a4,127
    8000035e:	97ba                	add	a5,a5,a4
    80000360:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000364:	47a9                	li	a5,10
    80000366:	0cf48563          	beq	s1,a5,80000430 <consoleintr+0x178>
    8000036a:	4791                	li	a5,4
    8000036c:	0cf48263          	beq	s1,a5,80000430 <consoleintr+0x178>
    80000370:	00010797          	auipc	a5,0x10
    80000374:	7987a783          	lw	a5,1944(a5) # 80010b08 <cons+0x98>
    80000378:	0807879b          	addiw	a5,a5,128
    8000037c:	f6f61ce3          	bne	a2,a5,800002f4 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000380:	863e                	mv	a2,a5
    80000382:	a07d                	j	80000430 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000384:	00010717          	auipc	a4,0x10
    80000388:	6ec70713          	addi	a4,a4,1772 # 80010a70 <cons>
    8000038c:	0a072783          	lw	a5,160(a4)
    80000390:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000394:	00010497          	auipc	s1,0x10
    80000398:	6dc48493          	addi	s1,s1,1756 # 80010a70 <cons>
    while(cons.e != cons.w &&
    8000039c:	4929                	li	s2,10
    8000039e:	f4f70be3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a2:	37fd                	addiw	a5,a5,-1
    800003a4:	07f7f713          	andi	a4,a5,127
    800003a8:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003aa:	01874703          	lbu	a4,24(a4)
    800003ae:	f52703e3          	beq	a4,s2,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003b2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b6:	10000513          	li	a0,256
    800003ba:	00000097          	auipc	ra,0x0
    800003be:	ebc080e7          	jalr	-324(ra) # 80000276 <consputc>
    while(cons.e != cons.w &&
    800003c2:	0a04a783          	lw	a5,160(s1)
    800003c6:	09c4a703          	lw	a4,156(s1)
    800003ca:	fcf71ce3          	bne	a4,a5,800003a2 <consoleintr+0xea>
    800003ce:	b71d                	j	800002f4 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d0:	00010717          	auipc	a4,0x10
    800003d4:	6a070713          	addi	a4,a4,1696 # 80010a70 <cons>
    800003d8:	0a072783          	lw	a5,160(a4)
    800003dc:	09c72703          	lw	a4,156(a4)
    800003e0:	f0f70ae3          	beq	a4,a5,800002f4 <consoleintr+0x3c>
      cons.e--;
    800003e4:	37fd                	addiw	a5,a5,-1
    800003e6:	00010717          	auipc	a4,0x10
    800003ea:	72f72523          	sw	a5,1834(a4) # 80010b10 <cons+0xa0>
      consputc(BACKSPACE);
    800003ee:	10000513          	li	a0,256
    800003f2:	00000097          	auipc	ra,0x0
    800003f6:	e84080e7          	jalr	-380(ra) # 80000276 <consputc>
    800003fa:	bded                	j	800002f4 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003fc:	ee048ce3          	beqz	s1,800002f4 <consoleintr+0x3c>
    80000400:	bf21                	j	80000318 <consoleintr+0x60>
      consputc(c);
    80000402:	4529                	li	a0,10
    80000404:	00000097          	auipc	ra,0x0
    80000408:	e72080e7          	jalr	-398(ra) # 80000276 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000040c:	00010797          	auipc	a5,0x10
    80000410:	66478793          	addi	a5,a5,1636 # 80010a70 <cons>
    80000414:	0a07a703          	lw	a4,160(a5)
    80000418:	0017069b          	addiw	a3,a4,1
    8000041c:	0006861b          	sext.w	a2,a3
    80000420:	0ad7a023          	sw	a3,160(a5)
    80000424:	07f77713          	andi	a4,a4,127
    80000428:	97ba                	add	a5,a5,a4
    8000042a:	4729                	li	a4,10
    8000042c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000430:	00010797          	auipc	a5,0x10
    80000434:	6cc7ae23          	sw	a2,1756(a5) # 80010b0c <cons+0x9c>
        wakeup(&cons.r);
    80000438:	00010517          	auipc	a0,0x10
    8000043c:	6d050513          	addi	a0,a0,1744 # 80010b08 <cons+0x98>
    80000440:	00002097          	auipc	ra,0x2
    80000444:	126080e7          	jalr	294(ra) # 80002566 <wakeup>
    80000448:	b575                	j	800002f4 <consoleintr+0x3c>

000000008000044a <consoleinit>:

void
consoleinit(void)
{
    8000044a:	1141                	addi	sp,sp,-16
    8000044c:	e406                	sd	ra,8(sp)
    8000044e:	e022                	sd	s0,0(sp)
    80000450:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000452:	00008597          	auipc	a1,0x8
    80000456:	bbe58593          	addi	a1,a1,-1090 # 80008010 <etext+0x10>
    8000045a:	00010517          	auipc	a0,0x10
    8000045e:	61650513          	addi	a0,a0,1558 # 80010a70 <cons>
    80000462:	00000097          	auipc	ra,0x0
    80000466:	6de080e7          	jalr	1758(ra) # 80000b40 <initlock>

  uartinit();
    8000046a:	00000097          	auipc	ra,0x0
    8000046e:	32a080e7          	jalr	810(ra) # 80000794 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000472:	00022797          	auipc	a5,0x22
    80000476:	a6678793          	addi	a5,a5,-1434 # 80021ed8 <devsw>
    8000047a:	00000717          	auipc	a4,0x0
    8000047e:	cea70713          	addi	a4,a4,-790 # 80000164 <consoleread>
    80000482:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000484:	00000717          	auipc	a4,0x0
    80000488:	c7e70713          	addi	a4,a4,-898 # 80000102 <consolewrite>
    8000048c:	ef98                	sd	a4,24(a5)
}
    8000048e:	60a2                	ld	ra,8(sp)
    80000490:	6402                	ld	s0,0(sp)
    80000492:	0141                	addi	sp,sp,16
    80000494:	8082                	ret

0000000080000496 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000496:	7179                	addi	sp,sp,-48
    80000498:	f406                	sd	ra,40(sp)
    8000049a:	f022                	sd	s0,32(sp)
    8000049c:	ec26                	sd	s1,24(sp)
    8000049e:	e84a                	sd	s2,16(sp)
    800004a0:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a2:	c219                	beqz	a2,800004a8 <printint+0x12>
    800004a4:	08054663          	bltz	a0,80000530 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004a8:	2501                	sext.w	a0,a0
    800004aa:	4881                	li	a7,0
    800004ac:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b0:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b2:	2581                	sext.w	a1,a1
    800004b4:	00008617          	auipc	a2,0x8
    800004b8:	b8c60613          	addi	a2,a2,-1140 # 80008040 <digits>
    800004bc:	883a                	mv	a6,a4
    800004be:	2705                	addiw	a4,a4,1
    800004c0:	02b577bb          	remuw	a5,a0,a1
    800004c4:	1782                	slli	a5,a5,0x20
    800004c6:	9381                	srli	a5,a5,0x20
    800004c8:	97b2                	add	a5,a5,a2
    800004ca:	0007c783          	lbu	a5,0(a5)
    800004ce:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d2:	0005079b          	sext.w	a5,a0
    800004d6:	02b5553b          	divuw	a0,a0,a1
    800004da:	0685                	addi	a3,a3,1
    800004dc:	feb7f0e3          	bgeu	a5,a1,800004bc <printint+0x26>

  if(sign)
    800004e0:	00088b63          	beqz	a7,800004f6 <printint+0x60>
    buf[i++] = '-';
    800004e4:	fe040793          	addi	a5,s0,-32
    800004e8:	973e                	add	a4,a4,a5
    800004ea:	02d00793          	li	a5,45
    800004ee:	fef70823          	sb	a5,-16(a4)
    800004f2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004f6:	02e05763          	blez	a4,80000524 <printint+0x8e>
    800004fa:	fd040793          	addi	a5,s0,-48
    800004fe:	00e784b3          	add	s1,a5,a4
    80000502:	fff78913          	addi	s2,a5,-1
    80000506:	993a                	add	s2,s2,a4
    80000508:	377d                	addiw	a4,a4,-1
    8000050a:	1702                	slli	a4,a4,0x20
    8000050c:	9301                	srli	a4,a4,0x20
    8000050e:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000512:	fff4c503          	lbu	a0,-1(s1)
    80000516:	00000097          	auipc	ra,0x0
    8000051a:	d60080e7          	jalr	-672(ra) # 80000276 <consputc>
  while(--i >= 0)
    8000051e:	14fd                	addi	s1,s1,-1
    80000520:	ff2499e3          	bne	s1,s2,80000512 <printint+0x7c>
}
    80000524:	70a2                	ld	ra,40(sp)
    80000526:	7402                	ld	s0,32(sp)
    80000528:	64e2                	ld	s1,24(sp)
    8000052a:	6942                	ld	s2,16(sp)
    8000052c:	6145                	addi	sp,sp,48
    8000052e:	8082                	ret
    x = -xx;
    80000530:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000534:	4885                	li	a7,1
    x = -xx;
    80000536:	bf9d                	j	800004ac <printint+0x16>

0000000080000538 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000538:	1101                	addi	sp,sp,-32
    8000053a:	ec06                	sd	ra,24(sp)
    8000053c:	e822                	sd	s0,16(sp)
    8000053e:	e426                	sd	s1,8(sp)
    80000540:	1000                	addi	s0,sp,32
    80000542:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000544:	00010797          	auipc	a5,0x10
    80000548:	5e07a623          	sw	zero,1516(a5) # 80010b30 <pr+0x18>
  printf("panic: ");
    8000054c:	00008517          	auipc	a0,0x8
    80000550:	acc50513          	addi	a0,a0,-1332 # 80008018 <etext+0x18>
    80000554:	00000097          	auipc	ra,0x0
    80000558:	02e080e7          	jalr	46(ra) # 80000582 <printf>
  printf(s);
    8000055c:	8526                	mv	a0,s1
    8000055e:	00000097          	auipc	ra,0x0
    80000562:	024080e7          	jalr	36(ra) # 80000582 <printf>
  printf("\n");
    80000566:	00008517          	auipc	a0,0x8
    8000056a:	b6250513          	addi	a0,a0,-1182 # 800080c8 <digits+0x88>
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	014080e7          	jalr	20(ra) # 80000582 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000576:	4785                	li	a5,1
    80000578:	00008717          	auipc	a4,0x8
    8000057c:	36f72c23          	sw	a5,888(a4) # 800088f0 <panicked>
  for(;;)
    80000580:	a001                	j	80000580 <panic+0x48>

0000000080000582 <printf>:
{
    80000582:	7131                	addi	sp,sp,-192
    80000584:	fc86                	sd	ra,120(sp)
    80000586:	f8a2                	sd	s0,112(sp)
    80000588:	f4a6                	sd	s1,104(sp)
    8000058a:	f0ca                	sd	s2,96(sp)
    8000058c:	ecce                	sd	s3,88(sp)
    8000058e:	e8d2                	sd	s4,80(sp)
    80000590:	e4d6                	sd	s5,72(sp)
    80000592:	e0da                	sd	s6,64(sp)
    80000594:	fc5e                	sd	s7,56(sp)
    80000596:	f862                	sd	s8,48(sp)
    80000598:	f466                	sd	s9,40(sp)
    8000059a:	f06a                	sd	s10,32(sp)
    8000059c:	ec6e                	sd	s11,24(sp)
    8000059e:	0100                	addi	s0,sp,128
    800005a0:	8a2a                	mv	s4,a0
    800005a2:	e40c                	sd	a1,8(s0)
    800005a4:	e810                	sd	a2,16(s0)
    800005a6:	ec14                	sd	a3,24(s0)
    800005a8:	f018                	sd	a4,32(s0)
    800005aa:	f41c                	sd	a5,40(s0)
    800005ac:	03043823          	sd	a6,48(s0)
    800005b0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b4:	00010d97          	auipc	s11,0x10
    800005b8:	57cdad83          	lw	s11,1404(s11) # 80010b30 <pr+0x18>
  if(locking)
    800005bc:	020d9b63          	bnez	s11,800005f2 <printf+0x70>
  if (fmt == 0)
    800005c0:	040a0263          	beqz	s4,80000604 <printf+0x82>
  va_start(ap, fmt);
    800005c4:	00840793          	addi	a5,s0,8
    800005c8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005cc:	000a4503          	lbu	a0,0(s4)
    800005d0:	14050f63          	beqz	a0,8000072e <printf+0x1ac>
    800005d4:	4981                	li	s3,0
    if(c != '%'){
    800005d6:	02500a93          	li	s5,37
    switch(c){
    800005da:	07000b93          	li	s7,112
  consputc('x');
    800005de:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e0:	00008b17          	auipc	s6,0x8
    800005e4:	a60b0b13          	addi	s6,s6,-1440 # 80008040 <digits>
    switch(c){
    800005e8:	07300c93          	li	s9,115
    800005ec:	06400c13          	li	s8,100
    800005f0:	a82d                	j	8000062a <printf+0xa8>
    acquire(&pr.lock);
    800005f2:	00010517          	auipc	a0,0x10
    800005f6:	52650513          	addi	a0,a0,1318 # 80010b18 <pr>
    800005fa:	00000097          	auipc	ra,0x0
    800005fe:	5d6080e7          	jalr	1494(ra) # 80000bd0 <acquire>
    80000602:	bf7d                	j	800005c0 <printf+0x3e>
    panic("null fmt");
    80000604:	00008517          	auipc	a0,0x8
    80000608:	a2450513          	addi	a0,a0,-1500 # 80008028 <etext+0x28>
    8000060c:	00000097          	auipc	ra,0x0
    80000610:	f2c080e7          	jalr	-212(ra) # 80000538 <panic>
      consputc(c);
    80000614:	00000097          	auipc	ra,0x0
    80000618:	c62080e7          	jalr	-926(ra) # 80000276 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000061c:	2985                	addiw	s3,s3,1
    8000061e:	013a07b3          	add	a5,s4,s3
    80000622:	0007c503          	lbu	a0,0(a5)
    80000626:	10050463          	beqz	a0,8000072e <printf+0x1ac>
    if(c != '%'){
    8000062a:	ff5515e3          	bne	a0,s5,80000614 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000062e:	2985                	addiw	s3,s3,1
    80000630:	013a07b3          	add	a5,s4,s3
    80000634:	0007c783          	lbu	a5,0(a5)
    80000638:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000063c:	cbed                	beqz	a5,8000072e <printf+0x1ac>
    switch(c){
    8000063e:	05778a63          	beq	a5,s7,80000692 <printf+0x110>
    80000642:	02fbf663          	bgeu	s7,a5,8000066e <printf+0xec>
    80000646:	09978863          	beq	a5,s9,800006d6 <printf+0x154>
    8000064a:	07800713          	li	a4,120
    8000064e:	0ce79563          	bne	a5,a4,80000718 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000652:	f8843783          	ld	a5,-120(s0)
    80000656:	00878713          	addi	a4,a5,8
    8000065a:	f8e43423          	sd	a4,-120(s0)
    8000065e:	4605                	li	a2,1
    80000660:	85ea                	mv	a1,s10
    80000662:	4388                	lw	a0,0(a5)
    80000664:	00000097          	auipc	ra,0x0
    80000668:	e32080e7          	jalr	-462(ra) # 80000496 <printint>
      break;
    8000066c:	bf45                	j	8000061c <printf+0x9a>
    switch(c){
    8000066e:	09578f63          	beq	a5,s5,8000070c <printf+0x18a>
    80000672:	0b879363          	bne	a5,s8,80000718 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000676:	f8843783          	ld	a5,-120(s0)
    8000067a:	00878713          	addi	a4,a5,8
    8000067e:	f8e43423          	sd	a4,-120(s0)
    80000682:	4605                	li	a2,1
    80000684:	45a9                	li	a1,10
    80000686:	4388                	lw	a0,0(a5)
    80000688:	00000097          	auipc	ra,0x0
    8000068c:	e0e080e7          	jalr	-498(ra) # 80000496 <printint>
      break;
    80000690:	b771                	j	8000061c <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a2:	03000513          	li	a0,48
    800006a6:	00000097          	auipc	ra,0x0
    800006aa:	bd0080e7          	jalr	-1072(ra) # 80000276 <consputc>
  consputc('x');
    800006ae:	07800513          	li	a0,120
    800006b2:	00000097          	auipc	ra,0x0
    800006b6:	bc4080e7          	jalr	-1084(ra) # 80000276 <consputc>
    800006ba:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006bc:	03c95793          	srli	a5,s2,0x3c
    800006c0:	97da                	add	a5,a5,s6
    800006c2:	0007c503          	lbu	a0,0(a5)
    800006c6:	00000097          	auipc	ra,0x0
    800006ca:	bb0080e7          	jalr	-1104(ra) # 80000276 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006ce:	0912                	slli	s2,s2,0x4
    800006d0:	34fd                	addiw	s1,s1,-1
    800006d2:	f4ed                	bnez	s1,800006bc <printf+0x13a>
    800006d4:	b7a1                	j	8000061c <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006d6:	f8843783          	ld	a5,-120(s0)
    800006da:	00878713          	addi	a4,a5,8
    800006de:	f8e43423          	sd	a4,-120(s0)
    800006e2:	6384                	ld	s1,0(a5)
    800006e4:	cc89                	beqz	s1,800006fe <printf+0x17c>
      for(; *s; s++)
    800006e6:	0004c503          	lbu	a0,0(s1)
    800006ea:	d90d                	beqz	a0,8000061c <printf+0x9a>
        consputc(*s);
    800006ec:	00000097          	auipc	ra,0x0
    800006f0:	b8a080e7          	jalr	-1142(ra) # 80000276 <consputc>
      for(; *s; s++)
    800006f4:	0485                	addi	s1,s1,1
    800006f6:	0004c503          	lbu	a0,0(s1)
    800006fa:	f96d                	bnez	a0,800006ec <printf+0x16a>
    800006fc:	b705                	j	8000061c <printf+0x9a>
        s = "(null)";
    800006fe:	00008497          	auipc	s1,0x8
    80000702:	92248493          	addi	s1,s1,-1758 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000706:	02800513          	li	a0,40
    8000070a:	b7cd                	j	800006ec <printf+0x16a>
      consputc('%');
    8000070c:	8556                	mv	a0,s5
    8000070e:	00000097          	auipc	ra,0x0
    80000712:	b68080e7          	jalr	-1176(ra) # 80000276 <consputc>
      break;
    80000716:	b719                	j	8000061c <printf+0x9a>
      consputc('%');
    80000718:	8556                	mv	a0,s5
    8000071a:	00000097          	auipc	ra,0x0
    8000071e:	b5c080e7          	jalr	-1188(ra) # 80000276 <consputc>
      consputc(c);
    80000722:	8526                	mv	a0,s1
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b52080e7          	jalr	-1198(ra) # 80000276 <consputc>
      break;
    8000072c:	bdc5                	j	8000061c <printf+0x9a>
  if(locking)
    8000072e:	020d9163          	bnez	s11,80000750 <printf+0x1ce>
}
    80000732:	70e6                	ld	ra,120(sp)
    80000734:	7446                	ld	s0,112(sp)
    80000736:	74a6                	ld	s1,104(sp)
    80000738:	7906                	ld	s2,96(sp)
    8000073a:	69e6                	ld	s3,88(sp)
    8000073c:	6a46                	ld	s4,80(sp)
    8000073e:	6aa6                	ld	s5,72(sp)
    80000740:	6b06                	ld	s6,64(sp)
    80000742:	7be2                	ld	s7,56(sp)
    80000744:	7c42                	ld	s8,48(sp)
    80000746:	7ca2                	ld	s9,40(sp)
    80000748:	7d02                	ld	s10,32(sp)
    8000074a:	6de2                	ld	s11,24(sp)
    8000074c:	6129                	addi	sp,sp,192
    8000074e:	8082                	ret
    release(&pr.lock);
    80000750:	00010517          	auipc	a0,0x10
    80000754:	3c850513          	addi	a0,a0,968 # 80010b18 <pr>
    80000758:	00000097          	auipc	ra,0x0
    8000075c:	52c080e7          	jalr	1324(ra) # 80000c84 <release>
}
    80000760:	bfc9                	j	80000732 <printf+0x1b0>

0000000080000762 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000762:	1101                	addi	sp,sp,-32
    80000764:	ec06                	sd	ra,24(sp)
    80000766:	e822                	sd	s0,16(sp)
    80000768:	e426                	sd	s1,8(sp)
    8000076a:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000076c:	00010497          	auipc	s1,0x10
    80000770:	3ac48493          	addi	s1,s1,940 # 80010b18 <pr>
    80000774:	00008597          	auipc	a1,0x8
    80000778:	8c458593          	addi	a1,a1,-1852 # 80008038 <etext+0x38>
    8000077c:	8526                	mv	a0,s1
    8000077e:	00000097          	auipc	ra,0x0
    80000782:	3c2080e7          	jalr	962(ra) # 80000b40 <initlock>
  pr.locking = 1;
    80000786:	4785                	li	a5,1
    80000788:	cc9c                	sw	a5,24(s1)
}
    8000078a:	60e2                	ld	ra,24(sp)
    8000078c:	6442                	ld	s0,16(sp)
    8000078e:	64a2                	ld	s1,8(sp)
    80000790:	6105                	addi	sp,sp,32
    80000792:	8082                	ret

0000000080000794 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000794:	1141                	addi	sp,sp,-16
    80000796:	e406                	sd	ra,8(sp)
    80000798:	e022                	sd	s0,0(sp)
    8000079a:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000079c:	100007b7          	lui	a5,0x10000
    800007a0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a4:	f8000713          	li	a4,-128
    800007a8:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ac:	470d                	li	a4,3
    800007ae:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b2:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007b6:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ba:	469d                	li	a3,7
    800007bc:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c0:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c4:	00008597          	auipc	a1,0x8
    800007c8:	89458593          	addi	a1,a1,-1900 # 80008058 <digits+0x18>
    800007cc:	00010517          	auipc	a0,0x10
    800007d0:	36c50513          	addi	a0,a0,876 # 80010b38 <uart_tx_lock>
    800007d4:	00000097          	auipc	ra,0x0
    800007d8:	36c080e7          	jalr	876(ra) # 80000b40 <initlock>
}
    800007dc:	60a2                	ld	ra,8(sp)
    800007de:	6402                	ld	s0,0(sp)
    800007e0:	0141                	addi	sp,sp,16
    800007e2:	8082                	ret

00000000800007e4 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e4:	1101                	addi	sp,sp,-32
    800007e6:	ec06                	sd	ra,24(sp)
    800007e8:	e822                	sd	s0,16(sp)
    800007ea:	e426                	sd	s1,8(sp)
    800007ec:	1000                	addi	s0,sp,32
    800007ee:	84aa                	mv	s1,a0
  push_off();
    800007f0:	00000097          	auipc	ra,0x0
    800007f4:	394080e7          	jalr	916(ra) # 80000b84 <push_off>

  if(panicked){
    800007f8:	00008797          	auipc	a5,0x8
    800007fc:	0f87a783          	lw	a5,248(a5) # 800088f0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000800:	10000737          	lui	a4,0x10000
  if(panicked){
    80000804:	c391                	beqz	a5,80000808 <uartputc_sync+0x24>
    for(;;)
    80000806:	a001                	j	80000806 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000080c:	0207f793          	andi	a5,a5,32
    80000810:	dfe5                	beqz	a5,80000808 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000812:	0ff4f513          	andi	a0,s1,255
    80000816:	100007b7          	lui	a5,0x10000
    8000081a:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000081e:	00000097          	auipc	ra,0x0
    80000822:	406080e7          	jalr	1030(ra) # 80000c24 <pop_off>
}
    80000826:	60e2                	ld	ra,24(sp)
    80000828:	6442                	ld	s0,16(sp)
    8000082a:	64a2                	ld	s1,8(sp)
    8000082c:	6105                	addi	sp,sp,32
    8000082e:	8082                	ret

0000000080000830 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000830:	00008797          	auipc	a5,0x8
    80000834:	0c87b783          	ld	a5,200(a5) # 800088f8 <uart_tx_r>
    80000838:	00008717          	auipc	a4,0x8
    8000083c:	0c873703          	ld	a4,200(a4) # 80008900 <uart_tx_w>
    80000840:	06f70a63          	beq	a4,a5,800008b4 <uartstart+0x84>
{
    80000844:	7139                	addi	sp,sp,-64
    80000846:	fc06                	sd	ra,56(sp)
    80000848:	f822                	sd	s0,48(sp)
    8000084a:	f426                	sd	s1,40(sp)
    8000084c:	f04a                	sd	s2,32(sp)
    8000084e:	ec4e                	sd	s3,24(sp)
    80000850:	e852                	sd	s4,16(sp)
    80000852:	e456                	sd	s5,8(sp)
    80000854:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000856:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085a:	00010a17          	auipc	s4,0x10
    8000085e:	2dea0a13          	addi	s4,s4,734 # 80010b38 <uart_tx_lock>
    uart_tx_r += 1;
    80000862:	00008497          	auipc	s1,0x8
    80000866:	09648493          	addi	s1,s1,150 # 800088f8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086a:	00008997          	auipc	s3,0x8
    8000086e:	09698993          	addi	s3,s3,150 # 80008900 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000872:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000876:	02077713          	andi	a4,a4,32
    8000087a:	c705                	beqz	a4,800008a2 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000087c:	01f7f713          	andi	a4,a5,31
    80000880:	9752                	add	a4,a4,s4
    80000882:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80000886:	0785                	addi	a5,a5,1
    80000888:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088a:	8526                	mv	a0,s1
    8000088c:	00002097          	auipc	ra,0x2
    80000890:	cda080e7          	jalr	-806(ra) # 80002566 <wakeup>
    
    WriteReg(THR, c);
    80000894:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    80000898:	609c                	ld	a5,0(s1)
    8000089a:	0009b703          	ld	a4,0(s3)
    8000089e:	fcf71ae3          	bne	a4,a5,80000872 <uartstart+0x42>
  }
}
    800008a2:	70e2                	ld	ra,56(sp)
    800008a4:	7442                	ld	s0,48(sp)
    800008a6:	74a2                	ld	s1,40(sp)
    800008a8:	7902                	ld	s2,32(sp)
    800008aa:	69e2                	ld	s3,24(sp)
    800008ac:	6a42                	ld	s4,16(sp)
    800008ae:	6aa2                	ld	s5,8(sp)
    800008b0:	6121                	addi	sp,sp,64
    800008b2:	8082                	ret
    800008b4:	8082                	ret

00000000800008b6 <uartputc>:
{
    800008b6:	7179                	addi	sp,sp,-48
    800008b8:	f406                	sd	ra,40(sp)
    800008ba:	f022                	sd	s0,32(sp)
    800008bc:	ec26                	sd	s1,24(sp)
    800008be:	e84a                	sd	s2,16(sp)
    800008c0:	e44e                	sd	s3,8(sp)
    800008c2:	e052                	sd	s4,0(sp)
    800008c4:	1800                	addi	s0,sp,48
    800008c6:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008c8:	00010517          	auipc	a0,0x10
    800008cc:	27050513          	addi	a0,a0,624 # 80010b38 <uart_tx_lock>
    800008d0:	00000097          	auipc	ra,0x0
    800008d4:	300080e7          	jalr	768(ra) # 80000bd0 <acquire>
  if(panicked){
    800008d8:	00008797          	auipc	a5,0x8
    800008dc:	0187a783          	lw	a5,24(a5) # 800088f0 <panicked>
    800008e0:	c391                	beqz	a5,800008e4 <uartputc+0x2e>
    for(;;)
    800008e2:	a001                	j	800008e2 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e4:	00008717          	auipc	a4,0x8
    800008e8:	01c73703          	ld	a4,28(a4) # 80008900 <uart_tx_w>
    800008ec:	00008797          	auipc	a5,0x8
    800008f0:	00c7b783          	ld	a5,12(a5) # 800088f8 <uart_tx_r>
    800008f4:	02078793          	addi	a5,a5,32
    800008f8:	02e79b63          	bne	a5,a4,8000092e <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	23c98993          	addi	s3,s3,572 # 80010b38 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	ff448493          	addi	s1,s1,-12 # 800088f8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	ff490913          	addi	s2,s2,-12 # 80008900 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000914:	85ce                	mv	a1,s3
    80000916:	8526                	mv	a0,s1
    80000918:	00002097          	auipc	ra,0x2
    8000091c:	ac2080e7          	jalr	-1342(ra) # 800023da <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00093703          	ld	a4,0(s2)
    80000924:	609c                	ld	a5,0(s1)
    80000926:	02078793          	addi	a5,a5,32
    8000092a:	fee785e3          	beq	a5,a4,80000914 <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000092e:	00010497          	auipc	s1,0x10
    80000932:	20a48493          	addi	s1,s1,522 # 80010b38 <uart_tx_lock>
    80000936:	01f77793          	andi	a5,a4,31
    8000093a:	97a6                	add	a5,a5,s1
    8000093c:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000940:	0705                	addi	a4,a4,1
    80000942:	00008797          	auipc	a5,0x8
    80000946:	fae7bf23          	sd	a4,-66(a5) # 80008900 <uart_tx_w>
      uartstart();
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	ee6080e7          	jalr	-282(ra) # 80000830 <uartstart>
      release(&uart_tx_lock);
    80000952:	8526                	mv	a0,s1
    80000954:	00000097          	auipc	ra,0x0
    80000958:	330080e7          	jalr	816(ra) # 80000c84 <release>
}
    8000095c:	70a2                	ld	ra,40(sp)
    8000095e:	7402                	ld	s0,32(sp)
    80000960:	64e2                	ld	s1,24(sp)
    80000962:	6942                	ld	s2,16(sp)
    80000964:	69a2                	ld	s3,8(sp)
    80000966:	6a02                	ld	s4,0(sp)
    80000968:	6145                	addi	sp,sp,48
    8000096a:	8082                	ret

000000008000096c <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000096c:	1141                	addi	sp,sp,-16
    8000096e:	e422                	sd	s0,8(sp)
    80000970:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000972:	100007b7          	lui	a5,0x10000
    80000976:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097a:	8b85                	andi	a5,a5,1
    8000097c:	cb91                	beqz	a5,80000990 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    8000097e:	100007b7          	lui	a5,0x10000
    80000982:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000986:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	addi	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1e>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000994:	1101                	addi	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	916080e7          	jalr	-1770(ra) # 800002b8 <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc2080e7          	jalr	-62(ra) # 8000096c <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	18248493          	addi	s1,s1,386 # 80010b38 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	210080e7          	jalr	528(ra) # 80000bd0 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e68080e7          	jalr	-408(ra) # 80000830 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b2080e7          	jalr	690(ra) # 80000c84 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	addi	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	addi	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	slli	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00022797          	auipc	a5,0x22
    800009fc:	67878793          	addi	a5,a5,1656 # 80023070 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	slli	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2bc080e7          	jalr	700(ra) # 80000ccc <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	15890913          	addi	s2,s2,344 # 80010b70 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1ae080e7          	jalr	430(ra) # 80000bd0 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	24e080e7          	jalr	590(ra) # 80000c84 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	addi	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	ae6080e7          	jalr	-1306(ra) # 80000538 <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	addi	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	94aa                	add	s1,s1,a0
    80000a72:	757d                	lui	a0,0xfffff
    80000a74:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a76:	94be                	add	s1,s1,a5
    80000a78:	0095ee63          	bltu	a1,s1,80000a94 <freerange+0x3a>
    80000a7c:	892e                	mv	s2,a1
    kfree(p);
    80000a7e:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a80:	6985                	lui	s3,0x1
    kfree(p);
    80000a82:	01448533          	add	a0,s1,s4
    80000a86:	00000097          	auipc	ra,0x0
    80000a8a:	f5e080e7          	jalr	-162(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8e:	94ce                	add	s1,s1,s3
    80000a90:	fe9979e3          	bgeu	s2,s1,80000a82 <freerange+0x28>
}
    80000a94:	70a2                	ld	ra,40(sp)
    80000a96:	7402                	ld	s0,32(sp)
    80000a98:	64e2                	ld	s1,24(sp)
    80000a9a:	6942                	ld	s2,16(sp)
    80000a9c:	69a2                	ld	s3,8(sp)
    80000a9e:	6a02                	ld	s4,0(sp)
    80000aa0:	6145                	addi	sp,sp,48
    80000aa2:	8082                	ret

0000000080000aa4 <kinit>:
{
    80000aa4:	1141                	addi	sp,sp,-16
    80000aa6:	e406                	sd	ra,8(sp)
    80000aa8:	e022                	sd	s0,0(sp)
    80000aaa:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aac:	00007597          	auipc	a1,0x7
    80000ab0:	5bc58593          	addi	a1,a1,1468 # 80008068 <digits+0x28>
    80000ab4:	00010517          	auipc	a0,0x10
    80000ab8:	0bc50513          	addi	a0,a0,188 # 80010b70 <kmem>
    80000abc:	00000097          	auipc	ra,0x0
    80000ac0:	084080e7          	jalr	132(ra) # 80000b40 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac4:	45c5                	li	a1,17
    80000ac6:	05ee                	slli	a1,a1,0x1b
    80000ac8:	00022517          	auipc	a0,0x22
    80000acc:	5a850513          	addi	a0,a0,1448 # 80023070 <end>
    80000ad0:	00000097          	auipc	ra,0x0
    80000ad4:	f8a080e7          	jalr	-118(ra) # 80000a5a <freerange>
}
    80000ad8:	60a2                	ld	ra,8(sp)
    80000ada:	6402                	ld	s0,0(sp)
    80000adc:	0141                	addi	sp,sp,16
    80000ade:	8082                	ret

0000000080000ae0 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae0:	1101                	addi	sp,sp,-32
    80000ae2:	ec06                	sd	ra,24(sp)
    80000ae4:	e822                	sd	s0,16(sp)
    80000ae6:	e426                	sd	s1,8(sp)
    80000ae8:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aea:	00010497          	auipc	s1,0x10
    80000aee:	08648493          	addi	s1,s1,134 # 80010b70 <kmem>
    80000af2:	8526                	mv	a0,s1
    80000af4:	00000097          	auipc	ra,0x0
    80000af8:	0dc080e7          	jalr	220(ra) # 80000bd0 <acquire>
  r = kmem.freelist;
    80000afc:	6c84                	ld	s1,24(s1)
  if(r)
    80000afe:	c885                	beqz	s1,80000b2e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b00:	609c                	ld	a5,0(s1)
    80000b02:	00010517          	auipc	a0,0x10
    80000b06:	06e50513          	addi	a0,a0,110 # 80010b70 <kmem>
    80000b0a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0c:	00000097          	auipc	ra,0x0
    80000b10:	178080e7          	jalr	376(ra) # 80000c84 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b14:	6605                	lui	a2,0x1
    80000b16:	4595                	li	a1,5
    80000b18:	8526                	mv	a0,s1
    80000b1a:	00000097          	auipc	ra,0x0
    80000b1e:	1b2080e7          	jalr	434(ra) # 80000ccc <memset>
  return (void*)r;
}
    80000b22:	8526                	mv	a0,s1
    80000b24:	60e2                	ld	ra,24(sp)
    80000b26:	6442                	ld	s0,16(sp)
    80000b28:	64a2                	ld	s1,8(sp)
    80000b2a:	6105                	addi	sp,sp,32
    80000b2c:	8082                	ret
  release(&kmem.lock);
    80000b2e:	00010517          	auipc	a0,0x10
    80000b32:	04250513          	addi	a0,a0,66 # 80010b70 <kmem>
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	14e080e7          	jalr	334(ra) # 80000c84 <release>
  if(r)
    80000b3e:	b7d5                	j	80000b22 <kalloc+0x42>

0000000080000b40 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b40:	1141                	addi	sp,sp,-16
    80000b42:	e422                	sd	s0,8(sp)
    80000b44:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b46:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b48:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4c:	00053823          	sd	zero,16(a0)
}
    80000b50:	6422                	ld	s0,8(sp)
    80000b52:	0141                	addi	sp,sp,16
    80000b54:	8082                	ret

0000000080000b56 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b56:	411c                	lw	a5,0(a0)
    80000b58:	e399                	bnez	a5,80000b5e <holding+0x8>
    80000b5a:	4501                	li	a0,0
  return r;
}
    80000b5c:	8082                	ret
{
    80000b5e:	1101                	addi	sp,sp,-32
    80000b60:	ec06                	sd	ra,24(sp)
    80000b62:	e822                	sd	s0,16(sp)
    80000b64:	e426                	sd	s1,8(sp)
    80000b66:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b68:	6904                	ld	s1,16(a0)
    80000b6a:	00001097          	auipc	ra,0x1
    80000b6e:	e7c080e7          	jalr	-388(ra) # 800019e6 <mycpu>
    80000b72:	40a48533          	sub	a0,s1,a0
    80000b76:	00153513          	seqz	a0,a0
}
    80000b7a:	60e2                	ld	ra,24(sp)
    80000b7c:	6442                	ld	s0,16(sp)
    80000b7e:	64a2                	ld	s1,8(sp)
    80000b80:	6105                	addi	sp,sp,32
    80000b82:	8082                	ret

0000000080000b84 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b84:	1101                	addi	sp,sp,-32
    80000b86:	ec06                	sd	ra,24(sp)
    80000b88:	e822                	sd	s0,16(sp)
    80000b8a:	e426                	sd	s1,8(sp)
    80000b8c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b8e:	100024f3          	csrr	s1,sstatus
    80000b92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b96:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b98:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9c:	00001097          	auipc	ra,0x1
    80000ba0:	e4a080e7          	jalr	-438(ra) # 800019e6 <mycpu>
    80000ba4:	5d3c                	lw	a5,120(a0)
    80000ba6:	cf89                	beqz	a5,80000bc0 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000ba8:	00001097          	auipc	ra,0x1
    80000bac:	e3e080e7          	jalr	-450(ra) # 800019e6 <mycpu>
    80000bb0:	5d3c                	lw	a5,120(a0)
    80000bb2:	2785                	addiw	a5,a5,1
    80000bb4:	dd3c                	sw	a5,120(a0)
}
    80000bb6:	60e2                	ld	ra,24(sp)
    80000bb8:	6442                	ld	s0,16(sp)
    80000bba:	64a2                	ld	s1,8(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret
    mycpu()->intena = old;
    80000bc0:	00001097          	auipc	ra,0x1
    80000bc4:	e26080e7          	jalr	-474(ra) # 800019e6 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bc8:	8085                	srli	s1,s1,0x1
    80000bca:	8885                	andi	s1,s1,1
    80000bcc:	dd64                	sw	s1,124(a0)
    80000bce:	bfe9                	j	80000ba8 <push_off+0x24>

0000000080000bd0 <acquire>:
{
    80000bd0:	1101                	addi	sp,sp,-32
    80000bd2:	ec06                	sd	ra,24(sp)
    80000bd4:	e822                	sd	s0,16(sp)
    80000bd6:	e426                	sd	s1,8(sp)
    80000bd8:	1000                	addi	s0,sp,32
    80000bda:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bdc:	00000097          	auipc	ra,0x0
    80000be0:	fa8080e7          	jalr	-88(ra) # 80000b84 <push_off>
  if(holding(lk))
    80000be4:	8526                	mv	a0,s1
    80000be6:	00000097          	auipc	ra,0x0
    80000bea:	f70080e7          	jalr	-144(ra) # 80000b56 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bee:	4705                	li	a4,1
  if(holding(lk))
    80000bf0:	e115                	bnez	a0,80000c14 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf2:	87ba                	mv	a5,a4
    80000bf4:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bf8:	2781                	sext.w	a5,a5
    80000bfa:	ffe5                	bnez	a5,80000bf2 <acquire+0x22>
  __sync_synchronize();
    80000bfc:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c00:	00001097          	auipc	ra,0x1
    80000c04:	de6080e7          	jalr	-538(ra) # 800019e6 <mycpu>
    80000c08:	e888                	sd	a0,16(s1)
}
    80000c0a:	60e2                	ld	ra,24(sp)
    80000c0c:	6442                	ld	s0,16(sp)
    80000c0e:	64a2                	ld	s1,8(sp)
    80000c10:	6105                	addi	sp,sp,32
    80000c12:	8082                	ret
    panic("acquire");
    80000c14:	00007517          	auipc	a0,0x7
    80000c18:	45c50513          	addi	a0,a0,1116 # 80008070 <digits+0x30>
    80000c1c:	00000097          	auipc	ra,0x0
    80000c20:	91c080e7          	jalr	-1764(ra) # 80000538 <panic>

0000000080000c24 <pop_off>:

void
pop_off(void)
{
    80000c24:	1141                	addi	sp,sp,-16
    80000c26:	e406                	sd	ra,8(sp)
    80000c28:	e022                	sd	s0,0(sp)
    80000c2a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2c:	00001097          	auipc	ra,0x1
    80000c30:	dba080e7          	jalr	-582(ra) # 800019e6 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c34:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c38:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3a:	e78d                	bnez	a5,80000c64 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3c:	5d3c                	lw	a5,120(a0)
    80000c3e:	02f05b63          	blez	a5,80000c74 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c42:	37fd                	addiw	a5,a5,-1
    80000c44:	0007871b          	sext.w	a4,a5
    80000c48:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4a:	eb09                	bnez	a4,80000c5c <pop_off+0x38>
    80000c4c:	5d7c                	lw	a5,124(a0)
    80000c4e:	c799                	beqz	a5,80000c5c <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c50:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c54:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c58:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5c:	60a2                	ld	ra,8(sp)
    80000c5e:	6402                	ld	s0,0(sp)
    80000c60:	0141                	addi	sp,sp,16
    80000c62:	8082                	ret
    panic("pop_off - interruptible");
    80000c64:	00007517          	auipc	a0,0x7
    80000c68:	41450513          	addi	a0,a0,1044 # 80008078 <digits+0x38>
    80000c6c:	00000097          	auipc	ra,0x0
    80000c70:	8cc080e7          	jalr	-1844(ra) # 80000538 <panic>
    panic("pop_off");
    80000c74:	00007517          	auipc	a0,0x7
    80000c78:	41c50513          	addi	a0,a0,1052 # 80008090 <digits+0x50>
    80000c7c:	00000097          	auipc	ra,0x0
    80000c80:	8bc080e7          	jalr	-1860(ra) # 80000538 <panic>

0000000080000c84 <release>:
{
    80000c84:	1101                	addi	sp,sp,-32
    80000c86:	ec06                	sd	ra,24(sp)
    80000c88:	e822                	sd	s0,16(sp)
    80000c8a:	e426                	sd	s1,8(sp)
    80000c8c:	1000                	addi	s0,sp,32
    80000c8e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c90:	00000097          	auipc	ra,0x0
    80000c94:	ec6080e7          	jalr	-314(ra) # 80000b56 <holding>
    80000c98:	c115                	beqz	a0,80000cbc <release+0x38>
  lk->cpu = 0;
    80000c9a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c9e:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca2:	0f50000f          	fence	iorw,ow
    80000ca6:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	f7a080e7          	jalr	-134(ra) # 80000c24 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00007517          	auipc	a0,0x7
    80000cc0:	3dc50513          	addi	a0,a0,988 # 80008098 <digits+0x58>
    80000cc4:	00000097          	auipc	ra,0x0
    80000cc8:	874080e7          	jalr	-1932(ra) # 80000538 <panic>

0000000080000ccc <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ccc:	1141                	addi	sp,sp,-16
    80000cce:	e422                	sd	s0,8(sp)
    80000cd0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd2:	ca19                	beqz	a2,80000ce8 <memset+0x1c>
    80000cd4:	87aa                	mv	a5,a0
    80000cd6:	1602                	slli	a2,a2,0x20
    80000cd8:	9201                	srli	a2,a2,0x20
    80000cda:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cde:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce2:	0785                	addi	a5,a5,1
    80000ce4:	fee79de3          	bne	a5,a4,80000cde <memset+0x12>
  }
  return dst;
}
    80000ce8:	6422                	ld	s0,8(sp)
    80000cea:	0141                	addi	sp,sp,16
    80000cec:	8082                	ret

0000000080000cee <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cee:	1141                	addi	sp,sp,-16
    80000cf0:	e422                	sd	s0,8(sp)
    80000cf2:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf4:	ca05                	beqz	a2,80000d24 <memcmp+0x36>
    80000cf6:	fff6069b          	addiw	a3,a2,-1
    80000cfa:	1682                	slli	a3,a3,0x20
    80000cfc:	9281                	srli	a3,a3,0x20
    80000cfe:	0685                	addi	a3,a3,1
    80000d00:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d02:	00054783          	lbu	a5,0(a0)
    80000d06:	0005c703          	lbu	a4,0(a1)
    80000d0a:	00e79863          	bne	a5,a4,80000d1a <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0e:	0505                	addi	a0,a0,1
    80000d10:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d12:	fed518e3          	bne	a0,a3,80000d02 <memcmp+0x14>
  }

  return 0;
    80000d16:	4501                	li	a0,0
    80000d18:	a019                	j	80000d1e <memcmp+0x30>
      return *s1 - *s2;
    80000d1a:	40e7853b          	subw	a0,a5,a4
}
    80000d1e:	6422                	ld	s0,8(sp)
    80000d20:	0141                	addi	sp,sp,16
    80000d22:	8082                	ret
  return 0;
    80000d24:	4501                	li	a0,0
    80000d26:	bfe5                	j	80000d1e <memcmp+0x30>

0000000080000d28 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d28:	1141                	addi	sp,sp,-16
    80000d2a:	e422                	sd	s0,8(sp)
    80000d2c:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2e:	c205                	beqz	a2,80000d4e <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d30:	02a5e263          	bltu	a1,a0,80000d54 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d34:	1602                	slli	a2,a2,0x20
    80000d36:	9201                	srli	a2,a2,0x20
    80000d38:	00c587b3          	add	a5,a1,a2
{
    80000d3c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3e:	0585                	addi	a1,a1,1
    80000d40:	0705                	addi	a4,a4,1
    80000d42:	fff5c683          	lbu	a3,-1(a1)
    80000d46:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4a:	fef59ae3          	bne	a1,a5,80000d3e <memmove+0x16>

  return dst;
}
    80000d4e:	6422                	ld	s0,8(sp)
    80000d50:	0141                	addi	sp,sp,16
    80000d52:	8082                	ret
  if(s < d && s + n > d){
    80000d54:	02061693          	slli	a3,a2,0x20
    80000d58:	9281                	srli	a3,a3,0x20
    80000d5a:	00d58733          	add	a4,a1,a3
    80000d5e:	fce57be3          	bgeu	a0,a4,80000d34 <memmove+0xc>
    d += n;
    80000d62:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d64:	fff6079b          	addiw	a5,a2,-1
    80000d68:	1782                	slli	a5,a5,0x20
    80000d6a:	9381                	srli	a5,a5,0x20
    80000d6c:	fff7c793          	not	a5,a5
    80000d70:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d72:	177d                	addi	a4,a4,-1
    80000d74:	16fd                	addi	a3,a3,-1
    80000d76:	00074603          	lbu	a2,0(a4)
    80000d7a:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7e:	fee79ae3          	bne	a5,a4,80000d72 <memmove+0x4a>
    80000d82:	b7f1                	j	80000d4e <memmove+0x26>

0000000080000d84 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d84:	1141                	addi	sp,sp,-16
    80000d86:	e406                	sd	ra,8(sp)
    80000d88:	e022                	sd	s0,0(sp)
    80000d8a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8c:	00000097          	auipc	ra,0x0
    80000d90:	f9c080e7          	jalr	-100(ra) # 80000d28 <memmove>
}
    80000d94:	60a2                	ld	ra,8(sp)
    80000d96:	6402                	ld	s0,0(sp)
    80000d98:	0141                	addi	sp,sp,16
    80000d9a:	8082                	ret

0000000080000d9c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9c:	1141                	addi	sp,sp,-16
    80000d9e:	e422                	sd	s0,8(sp)
    80000da0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da2:	ce11                	beqz	a2,80000dbe <strncmp+0x22>
    80000da4:	00054783          	lbu	a5,0(a0)
    80000da8:	cf89                	beqz	a5,80000dc2 <strncmp+0x26>
    80000daa:	0005c703          	lbu	a4,0(a1)
    80000dae:	00f71a63          	bne	a4,a5,80000dc2 <strncmp+0x26>
    n--, p++, q++;
    80000db2:	367d                	addiw	a2,a2,-1
    80000db4:	0505                	addi	a0,a0,1
    80000db6:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db8:	f675                	bnez	a2,80000da4 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dba:	4501                	li	a0,0
    80000dbc:	a809                	j	80000dce <strncmp+0x32>
    80000dbe:	4501                	li	a0,0
    80000dc0:	a039                	j	80000dce <strncmp+0x32>
  if(n == 0)
    80000dc2:	ca09                	beqz	a2,80000dd4 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc4:	00054503          	lbu	a0,0(a0)
    80000dc8:	0005c783          	lbu	a5,0(a1)
    80000dcc:	9d1d                	subw	a0,a0,a5
}
    80000dce:	6422                	ld	s0,8(sp)
    80000dd0:	0141                	addi	sp,sp,16
    80000dd2:	8082                	ret
    return 0;
    80000dd4:	4501                	li	a0,0
    80000dd6:	bfe5                	j	80000dce <strncmp+0x32>

0000000080000dd8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dd8:	1141                	addi	sp,sp,-16
    80000dda:	e422                	sd	s0,8(sp)
    80000ddc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dde:	872a                	mv	a4,a0
    80000de0:	8832                	mv	a6,a2
    80000de2:	367d                	addiw	a2,a2,-1
    80000de4:	01005963          	blez	a6,80000df6 <strncpy+0x1e>
    80000de8:	0705                	addi	a4,a4,1
    80000dea:	0005c783          	lbu	a5,0(a1)
    80000dee:	fef70fa3          	sb	a5,-1(a4)
    80000df2:	0585                	addi	a1,a1,1
    80000df4:	f7f5                	bnez	a5,80000de0 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df6:	86ba                	mv	a3,a4
    80000df8:	00c05c63          	blez	a2,80000e10 <strncpy+0x38>
    *s++ = 0;
    80000dfc:	0685                	addi	a3,a3,1
    80000dfe:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e02:	fff6c793          	not	a5,a3
    80000e06:	9fb9                	addw	a5,a5,a4
    80000e08:	010787bb          	addw	a5,a5,a6
    80000e0c:	fef048e3          	bgtz	a5,80000dfc <strncpy+0x24>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	addi	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	addi	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addiw	a3,a2,-1
    80000e24:	1682                	slli	a3,a3,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	addi	a1,a1,1
    80000e32:	0785                	addi	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	4685                	li	a3,1
    80000e5a:	9e89                	subw	a3,a3,a0
    80000e5c:	00f6853b          	addw	a0,a3,a5
    80000e60:	0785                	addi	a5,a5,1
    80000e62:	fff7c703          	lbu	a4,-1(a5)
    80000e66:	fb7d                	bnez	a4,80000e5c <strlen+0x14>
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b5c080e7          	jalr	-1188(ra) # 800019d6 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	a8670713          	addi	a4,a4,-1402 # 80008908 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	b40080e7          	jalr	-1216(ra) # 800019d6 <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6da080e7          	jalr	1754(ra) # 80000582 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	ab8080e7          	jalr	-1352(ra) # 80002970 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	040080e7          	jalr	64(ra) # 80005f00 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	0da080e7          	jalr	218(ra) # 80001fa2 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57a080e7          	jalr	1402(ra) # 8000044a <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88a080e7          	jalr	-1910(ra) # 80000762 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	addi	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69a080e7          	jalr	1690(ra) # 80000582 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	addi	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68a080e7          	jalr	1674(ra) # 80000582 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	addi	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67a080e7          	jalr	1658(ra) # 80000582 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b94080e7          	jalr	-1132(ra) # 80000aa4 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	322080e7          	jalr	802(ra) # 8000123a <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	9ec080e7          	jalr	-1556(ra) # 80001914 <procinit>
    trapinit();      // trap vectors
    80000f30:	00002097          	auipc	ra,0x2
    80000f34:	a18080e7          	jalr	-1512(ra) # 80002948 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	a38080e7          	jalr	-1480(ra) # 80002970 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	faa080e7          	jalr	-86(ra) # 80005eea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	fb8080e7          	jalr	-72(ra) # 80005f00 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	174080e7          	jalr	372(ra) # 800030c4 <binit>
    iinit();         // inode table
    80000f58:	00003097          	auipc	ra,0x3
    80000f5c:	818080e7          	jalr	-2024(ra) # 80003770 <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	7c2080e7          	jalr	1986(ra) # 80004722 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	0a0080e7          	jalr	160(ra) # 80006008 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	df2080e7          	jalr	-526(ra) # 80001d62 <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	98f72523          	sw	a5,-1654(a4) # 80008908 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f8e:	00008797          	auipc	a5,0x8
    80000f92:	9827b783          	ld	a5,-1662(a5) # 80008910 <kernel_pagetable>
    80000f96:	83b1                	srli	a5,a5,0xc
    80000f98:	577d                	li	a4,-1
    80000f9a:	177e                	slli	a4,a4,0x3f
    80000f9c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f9e:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fa2:	12000073          	sfence.vma
  sfence_vma();
}
    80000fa6:	6422                	ld	s0,8(sp)
    80000fa8:	0141                	addi	sp,sp,16
    80000faa:	8082                	ret

0000000080000fac <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fac:	7139                	addi	sp,sp,-64
    80000fae:	fc06                	sd	ra,56(sp)
    80000fb0:	f822                	sd	s0,48(sp)
    80000fb2:	f426                	sd	s1,40(sp)
    80000fb4:	f04a                	sd	s2,32(sp)
    80000fb6:	ec4e                	sd	s3,24(sp)
    80000fb8:	e852                	sd	s4,16(sp)
    80000fba:	e456                	sd	s5,8(sp)
    80000fbc:	e05a                	sd	s6,0(sp)
    80000fbe:	0080                	addi	s0,sp,64
    80000fc0:	84aa                	mv	s1,a0
    80000fc2:	89ae                	mv	s3,a1
    80000fc4:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fc6:	57fd                	li	a5,-1
    80000fc8:	83e9                	srli	a5,a5,0x1a
    80000fca:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fcc:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fce:	04b7f263          	bgeu	a5,a1,80001012 <walk+0x66>
    panic("walk");
    80000fd2:	00007517          	auipc	a0,0x7
    80000fd6:	0fe50513          	addi	a0,a0,254 # 800080d0 <digits+0x90>
    80000fda:	fffff097          	auipc	ra,0xfffff
    80000fde:	55e080e7          	jalr	1374(ra) # 80000538 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe2:	060a8663          	beqz	s5,8000104e <walk+0xa2>
    80000fe6:	00000097          	auipc	ra,0x0
    80000fea:	afa080e7          	jalr	-1286(ra) # 80000ae0 <kalloc>
    80000fee:	84aa                	mv	s1,a0
    80000ff0:	c529                	beqz	a0,8000103a <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff2:	6605                	lui	a2,0x1
    80000ff4:	4581                	li	a1,0
    80000ff6:	00000097          	auipc	ra,0x0
    80000ffa:	cd6080e7          	jalr	-810(ra) # 80000ccc <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000ffe:	00c4d793          	srli	a5,s1,0xc
    80001002:	07aa                	slli	a5,a5,0xa
    80001004:	0017e793          	ori	a5,a5,1
    80001008:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000100c:	3a5d                	addiw	s4,s4,-9
    8000100e:	036a0063          	beq	s4,s6,8000102e <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001012:	0149d933          	srl	s2,s3,s4
    80001016:	1ff97913          	andi	s2,s2,511
    8000101a:	090e                	slli	s2,s2,0x3
    8000101c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000101e:	00093483          	ld	s1,0(s2)
    80001022:	0014f793          	andi	a5,s1,1
    80001026:	dfd5                	beqz	a5,80000fe2 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001028:	80a9                	srli	s1,s1,0xa
    8000102a:	04b2                	slli	s1,s1,0xc
    8000102c:	b7c5                	j	8000100c <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000102e:	00c9d513          	srli	a0,s3,0xc
    80001032:	1ff57513          	andi	a0,a0,511
    80001036:	050e                	slli	a0,a0,0x3
    80001038:	9526                	add	a0,a0,s1
}
    8000103a:	70e2                	ld	ra,56(sp)
    8000103c:	7442                	ld	s0,48(sp)
    8000103e:	74a2                	ld	s1,40(sp)
    80001040:	7902                	ld	s2,32(sp)
    80001042:	69e2                	ld	s3,24(sp)
    80001044:	6a42                	ld	s4,16(sp)
    80001046:	6aa2                	ld	s5,8(sp)
    80001048:	6b02                	ld	s6,0(sp)
    8000104a:	6121                	addi	sp,sp,64
    8000104c:	8082                	ret
        return 0;
    8000104e:	4501                	li	a0,0
    80001050:	b7ed                	j	8000103a <walk+0x8e>

0000000080001052 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001052:	57fd                	li	a5,-1
    80001054:	83e9                	srli	a5,a5,0x1a
    80001056:	00b7f463          	bgeu	a5,a1,8000105e <walkaddr+0xc>
    return 0;
    8000105a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000105c:	8082                	ret
{
    8000105e:	1141                	addi	sp,sp,-16
    80001060:	e406                	sd	ra,8(sp)
    80001062:	e022                	sd	s0,0(sp)
    80001064:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001066:	4601                	li	a2,0
    80001068:	00000097          	auipc	ra,0x0
    8000106c:	f44080e7          	jalr	-188(ra) # 80000fac <walk>
  if(pte == 0)
    80001070:	c105                	beqz	a0,80001090 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001072:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001074:	0117f693          	andi	a3,a5,17
    80001078:	4745                	li	a4,17
    return 0;
    8000107a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000107c:	00e68663          	beq	a3,a4,80001088 <walkaddr+0x36>
}
    80001080:	60a2                	ld	ra,8(sp)
    80001082:	6402                	ld	s0,0(sp)
    80001084:	0141                	addi	sp,sp,16
    80001086:	8082                	ret
  pa = PTE2PA(*pte);
    80001088:	00a7d513          	srli	a0,a5,0xa
    8000108c:	0532                	slli	a0,a0,0xc
  return pa;
    8000108e:	bfcd                	j	80001080 <walkaddr+0x2e>
    return 0;
    80001090:	4501                	li	a0,0
    80001092:	b7fd                	j	80001080 <walkaddr+0x2e>

0000000080001094 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001094:	715d                	addi	sp,sp,-80
    80001096:	e486                	sd	ra,72(sp)
    80001098:	e0a2                	sd	s0,64(sp)
    8000109a:	fc26                	sd	s1,56(sp)
    8000109c:	f84a                	sd	s2,48(sp)
    8000109e:	f44e                	sd	s3,40(sp)
    800010a0:	f052                	sd	s4,32(sp)
    800010a2:	ec56                	sd	s5,24(sp)
    800010a4:	e85a                	sd	s6,16(sp)
    800010a6:	e45e                	sd	s7,8(sp)
    800010a8:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010aa:	c639                	beqz	a2,800010f8 <mappages+0x64>
    800010ac:	8aaa                	mv	s5,a0
    800010ae:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b0:	77fd                	lui	a5,0xfffff
    800010b2:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010b6:	15fd                	addi	a1,a1,-1
    800010b8:	00c589b3          	add	s3,a1,a2
    800010bc:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010c0:	8952                	mv	s2,s4
    800010c2:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010c6:	6b85                	lui	s7,0x1
    800010c8:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010cc:	4605                	li	a2,1
    800010ce:	85ca                	mv	a1,s2
    800010d0:	8556                	mv	a0,s5
    800010d2:	00000097          	auipc	ra,0x0
    800010d6:	eda080e7          	jalr	-294(ra) # 80000fac <walk>
    800010da:	cd1d                	beqz	a0,80001118 <mappages+0x84>
    if(*pte & PTE_V)
    800010dc:	611c                	ld	a5,0(a0)
    800010de:	8b85                	andi	a5,a5,1
    800010e0:	e785                	bnez	a5,80001108 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e2:	80b1                	srli	s1,s1,0xc
    800010e4:	04aa                	slli	s1,s1,0xa
    800010e6:	0164e4b3          	or	s1,s1,s6
    800010ea:	0014e493          	ori	s1,s1,1
    800010ee:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f0:	05390063          	beq	s2,s3,80001130 <mappages+0x9c>
    a += PGSIZE;
    800010f4:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010f6:	bfc9                	j	800010c8 <mappages+0x34>
    panic("mappages: size");
    800010f8:	00007517          	auipc	a0,0x7
    800010fc:	fe050513          	addi	a0,a0,-32 # 800080d8 <digits+0x98>
    80001100:	fffff097          	auipc	ra,0xfffff
    80001104:	438080e7          	jalr	1080(ra) # 80000538 <panic>
      panic("mappages: remap");
    80001108:	00007517          	auipc	a0,0x7
    8000110c:	fe050513          	addi	a0,a0,-32 # 800080e8 <digits+0xa8>
    80001110:	fffff097          	auipc	ra,0xfffff
    80001114:	428080e7          	jalr	1064(ra) # 80000538 <panic>
      return -1;
    80001118:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111a:	60a6                	ld	ra,72(sp)
    8000111c:	6406                	ld	s0,64(sp)
    8000111e:	74e2                	ld	s1,56(sp)
    80001120:	7942                	ld	s2,48(sp)
    80001122:	79a2                	ld	s3,40(sp)
    80001124:	7a02                	ld	s4,32(sp)
    80001126:	6ae2                	ld	s5,24(sp)
    80001128:	6b42                	ld	s6,16(sp)
    8000112a:	6ba2                	ld	s7,8(sp)
    8000112c:	6161                	addi	sp,sp,80
    8000112e:	8082                	ret
  return 0;
    80001130:	4501                	li	a0,0
    80001132:	b7e5                	j	8000111a <mappages+0x86>

0000000080001134 <kvmmap>:
{
    80001134:	1141                	addi	sp,sp,-16
    80001136:	e406                	sd	ra,8(sp)
    80001138:	e022                	sd	s0,0(sp)
    8000113a:	0800                	addi	s0,sp,16
    8000113c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000113e:	86b2                	mv	a3,a2
    80001140:	863e                	mv	a2,a5
    80001142:	00000097          	auipc	ra,0x0
    80001146:	f52080e7          	jalr	-174(ra) # 80001094 <mappages>
    8000114a:	e509                	bnez	a0,80001154 <kvmmap+0x20>
}
    8000114c:	60a2                	ld	ra,8(sp)
    8000114e:	6402                	ld	s0,0(sp)
    80001150:	0141                	addi	sp,sp,16
    80001152:	8082                	ret
    panic("kvmmap");
    80001154:	00007517          	auipc	a0,0x7
    80001158:	fa450513          	addi	a0,a0,-92 # 800080f8 <digits+0xb8>
    8000115c:	fffff097          	auipc	ra,0xfffff
    80001160:	3dc080e7          	jalr	988(ra) # 80000538 <panic>

0000000080001164 <kvmmake>:
{
    80001164:	1101                	addi	sp,sp,-32
    80001166:	ec06                	sd	ra,24(sp)
    80001168:	e822                	sd	s0,16(sp)
    8000116a:	e426                	sd	s1,8(sp)
    8000116c:	e04a                	sd	s2,0(sp)
    8000116e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001170:	00000097          	auipc	ra,0x0
    80001174:	970080e7          	jalr	-1680(ra) # 80000ae0 <kalloc>
    80001178:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117a:	6605                	lui	a2,0x1
    8000117c:	4581                	li	a1,0
    8000117e:	00000097          	auipc	ra,0x0
    80001182:	b4e080e7          	jalr	-1202(ra) # 80000ccc <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001186:	4719                	li	a4,6
    80001188:	6685                	lui	a3,0x1
    8000118a:	10000637          	lui	a2,0x10000
    8000118e:	100005b7          	lui	a1,0x10000
    80001192:	8526                	mv	a0,s1
    80001194:	00000097          	auipc	ra,0x0
    80001198:	fa0080e7          	jalr	-96(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000119c:	4719                	li	a4,6
    8000119e:	6685                	lui	a3,0x1
    800011a0:	10001637          	lui	a2,0x10001
    800011a4:	100015b7          	lui	a1,0x10001
    800011a8:	8526                	mv	a0,s1
    800011aa:	00000097          	auipc	ra,0x0
    800011ae:	f8a080e7          	jalr	-118(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b2:	4719                	li	a4,6
    800011b4:	004006b7          	lui	a3,0x400
    800011b8:	0c000637          	lui	a2,0xc000
    800011bc:	0c0005b7          	lui	a1,0xc000
    800011c0:	8526                	mv	a0,s1
    800011c2:	00000097          	auipc	ra,0x0
    800011c6:	f72080e7          	jalr	-142(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ca:	00007917          	auipc	s2,0x7
    800011ce:	e3690913          	addi	s2,s2,-458 # 80008000 <etext>
    800011d2:	4729                	li	a4,10
    800011d4:	80007697          	auipc	a3,0x80007
    800011d8:	e2c68693          	addi	a3,a3,-468 # 8000 <_entry-0x7fff8000>
    800011dc:	4605                	li	a2,1
    800011de:	067e                	slli	a2,a2,0x1f
    800011e0:	85b2                	mv	a1,a2
    800011e2:	8526                	mv	a0,s1
    800011e4:	00000097          	auipc	ra,0x0
    800011e8:	f50080e7          	jalr	-176(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011ec:	4719                	li	a4,6
    800011ee:	46c5                	li	a3,17
    800011f0:	06ee                	slli	a3,a3,0x1b
    800011f2:	412686b3          	sub	a3,a3,s2
    800011f6:	864a                	mv	a2,s2
    800011f8:	85ca                	mv	a1,s2
    800011fa:	8526                	mv	a0,s1
    800011fc:	00000097          	auipc	ra,0x0
    80001200:	f38080e7          	jalr	-200(ra) # 80001134 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001204:	4729                	li	a4,10
    80001206:	6685                	lui	a3,0x1
    80001208:	00006617          	auipc	a2,0x6
    8000120c:	df860613          	addi	a2,a2,-520 # 80007000 <_trampoline>
    80001210:	040005b7          	lui	a1,0x4000
    80001214:	15fd                	addi	a1,a1,-1
    80001216:	05b2                	slli	a1,a1,0xc
    80001218:	8526                	mv	a0,s1
    8000121a:	00000097          	auipc	ra,0x0
    8000121e:	f1a080e7          	jalr	-230(ra) # 80001134 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	65a080e7          	jalr	1626(ra) # 8000187e <proc_mapstacks>
}
    8000122c:	8526                	mv	a0,s1
    8000122e:	60e2                	ld	ra,24(sp)
    80001230:	6442                	ld	s0,16(sp)
    80001232:	64a2                	ld	s1,8(sp)
    80001234:	6902                	ld	s2,0(sp)
    80001236:	6105                	addi	sp,sp,32
    80001238:	8082                	ret

000000008000123a <kvminit>:
{
    8000123a:	1141                	addi	sp,sp,-16
    8000123c:	e406                	sd	ra,8(sp)
    8000123e:	e022                	sd	s0,0(sp)
    80001240:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001242:	00000097          	auipc	ra,0x0
    80001246:	f22080e7          	jalr	-222(ra) # 80001164 <kvmmake>
    8000124a:	00007797          	auipc	a5,0x7
    8000124e:	6ca7b323          	sd	a0,1734(a5) # 80008910 <kernel_pagetable>
}
    80001252:	60a2                	ld	ra,8(sp)
    80001254:	6402                	ld	s0,0(sp)
    80001256:	0141                	addi	sp,sp,16
    80001258:	8082                	ret

000000008000125a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125a:	715d                	addi	sp,sp,-80
    8000125c:	e486                	sd	ra,72(sp)
    8000125e:	e0a2                	sd	s0,64(sp)
    80001260:	fc26                	sd	s1,56(sp)
    80001262:	f84a                	sd	s2,48(sp)
    80001264:	f44e                	sd	s3,40(sp)
    80001266:	f052                	sd	s4,32(sp)
    80001268:	ec56                	sd	s5,24(sp)
    8000126a:	e85a                	sd	s6,16(sp)
    8000126c:	e45e                	sd	s7,8(sp)
    8000126e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001270:	03459793          	slli	a5,a1,0x34
    80001274:	e795                	bnez	a5,800012a0 <uvmunmap+0x46>
    80001276:	8a2a                	mv	s4,a0
    80001278:	892e                	mv	s2,a1
    8000127a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000127c:	0632                	slli	a2,a2,0xc
    8000127e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001282:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001284:	6b05                	lui	s6,0x1
    80001286:	0735e263          	bltu	a1,s3,800012ea <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128a:	60a6                	ld	ra,72(sp)
    8000128c:	6406                	ld	s0,64(sp)
    8000128e:	74e2                	ld	s1,56(sp)
    80001290:	7942                	ld	s2,48(sp)
    80001292:	79a2                	ld	s3,40(sp)
    80001294:	7a02                	ld	s4,32(sp)
    80001296:	6ae2                	ld	s5,24(sp)
    80001298:	6b42                	ld	s6,16(sp)
    8000129a:	6ba2                	ld	s7,8(sp)
    8000129c:	6161                	addi	sp,sp,80
    8000129e:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a0:	00007517          	auipc	a0,0x7
    800012a4:	e6050513          	addi	a0,a0,-416 # 80008100 <digits+0xc0>
    800012a8:	fffff097          	auipc	ra,0xfffff
    800012ac:	290080e7          	jalr	656(ra) # 80000538 <panic>
      panic("uvmunmap: walk");
    800012b0:	00007517          	auipc	a0,0x7
    800012b4:	e6850513          	addi	a0,a0,-408 # 80008118 <digits+0xd8>
    800012b8:	fffff097          	auipc	ra,0xfffff
    800012bc:	280080e7          	jalr	640(ra) # 80000538 <panic>
      panic("uvmunmap: not mapped");
    800012c0:	00007517          	auipc	a0,0x7
    800012c4:	e6850513          	addi	a0,a0,-408 # 80008128 <digits+0xe8>
    800012c8:	fffff097          	auipc	ra,0xfffff
    800012cc:	270080e7          	jalr	624(ra) # 80000538 <panic>
      panic("uvmunmap: not a leaf");
    800012d0:	00007517          	auipc	a0,0x7
    800012d4:	e7050513          	addi	a0,a0,-400 # 80008140 <digits+0x100>
    800012d8:	fffff097          	auipc	ra,0xfffff
    800012dc:	260080e7          	jalr	608(ra) # 80000538 <panic>
    *pte = 0;
    800012e0:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e4:	995a                	add	s2,s2,s6
    800012e6:	fb3972e3          	bgeu	s2,s3,8000128a <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ea:	4601                	li	a2,0
    800012ec:	85ca                	mv	a1,s2
    800012ee:	8552                	mv	a0,s4
    800012f0:	00000097          	auipc	ra,0x0
    800012f4:	cbc080e7          	jalr	-836(ra) # 80000fac <walk>
    800012f8:	84aa                	mv	s1,a0
    800012fa:	d95d                	beqz	a0,800012b0 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012fc:	6108                	ld	a0,0(a0)
    800012fe:	00157793          	andi	a5,a0,1
    80001302:	dfdd                	beqz	a5,800012c0 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001304:	3ff57793          	andi	a5,a0,1023
    80001308:	fd7784e3          	beq	a5,s7,800012d0 <uvmunmap+0x76>
    if(do_free){
    8000130c:	fc0a8ae3          	beqz	s5,800012e0 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001310:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001312:	0532                	slli	a0,a0,0xc
    80001314:	fffff097          	auipc	ra,0xfffff
    80001318:	6d0080e7          	jalr	1744(ra) # 800009e4 <kfree>
    8000131c:	b7d1                	j	800012e0 <uvmunmap+0x86>

000000008000131e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000131e:	1101                	addi	sp,sp,-32
    80001320:	ec06                	sd	ra,24(sp)
    80001322:	e822                	sd	s0,16(sp)
    80001324:	e426                	sd	s1,8(sp)
    80001326:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001328:	fffff097          	auipc	ra,0xfffff
    8000132c:	7b8080e7          	jalr	1976(ra) # 80000ae0 <kalloc>
    80001330:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001332:	c519                	beqz	a0,80001340 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001334:	6605                	lui	a2,0x1
    80001336:	4581                	li	a1,0
    80001338:	00000097          	auipc	ra,0x0
    8000133c:	994080e7          	jalr	-1644(ra) # 80000ccc <memset>
  return pagetable;
}
    80001340:	8526                	mv	a0,s1
    80001342:	60e2                	ld	ra,24(sp)
    80001344:	6442                	ld	s0,16(sp)
    80001346:	64a2                	ld	s1,8(sp)
    80001348:	6105                	addi	sp,sp,32
    8000134a:	8082                	ret

000000008000134c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000134c:	7179                	addi	sp,sp,-48
    8000134e:	f406                	sd	ra,40(sp)
    80001350:	f022                	sd	s0,32(sp)
    80001352:	ec26                	sd	s1,24(sp)
    80001354:	e84a                	sd	s2,16(sp)
    80001356:	e44e                	sd	s3,8(sp)
    80001358:	e052                	sd	s4,0(sp)
    8000135a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000135c:	6785                	lui	a5,0x1
    8000135e:	04f67863          	bgeu	a2,a5,800013ae <uvmfirst+0x62>
    80001362:	8a2a                	mv	s4,a0
    80001364:	89ae                	mv	s3,a1
    80001366:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001368:	fffff097          	auipc	ra,0xfffff
    8000136c:	778080e7          	jalr	1912(ra) # 80000ae0 <kalloc>
    80001370:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001372:	6605                	lui	a2,0x1
    80001374:	4581                	li	a1,0
    80001376:	00000097          	auipc	ra,0x0
    8000137a:	956080e7          	jalr	-1706(ra) # 80000ccc <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000137e:	4779                	li	a4,30
    80001380:	86ca                	mv	a3,s2
    80001382:	6605                	lui	a2,0x1
    80001384:	4581                	li	a1,0
    80001386:	8552                	mv	a0,s4
    80001388:	00000097          	auipc	ra,0x0
    8000138c:	d0c080e7          	jalr	-756(ra) # 80001094 <mappages>
  memmove(mem, src, sz);
    80001390:	8626                	mv	a2,s1
    80001392:	85ce                	mv	a1,s3
    80001394:	854a                	mv	a0,s2
    80001396:	00000097          	auipc	ra,0x0
    8000139a:	992080e7          	jalr	-1646(ra) # 80000d28 <memmove>
}
    8000139e:	70a2                	ld	ra,40(sp)
    800013a0:	7402                	ld	s0,32(sp)
    800013a2:	64e2                	ld	s1,24(sp)
    800013a4:	6942                	ld	s2,16(sp)
    800013a6:	69a2                	ld	s3,8(sp)
    800013a8:	6a02                	ld	s4,0(sp)
    800013aa:	6145                	addi	sp,sp,48
    800013ac:	8082                	ret
    panic("uvmfirst: more than a page");
    800013ae:	00007517          	auipc	a0,0x7
    800013b2:	daa50513          	addi	a0,a0,-598 # 80008158 <digits+0x118>
    800013b6:	fffff097          	auipc	ra,0xfffff
    800013ba:	182080e7          	jalr	386(ra) # 80000538 <panic>

00000000800013be <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013be:	1101                	addi	sp,sp,-32
    800013c0:	ec06                	sd	ra,24(sp)
    800013c2:	e822                	sd	s0,16(sp)
    800013c4:	e426                	sd	s1,8(sp)
    800013c6:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013c8:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ca:	00b67d63          	bgeu	a2,a1,800013e4 <uvmdealloc+0x26>
    800013ce:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d0:	6785                	lui	a5,0x1
    800013d2:	17fd                	addi	a5,a5,-1
    800013d4:	00f60733          	add	a4,a2,a5
    800013d8:	767d                	lui	a2,0xfffff
    800013da:	8f71                	and	a4,a4,a2
    800013dc:	97ae                	add	a5,a5,a1
    800013de:	8ff1                	and	a5,a5,a2
    800013e0:	00f76863          	bltu	a4,a5,800013f0 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e4:	8526                	mv	a0,s1
    800013e6:	60e2                	ld	ra,24(sp)
    800013e8:	6442                	ld	s0,16(sp)
    800013ea:	64a2                	ld	s1,8(sp)
    800013ec:	6105                	addi	sp,sp,32
    800013ee:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f0:	8f99                	sub	a5,a5,a4
    800013f2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f4:	4685                	li	a3,1
    800013f6:	0007861b          	sext.w	a2,a5
    800013fa:	85ba                	mv	a1,a4
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	e5e080e7          	jalr	-418(ra) # 8000125a <uvmunmap>
    80001404:	b7c5                	j	800013e4 <uvmdealloc+0x26>

0000000080001406 <uvmalloc>:
  if(newsz < oldsz)
    80001406:	0ab66163          	bltu	a2,a1,800014a8 <uvmalloc+0xa2>
{
    8000140a:	7139                	addi	sp,sp,-64
    8000140c:	fc06                	sd	ra,56(sp)
    8000140e:	f822                	sd	s0,48(sp)
    80001410:	f426                	sd	s1,40(sp)
    80001412:	f04a                	sd	s2,32(sp)
    80001414:	ec4e                	sd	s3,24(sp)
    80001416:	e852                	sd	s4,16(sp)
    80001418:	e456                	sd	s5,8(sp)
    8000141a:	0080                	addi	s0,sp,64
    8000141c:	8aaa                	mv	s5,a0
    8000141e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001420:	6985                	lui	s3,0x1
    80001422:	19fd                	addi	s3,s3,-1
    80001424:	95ce                	add	a1,a1,s3
    80001426:	79fd                	lui	s3,0xfffff
    80001428:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000142c:	08c9f063          	bgeu	s3,a2,800014ac <uvmalloc+0xa6>
    80001430:	894e                	mv	s2,s3
    mem = kalloc();
    80001432:	fffff097          	auipc	ra,0xfffff
    80001436:	6ae080e7          	jalr	1710(ra) # 80000ae0 <kalloc>
    8000143a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000143c:	c51d                	beqz	a0,8000146a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000143e:	6605                	lui	a2,0x1
    80001440:	4581                	li	a1,0
    80001442:	00000097          	auipc	ra,0x0
    80001446:	88a080e7          	jalr	-1910(ra) # 80000ccc <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000144a:	4779                	li	a4,30
    8000144c:	86a6                	mv	a3,s1
    8000144e:	6605                	lui	a2,0x1
    80001450:	85ca                	mv	a1,s2
    80001452:	8556                	mv	a0,s5
    80001454:	00000097          	auipc	ra,0x0
    80001458:	c40080e7          	jalr	-960(ra) # 80001094 <mappages>
    8000145c:	e905                	bnez	a0,8000148c <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000145e:	6785                	lui	a5,0x1
    80001460:	993e                	add	s2,s2,a5
    80001462:	fd4968e3          	bltu	s2,s4,80001432 <uvmalloc+0x2c>
  return newsz;
    80001466:	8552                	mv	a0,s4
    80001468:	a809                	j	8000147a <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000146a:	864e                	mv	a2,s3
    8000146c:	85ca                	mv	a1,s2
    8000146e:	8556                	mv	a0,s5
    80001470:	00000097          	auipc	ra,0x0
    80001474:	f4e080e7          	jalr	-178(ra) # 800013be <uvmdealloc>
      return 0;
    80001478:	4501                	li	a0,0
}
    8000147a:	70e2                	ld	ra,56(sp)
    8000147c:	7442                	ld	s0,48(sp)
    8000147e:	74a2                	ld	s1,40(sp)
    80001480:	7902                	ld	s2,32(sp)
    80001482:	69e2                	ld	s3,24(sp)
    80001484:	6a42                	ld	s4,16(sp)
    80001486:	6aa2                	ld	s5,8(sp)
    80001488:	6121                	addi	sp,sp,64
    8000148a:	8082                	ret
      kfree(mem);
    8000148c:	8526                	mv	a0,s1
    8000148e:	fffff097          	auipc	ra,0xfffff
    80001492:	556080e7          	jalr	1366(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001496:	864e                	mv	a2,s3
    80001498:	85ca                	mv	a1,s2
    8000149a:	8556                	mv	a0,s5
    8000149c:	00000097          	auipc	ra,0x0
    800014a0:	f22080e7          	jalr	-222(ra) # 800013be <uvmdealloc>
      return 0;
    800014a4:	4501                	li	a0,0
    800014a6:	bfd1                	j	8000147a <uvmalloc+0x74>
    return oldsz;
    800014a8:	852e                	mv	a0,a1
}
    800014aa:	8082                	ret
  return newsz;
    800014ac:	8532                	mv	a0,a2
    800014ae:	b7f1                	j	8000147a <uvmalloc+0x74>

00000000800014b0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014b0:	7179                	addi	sp,sp,-48
    800014b2:	f406                	sd	ra,40(sp)
    800014b4:	f022                	sd	s0,32(sp)
    800014b6:	ec26                	sd	s1,24(sp)
    800014b8:	e84a                	sd	s2,16(sp)
    800014ba:	e44e                	sd	s3,8(sp)
    800014bc:	e052                	sd	s4,0(sp)
    800014be:	1800                	addi	s0,sp,48
    800014c0:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014c2:	84aa                	mv	s1,a0
    800014c4:	6905                	lui	s2,0x1
    800014c6:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014c8:	4985                	li	s3,1
    800014ca:	a821                	j	800014e2 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014cc:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014ce:	0532                	slli	a0,a0,0xc
    800014d0:	00000097          	auipc	ra,0x0
    800014d4:	fe0080e7          	jalr	-32(ra) # 800014b0 <freewalk>
      pagetable[i] = 0;
    800014d8:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014dc:	04a1                	addi	s1,s1,8
    800014de:	03248163          	beq	s1,s2,80001500 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014e2:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e4:	00f57793          	andi	a5,a0,15
    800014e8:	ff3782e3          	beq	a5,s3,800014cc <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014ec:	8905                	andi	a0,a0,1
    800014ee:	d57d                	beqz	a0,800014dc <freewalk+0x2c>
      panic("freewalk: leaf");
    800014f0:	00007517          	auipc	a0,0x7
    800014f4:	c8850513          	addi	a0,a0,-888 # 80008178 <digits+0x138>
    800014f8:	fffff097          	auipc	ra,0xfffff
    800014fc:	040080e7          	jalr	64(ra) # 80000538 <panic>
    }
  }
  kfree((void*)pagetable);
    80001500:	8552                	mv	a0,s4
    80001502:	fffff097          	auipc	ra,0xfffff
    80001506:	4e2080e7          	jalr	1250(ra) # 800009e4 <kfree>
}
    8000150a:	70a2                	ld	ra,40(sp)
    8000150c:	7402                	ld	s0,32(sp)
    8000150e:	64e2                	ld	s1,24(sp)
    80001510:	6942                	ld	s2,16(sp)
    80001512:	69a2                	ld	s3,8(sp)
    80001514:	6a02                	ld	s4,0(sp)
    80001516:	6145                	addi	sp,sp,48
    80001518:	8082                	ret

000000008000151a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000151a:	1101                	addi	sp,sp,-32
    8000151c:	ec06                	sd	ra,24(sp)
    8000151e:	e822                	sd	s0,16(sp)
    80001520:	e426                	sd	s1,8(sp)
    80001522:	1000                	addi	s0,sp,32
    80001524:	84aa                	mv	s1,a0
  if(sz > 0)
    80001526:	e999                	bnez	a1,8000153c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001528:	8526                	mv	a0,s1
    8000152a:	00000097          	auipc	ra,0x0
    8000152e:	f86080e7          	jalr	-122(ra) # 800014b0 <freewalk>
}
    80001532:	60e2                	ld	ra,24(sp)
    80001534:	6442                	ld	s0,16(sp)
    80001536:	64a2                	ld	s1,8(sp)
    80001538:	6105                	addi	sp,sp,32
    8000153a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000153c:	6605                	lui	a2,0x1
    8000153e:	167d                	addi	a2,a2,-1
    80001540:	962e                	add	a2,a2,a1
    80001542:	4685                	li	a3,1
    80001544:	8231                	srli	a2,a2,0xc
    80001546:	4581                	li	a1,0
    80001548:	00000097          	auipc	ra,0x0
    8000154c:	d12080e7          	jalr	-750(ra) # 8000125a <uvmunmap>
    80001550:	bfe1                	j	80001528 <uvmfree+0xe>

0000000080001552 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001552:	c679                	beqz	a2,80001620 <uvmcopy+0xce>
{
    80001554:	715d                	addi	sp,sp,-80
    80001556:	e486                	sd	ra,72(sp)
    80001558:	e0a2                	sd	s0,64(sp)
    8000155a:	fc26                	sd	s1,56(sp)
    8000155c:	f84a                	sd	s2,48(sp)
    8000155e:	f44e                	sd	s3,40(sp)
    80001560:	f052                	sd	s4,32(sp)
    80001562:	ec56                	sd	s5,24(sp)
    80001564:	e85a                	sd	s6,16(sp)
    80001566:	e45e                	sd	s7,8(sp)
    80001568:	0880                	addi	s0,sp,80
    8000156a:	8b2a                	mv	s6,a0
    8000156c:	8aae                	mv	s5,a1
    8000156e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001570:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001572:	4601                	li	a2,0
    80001574:	85ce                	mv	a1,s3
    80001576:	855a                	mv	a0,s6
    80001578:	00000097          	auipc	ra,0x0
    8000157c:	a34080e7          	jalr	-1484(ra) # 80000fac <walk>
    80001580:	c531                	beqz	a0,800015cc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001582:	6118                	ld	a4,0(a0)
    80001584:	00177793          	andi	a5,a4,1
    80001588:	cbb1                	beqz	a5,800015dc <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000158a:	00a75593          	srli	a1,a4,0xa
    8000158e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001592:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001596:	fffff097          	auipc	ra,0xfffff
    8000159a:	54a080e7          	jalr	1354(ra) # 80000ae0 <kalloc>
    8000159e:	892a                	mv	s2,a0
    800015a0:	c939                	beqz	a0,800015f6 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015a2:	6605                	lui	a2,0x1
    800015a4:	85de                	mv	a1,s7
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	782080e7          	jalr	1922(ra) # 80000d28 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015ae:	8726                	mv	a4,s1
    800015b0:	86ca                	mv	a3,s2
    800015b2:	6605                	lui	a2,0x1
    800015b4:	85ce                	mv	a1,s3
    800015b6:	8556                	mv	a0,s5
    800015b8:	00000097          	auipc	ra,0x0
    800015bc:	adc080e7          	jalr	-1316(ra) # 80001094 <mappages>
    800015c0:	e515                	bnez	a0,800015ec <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015c2:	6785                	lui	a5,0x1
    800015c4:	99be                	add	s3,s3,a5
    800015c6:	fb49e6e3          	bltu	s3,s4,80001572 <uvmcopy+0x20>
    800015ca:	a081                	j	8000160a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015cc:	00007517          	auipc	a0,0x7
    800015d0:	bbc50513          	addi	a0,a0,-1092 # 80008188 <digits+0x148>
    800015d4:	fffff097          	auipc	ra,0xfffff
    800015d8:	f64080e7          	jalr	-156(ra) # 80000538 <panic>
      panic("uvmcopy: page not present");
    800015dc:	00007517          	auipc	a0,0x7
    800015e0:	bcc50513          	addi	a0,a0,-1076 # 800081a8 <digits+0x168>
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	f54080e7          	jalr	-172(ra) # 80000538 <panic>
      kfree(mem);
    800015ec:	854a                	mv	a0,s2
    800015ee:	fffff097          	auipc	ra,0xfffff
    800015f2:	3f6080e7          	jalr	1014(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015f6:	4685                	li	a3,1
    800015f8:	00c9d613          	srli	a2,s3,0xc
    800015fc:	4581                	li	a1,0
    800015fe:	8556                	mv	a0,s5
    80001600:	00000097          	auipc	ra,0x0
    80001604:	c5a080e7          	jalr	-934(ra) # 8000125a <uvmunmap>
  return -1;
    80001608:	557d                	li	a0,-1
}
    8000160a:	60a6                	ld	ra,72(sp)
    8000160c:	6406                	ld	s0,64(sp)
    8000160e:	74e2                	ld	s1,56(sp)
    80001610:	7942                	ld	s2,48(sp)
    80001612:	79a2                	ld	s3,40(sp)
    80001614:	7a02                	ld	s4,32(sp)
    80001616:	6ae2                	ld	s5,24(sp)
    80001618:	6b42                	ld	s6,16(sp)
    8000161a:	6ba2                	ld	s7,8(sp)
    8000161c:	6161                	addi	sp,sp,80
    8000161e:	8082                	ret
  return 0;
    80001620:	4501                	li	a0,0
}
    80001622:	8082                	ret

0000000080001624 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001624:	1141                	addi	sp,sp,-16
    80001626:	e406                	sd	ra,8(sp)
    80001628:	e022                	sd	s0,0(sp)
    8000162a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000162c:	4601                	li	a2,0
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	97e080e7          	jalr	-1666(ra) # 80000fac <walk>
  if(pte == 0)
    80001636:	c901                	beqz	a0,80001646 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001638:	611c                	ld	a5,0(a0)
    8000163a:	9bbd                	andi	a5,a5,-17
    8000163c:	e11c                	sd	a5,0(a0)
}
    8000163e:	60a2                	ld	ra,8(sp)
    80001640:	6402                	ld	s0,0(sp)
    80001642:	0141                	addi	sp,sp,16
    80001644:	8082                	ret
    panic("uvmclear");
    80001646:	00007517          	auipc	a0,0x7
    8000164a:	b8250513          	addi	a0,a0,-1150 # 800081c8 <digits+0x188>
    8000164e:	fffff097          	auipc	ra,0xfffff
    80001652:	eea080e7          	jalr	-278(ra) # 80000538 <panic>

0000000080001656 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001656:	c6bd                	beqz	a3,800016c4 <copyout+0x6e>
{
    80001658:	715d                	addi	sp,sp,-80
    8000165a:	e486                	sd	ra,72(sp)
    8000165c:	e0a2                	sd	s0,64(sp)
    8000165e:	fc26                	sd	s1,56(sp)
    80001660:	f84a                	sd	s2,48(sp)
    80001662:	f44e                	sd	s3,40(sp)
    80001664:	f052                	sd	s4,32(sp)
    80001666:	ec56                	sd	s5,24(sp)
    80001668:	e85a                	sd	s6,16(sp)
    8000166a:	e45e                	sd	s7,8(sp)
    8000166c:	e062                	sd	s8,0(sp)
    8000166e:	0880                	addi	s0,sp,80
    80001670:	8b2a                	mv	s6,a0
    80001672:	8c2e                	mv	s8,a1
    80001674:	8a32                	mv	s4,a2
    80001676:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001678:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000167a:	6a85                	lui	s5,0x1
    8000167c:	a015                	j	800016a0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000167e:	9562                	add	a0,a0,s8
    80001680:	0004861b          	sext.w	a2,s1
    80001684:	85d2                	mv	a1,s4
    80001686:	41250533          	sub	a0,a0,s2
    8000168a:	fffff097          	auipc	ra,0xfffff
    8000168e:	69e080e7          	jalr	1694(ra) # 80000d28 <memmove>

    len -= n;
    80001692:	409989b3          	sub	s3,s3,s1
    src += n;
    80001696:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001698:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000169c:	02098263          	beqz	s3,800016c0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016a0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016a4:	85ca                	mv	a1,s2
    800016a6:	855a                	mv	a0,s6
    800016a8:	00000097          	auipc	ra,0x0
    800016ac:	9aa080e7          	jalr	-1622(ra) # 80001052 <walkaddr>
    if(pa0 == 0)
    800016b0:	cd01                	beqz	a0,800016c8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016b2:	418904b3          	sub	s1,s2,s8
    800016b6:	94d6                	add	s1,s1,s5
    if(n > len)
    800016b8:	fc99f3e3          	bgeu	s3,s1,8000167e <copyout+0x28>
    800016bc:	84ce                	mv	s1,s3
    800016be:	b7c1                	j	8000167e <copyout+0x28>
  }
  return 0;
    800016c0:	4501                	li	a0,0
    800016c2:	a021                	j	800016ca <copyout+0x74>
    800016c4:	4501                	li	a0,0
}
    800016c6:	8082                	ret
      return -1;
    800016c8:	557d                	li	a0,-1
}
    800016ca:	60a6                	ld	ra,72(sp)
    800016cc:	6406                	ld	s0,64(sp)
    800016ce:	74e2                	ld	s1,56(sp)
    800016d0:	7942                	ld	s2,48(sp)
    800016d2:	79a2                	ld	s3,40(sp)
    800016d4:	7a02                	ld	s4,32(sp)
    800016d6:	6ae2                	ld	s5,24(sp)
    800016d8:	6b42                	ld	s6,16(sp)
    800016da:	6ba2                	ld	s7,8(sp)
    800016dc:	6c02                	ld	s8,0(sp)
    800016de:	6161                	addi	sp,sp,80
    800016e0:	8082                	ret

00000000800016e2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e2:	caa5                	beqz	a3,80001752 <copyin+0x70>
{
    800016e4:	715d                	addi	sp,sp,-80
    800016e6:	e486                	sd	ra,72(sp)
    800016e8:	e0a2                	sd	s0,64(sp)
    800016ea:	fc26                	sd	s1,56(sp)
    800016ec:	f84a                	sd	s2,48(sp)
    800016ee:	f44e                	sd	s3,40(sp)
    800016f0:	f052                	sd	s4,32(sp)
    800016f2:	ec56                	sd	s5,24(sp)
    800016f4:	e85a                	sd	s6,16(sp)
    800016f6:	e45e                	sd	s7,8(sp)
    800016f8:	e062                	sd	s8,0(sp)
    800016fa:	0880                	addi	s0,sp,80
    800016fc:	8b2a                	mv	s6,a0
    800016fe:	8a2e                	mv	s4,a1
    80001700:	8c32                	mv	s8,a2
    80001702:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001704:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001706:	6a85                	lui	s5,0x1
    80001708:	a01d                	j	8000172e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000170a:	018505b3          	add	a1,a0,s8
    8000170e:	0004861b          	sext.w	a2,s1
    80001712:	412585b3          	sub	a1,a1,s2
    80001716:	8552                	mv	a0,s4
    80001718:	fffff097          	auipc	ra,0xfffff
    8000171c:	610080e7          	jalr	1552(ra) # 80000d28 <memmove>

    len -= n;
    80001720:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001724:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001726:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000172a:	02098263          	beqz	s3,8000174e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000172e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001732:	85ca                	mv	a1,s2
    80001734:	855a                	mv	a0,s6
    80001736:	00000097          	auipc	ra,0x0
    8000173a:	91c080e7          	jalr	-1764(ra) # 80001052 <walkaddr>
    if(pa0 == 0)
    8000173e:	cd01                	beqz	a0,80001756 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001740:	418904b3          	sub	s1,s2,s8
    80001744:	94d6                	add	s1,s1,s5
    if(n > len)
    80001746:	fc99f2e3          	bgeu	s3,s1,8000170a <copyin+0x28>
    8000174a:	84ce                	mv	s1,s3
    8000174c:	bf7d                	j	8000170a <copyin+0x28>
  }
  return 0;
    8000174e:	4501                	li	a0,0
    80001750:	a021                	j	80001758 <copyin+0x76>
    80001752:	4501                	li	a0,0
}
    80001754:	8082                	ret
      return -1;
    80001756:	557d                	li	a0,-1
}
    80001758:	60a6                	ld	ra,72(sp)
    8000175a:	6406                	ld	s0,64(sp)
    8000175c:	74e2                	ld	s1,56(sp)
    8000175e:	7942                	ld	s2,48(sp)
    80001760:	79a2                	ld	s3,40(sp)
    80001762:	7a02                	ld	s4,32(sp)
    80001764:	6ae2                	ld	s5,24(sp)
    80001766:	6b42                	ld	s6,16(sp)
    80001768:	6ba2                	ld	s7,8(sp)
    8000176a:	6c02                	ld	s8,0(sp)
    8000176c:	6161                	addi	sp,sp,80
    8000176e:	8082                	ret

0000000080001770 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001770:	c6c5                	beqz	a3,80001818 <copyinstr+0xa8>
{
    80001772:	715d                	addi	sp,sp,-80
    80001774:	e486                	sd	ra,72(sp)
    80001776:	e0a2                	sd	s0,64(sp)
    80001778:	fc26                	sd	s1,56(sp)
    8000177a:	f84a                	sd	s2,48(sp)
    8000177c:	f44e                	sd	s3,40(sp)
    8000177e:	f052                	sd	s4,32(sp)
    80001780:	ec56                	sd	s5,24(sp)
    80001782:	e85a                	sd	s6,16(sp)
    80001784:	e45e                	sd	s7,8(sp)
    80001786:	0880                	addi	s0,sp,80
    80001788:	8a2a                	mv	s4,a0
    8000178a:	8b2e                	mv	s6,a1
    8000178c:	8bb2                	mv	s7,a2
    8000178e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001790:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001792:	6985                	lui	s3,0x1
    80001794:	a035                	j	800017c0 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001796:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000179a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000179c:	0017b793          	seqz	a5,a5
    800017a0:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017a4:	60a6                	ld	ra,72(sp)
    800017a6:	6406                	ld	s0,64(sp)
    800017a8:	74e2                	ld	s1,56(sp)
    800017aa:	7942                	ld	s2,48(sp)
    800017ac:	79a2                	ld	s3,40(sp)
    800017ae:	7a02                	ld	s4,32(sp)
    800017b0:	6ae2                	ld	s5,24(sp)
    800017b2:	6b42                	ld	s6,16(sp)
    800017b4:	6ba2                	ld	s7,8(sp)
    800017b6:	6161                	addi	sp,sp,80
    800017b8:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ba:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017be:	c8a9                	beqz	s1,80001810 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017c0:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017c4:	85ca                	mv	a1,s2
    800017c6:	8552                	mv	a0,s4
    800017c8:	00000097          	auipc	ra,0x0
    800017cc:	88a080e7          	jalr	-1910(ra) # 80001052 <walkaddr>
    if(pa0 == 0)
    800017d0:	c131                	beqz	a0,80001814 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017d2:	41790833          	sub	a6,s2,s7
    800017d6:	984e                	add	a6,a6,s3
    if(n > max)
    800017d8:	0104f363          	bgeu	s1,a6,800017de <copyinstr+0x6e>
    800017dc:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017de:	955e                	add	a0,a0,s7
    800017e0:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017e4:	fc080be3          	beqz	a6,800017ba <copyinstr+0x4a>
    800017e8:	985a                	add	a6,a6,s6
    800017ea:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017ec:	41650633          	sub	a2,a0,s6
    800017f0:	14fd                	addi	s1,s1,-1
    800017f2:	9b26                	add	s6,s6,s1
    800017f4:	00f60733          	add	a4,a2,a5
    800017f8:	00074703          	lbu	a4,0(a4)
    800017fc:	df49                	beqz	a4,80001796 <copyinstr+0x26>
        *dst = *p;
    800017fe:	00e78023          	sb	a4,0(a5)
      --max;
    80001802:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001806:	0785                	addi	a5,a5,1
    while(n > 0){
    80001808:	ff0796e3          	bne	a5,a6,800017f4 <copyinstr+0x84>
      dst++;
    8000180c:	8b42                	mv	s6,a6
    8000180e:	b775                	j	800017ba <copyinstr+0x4a>
    80001810:	4781                	li	a5,0
    80001812:	b769                	j	8000179c <copyinstr+0x2c>
      return -1;
    80001814:	557d                	li	a0,-1
    80001816:	b779                	j	800017a4 <copyinstr+0x34>
  int got_null = 0;
    80001818:	4781                	li	a5,0
  if(got_null){
    8000181a:	0017b793          	seqz	a5,a5
    8000181e:	40f00533          	neg	a0,a5
}
    80001822:	8082                	ret

0000000080001824 <make_runnable>:
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

// added: make a process runnable (sets state and adds to run queue)
void make_runnable(struct proc *process) {
    80001824:	1141                	addi	sp,sp,-16
    80001826:	e406                	sd	ra,8(sp)
    80001828:	e022                	sd	s0,0(sp)
    8000182a:	0800                	addi	s0,sp,16
  process->state = RUNNABLE;
    8000182c:	478d                	li	a5,3
    8000182e:	cd1c                	sw	a5,24(a0)
  add_to_queue(process);
    80001830:	00010797          	auipc	a5,0x10
    80001834:	46078793          	addi	a5,a5,1120 # 80011c90 <proc>
    80001838:	40f507b3          	sub	a5,a0,a5
    8000183c:	879d                	srai	a5,a5,0x7
    8000183e:	4685                	li	a3,1
    80001840:	00006617          	auipc	a2,0x6
    80001844:	7c063603          	ld	a2,1984(a2) # 80008000 <etext>
    80001848:	02c78633          	mul	a2,a5,a2
    8000184c:	17452583          	lw	a1,372(a0)
    80001850:	0000f517          	auipc	a0,0xf
    80001854:	34050513          	addi	a0,a0,832 # 80010b90 <qtable>
    80001858:	00005097          	auipc	ra,0x5
    8000185c:	cc4080e7          	jalr	-828(ra) # 8000651c <enqueue_back>
}
    80001860:	60a2                	ld	ra,8(sp)
    80001862:	6402                	ld	s0,0(sp)
    80001864:	0141                	addi	sp,sp,16
    80001866:	8082                	ret

0000000080001868 <sys_startlog>:


// Starts the log as long as the log count is not full.
uint64
sys_startlog(void)
{
    80001868:	1141                	addi	sp,sp,-16
    8000186a:	e422                	sd	s0,8(sp)
    8000186c:	0800                	addi	s0,sp,16
  // modified: allow restart logging
  log_count = 0;
    8000186e:	00007797          	auipc	a5,0x7
    80001872:	0007ab23          	sw	zero,22(a5) # 80008884 <log_count>
  return 0;
}
    80001876:	4501                	li	a0,0
    80001878:	6422                	ld	s0,8(sp)
    8000187a:	0141                	addi	sp,sp,16
    8000187c:	8082                	ret

000000008000187e <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000187e:	7139                	addi	sp,sp,-64
    80001880:	fc06                	sd	ra,56(sp)
    80001882:	f822                	sd	s0,48(sp)
    80001884:	f426                	sd	s1,40(sp)
    80001886:	f04a                	sd	s2,32(sp)
    80001888:	ec4e                	sd	s3,24(sp)
    8000188a:	e852                	sd	s4,16(sp)
    8000188c:	e456                	sd	s5,8(sp)
    8000188e:	e05a                	sd	s6,0(sp)
    80001890:	0080                	addi	s0,sp,64
    80001892:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001894:	00010497          	auipc	s1,0x10
    80001898:	3fc48493          	addi	s1,s1,1020 # 80011c90 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000189c:	8b26                	mv	s6,s1
    8000189e:	00006a97          	auipc	s5,0x6
    800018a2:	762a8a93          	addi	s5,s5,1890 # 80008000 <etext>
    800018a6:	04000937          	lui	s2,0x4000
    800018aa:	197d                	addi	s2,s2,-1
    800018ac:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ae:	00016a17          	auipc	s4,0x16
    800018b2:	3e2a0a13          	addi	s4,s4,994 # 80017c90 <tickslock>
    char *pa = kalloc();
    800018b6:	fffff097          	auipc	ra,0xfffff
    800018ba:	22a080e7          	jalr	554(ra) # 80000ae0 <kalloc>
    800018be:	862a                	mv	a2,a0
    if(pa == 0)
    800018c0:	c131                	beqz	a0,80001904 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    800018c2:	416485b3          	sub	a1,s1,s6
    800018c6:	859d                	srai	a1,a1,0x7
    800018c8:	000ab783          	ld	a5,0(s5)
    800018cc:	02f585b3          	mul	a1,a1,a5
    800018d0:	2585                	addiw	a1,a1,1
    800018d2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018d6:	4719                	li	a4,6
    800018d8:	6685                	lui	a3,0x1
    800018da:	40b905b3          	sub	a1,s2,a1
    800018de:	854e                	mv	a0,s3
    800018e0:	00000097          	auipc	ra,0x0
    800018e4:	854080e7          	jalr	-1964(ra) # 80001134 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e8:	18048493          	addi	s1,s1,384
    800018ec:	fd4495e3          	bne	s1,s4,800018b6 <proc_mapstacks+0x38>
  }
}
    800018f0:	70e2                	ld	ra,56(sp)
    800018f2:	7442                	ld	s0,48(sp)
    800018f4:	74a2                	ld	s1,40(sp)
    800018f6:	7902                	ld	s2,32(sp)
    800018f8:	69e2                	ld	s3,24(sp)
    800018fa:	6a42                	ld	s4,16(sp)
    800018fc:	6aa2                	ld	s5,8(sp)
    800018fe:	6b02                	ld	s6,0(sp)
    80001900:	6121                	addi	sp,sp,64
    80001902:	8082                	ret
      panic("kalloc");
    80001904:	00007517          	auipc	a0,0x7
    80001908:	8d450513          	addi	a0,a0,-1836 # 800081d8 <digits+0x198>
    8000190c:	fffff097          	auipc	ra,0xfffff
    80001910:	c2c080e7          	jalr	-980(ra) # 80000538 <panic>

0000000080001914 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001914:	7139                	addi	sp,sp,-64
    80001916:	fc06                	sd	ra,56(sp)
    80001918:	f822                	sd	s0,48(sp)
    8000191a:	f426                	sd	s1,40(sp)
    8000191c:	f04a                	sd	s2,32(sp)
    8000191e:	ec4e                	sd	s3,24(sp)
    80001920:	e852                	sd	s4,16(sp)
    80001922:	e456                	sd	s5,8(sp)
    80001924:	e05a                	sd	s6,0(sp)
    80001926:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001928:	00007597          	auipc	a1,0x7
    8000192c:	8b858593          	addi	a1,a1,-1864 # 800081e0 <digits+0x1a0>
    80001930:	00010517          	auipc	a0,0x10
    80001934:	8f050513          	addi	a0,a0,-1808 # 80011220 <pid_lock>
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	208080e7          	jalr	520(ra) # 80000b40 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001940:	00007597          	auipc	a1,0x7
    80001944:	8a858593          	addi	a1,a1,-1880 # 800081e8 <digits+0x1a8>
    80001948:	00010517          	auipc	a0,0x10
    8000194c:	8f050513          	addi	a0,a0,-1808 # 80011238 <wait_lock>
    80001950:	fffff097          	auipc	ra,0xfffff
    80001954:	1f0080e7          	jalr	496(ra) # 80000b40 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001958:	00010497          	auipc	s1,0x10
    8000195c:	33848493          	addi	s1,s1,824 # 80011c90 <proc>
      initlock(&p->lock, "proc");
    80001960:	00007b17          	auipc	s6,0x7
    80001964:	898b0b13          	addi	s6,s6,-1896 # 800081f8 <digits+0x1b8>
      p->kstack = KSTACK((int) (p - proc));
    80001968:	8aa6                	mv	s5,s1
    8000196a:	00006a17          	auipc	s4,0x6
    8000196e:	696a0a13          	addi	s4,s4,1686 # 80008000 <etext>
    80001972:	04000937          	lui	s2,0x4000
    80001976:	197d                	addi	s2,s2,-1
    80001978:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000197a:	00016997          	auipc	s3,0x16
    8000197e:	31698993          	addi	s3,s3,790 # 80017c90 <tickslock>
      initlock(&p->lock, "proc");
    80001982:	85da                	mv	a1,s6
    80001984:	8526                	mv	a0,s1
    80001986:	fffff097          	auipc	ra,0xfffff
    8000198a:	1ba080e7          	jalr	442(ra) # 80000b40 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    8000198e:	415487b3          	sub	a5,s1,s5
    80001992:	879d                	srai	a5,a5,0x7
    80001994:	000a3703          	ld	a4,0(s4)
    80001998:	02e787b3          	mul	a5,a5,a4
    8000199c:	2785                	addiw	a5,a5,1
    8000199e:	00d7979b          	slliw	a5,a5,0xd
    800019a2:	40f907b3          	sub	a5,s2,a5
    800019a6:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019a8:	18048493          	addi	s1,s1,384
    800019ac:	fd349be3          	bne	s1,s3,80001982 <procinit+0x6e>
  }

  // added: setup qtable
  initialize(qtable, NUM_QUEUES);
    800019b0:	458d                	li	a1,3
    800019b2:	0000f517          	auipc	a0,0xf
    800019b6:	1de50513          	addi	a0,a0,478 # 80010b90 <qtable>
    800019ba:	00005097          	auipc	ra,0x5
    800019be:	c46080e7          	jalr	-954(ra) # 80006600 <initialize>
}
    800019c2:	70e2                	ld	ra,56(sp)
    800019c4:	7442                	ld	s0,48(sp)
    800019c6:	74a2                	ld	s1,40(sp)
    800019c8:	7902                	ld	s2,32(sp)
    800019ca:	69e2                	ld	s3,24(sp)
    800019cc:	6a42                	ld	s4,16(sp)
    800019ce:	6aa2                	ld	s5,8(sp)
    800019d0:	6b02                	ld	s6,0(sp)
    800019d2:	6121                	addi	sp,sp,64
    800019d4:	8082                	ret

00000000800019d6 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019d6:	1141                	addi	sp,sp,-16
    800019d8:	e422                	sd	s0,8(sp)
    800019da:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019dc:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019de:	2501                	sext.w	a0,a0
    800019e0:	6422                	ld	s0,8(sp)
    800019e2:	0141                	addi	sp,sp,16
    800019e4:	8082                	ret

00000000800019e6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019e6:	1141                	addi	sp,sp,-16
    800019e8:	e422                	sd	s0,8(sp)
    800019ea:	0800                	addi	s0,sp,16
    800019ec:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019ee:	2781                	sext.w	a5,a5
    800019f0:	079e                	slli	a5,a5,0x7
  return c;
}
    800019f2:	00010517          	auipc	a0,0x10
    800019f6:	85e50513          	addi	a0,a0,-1954 # 80011250 <cpus>
    800019fa:	953e                	add	a0,a0,a5
    800019fc:	6422                	ld	s0,8(sp)
    800019fe:	0141                	addi	sp,sp,16
    80001a00:	8082                	ret

0000000080001a02 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001a02:	1101                	addi	sp,sp,-32
    80001a04:	ec06                	sd	ra,24(sp)
    80001a06:	e822                	sd	s0,16(sp)
    80001a08:	e426                	sd	s1,8(sp)
    80001a0a:	1000                	addi	s0,sp,32
  push_off();
    80001a0c:	fffff097          	auipc	ra,0xfffff
    80001a10:	178080e7          	jalr	376(ra) # 80000b84 <push_off>
    80001a14:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a16:	2781                	sext.w	a5,a5
    80001a18:	079e                	slli	a5,a5,0x7
    80001a1a:	0000f717          	auipc	a4,0xf
    80001a1e:	17670713          	addi	a4,a4,374 # 80010b90 <qtable>
    80001a22:	97ba                	add	a5,a5,a4
    80001a24:	6c07b483          	ld	s1,1728(a5)
  pop_off();
    80001a28:	fffff097          	auipc	ra,0xfffff
    80001a2c:	1fc080e7          	jalr	508(ra) # 80000c24 <pop_off>
  return p;
}
    80001a30:	8526                	mv	a0,s1
    80001a32:	60e2                	ld	ra,24(sp)
    80001a34:	6442                	ld	s0,16(sp)
    80001a36:	64a2                	ld	s1,8(sp)
    80001a38:	6105                	addi	sp,sp,32
    80001a3a:	8082                	ret

0000000080001a3c <sys_getlog>:
{
    80001a3c:	1101                	addi	sp,sp,-32
    80001a3e:	ec06                	sd	ra,24(sp)
    80001a40:	e822                	sd	s0,16(sp)
    80001a42:	1000                	addi	s0,sp,32
  if (argaddr(0, &userlog) < 0)
    80001a44:	fe840593          	addi	a1,s0,-24
    80001a48:	4501                	li	a0,0
    80001a4a:	00001097          	auipc	ra,0x1
    80001a4e:	3bc080e7          	jalr	956(ra) # 80002e06 <argaddr>
    return -1;
    80001a52:	57fd                	li	a5,-1
  if (argaddr(0, &userlog) < 0)
    80001a54:	02054963          	bltz	a0,80001a86 <sys_getlog+0x4a>
  struct proc *p = myproc();
    80001a58:	00000097          	auipc	ra,0x0
    80001a5c:	faa080e7          	jalr	-86(ra) # 80001a02 <myproc>
  if (copyout(p->pagetable, userlog, (char *)schedlog,
    80001a60:	64000693          	li	a3,1600
    80001a64:	00010617          	auipc	a2,0x10
    80001a68:	bec60613          	addi	a2,a2,-1044 # 80011650 <schedlog>
    80001a6c:	fe843583          	ld	a1,-24(s0)
    80001a70:	6928                	ld	a0,80(a0)
    80001a72:	00000097          	auipc	ra,0x0
    80001a76:	be4080e7          	jalr	-1052(ra) # 80001656 <copyout>
    80001a7a:	00054b63          	bltz	a0,80001a90 <sys_getlog+0x54>
  return log_count;
    80001a7e:	00007797          	auipc	a5,0x7
    80001a82:	e067a783          	lw	a5,-506(a5) # 80008884 <log_count>
}
    80001a86:	853e                	mv	a0,a5
    80001a88:	60e2                	ld	ra,24(sp)
    80001a8a:	6442                	ld	s0,16(sp)
    80001a8c:	6105                	addi	sp,sp,32
    80001a8e:	8082                	ret
    return -1;
    80001a90:	57fd                	li	a5,-1
    80001a92:	bfd5                	j	80001a86 <sys_getlog+0x4a>

0000000080001a94 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a94:	1141                	addi	sp,sp,-16
    80001a96:	e406                	sd	ra,8(sp)
    80001a98:	e022                	sd	s0,0(sp)
    80001a9a:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a9c:	00000097          	auipc	ra,0x0
    80001aa0:	f66080e7          	jalr	-154(ra) # 80001a02 <myproc>
    80001aa4:	fffff097          	auipc	ra,0xfffff
    80001aa8:	1e0080e7          	jalr	480(ra) # 80000c84 <release>

  if (first) {
    80001aac:	00007797          	auipc	a5,0x7
    80001ab0:	dd47a783          	lw	a5,-556(a5) # 80008880 <first.1>
    80001ab4:	eb89                	bnez	a5,80001ac6 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001ab6:	00001097          	auipc	ra,0x1
    80001aba:	ed2080e7          	jalr	-302(ra) # 80002988 <usertrapret>
}
    80001abe:	60a2                	ld	ra,8(sp)
    80001ac0:	6402                	ld	s0,0(sp)
    80001ac2:	0141                	addi	sp,sp,16
    80001ac4:	8082                	ret
    first = 0;
    80001ac6:	00007797          	auipc	a5,0x7
    80001aca:	da07ad23          	sw	zero,-582(a5) # 80008880 <first.1>
    fsinit(ROOTDEV);
    80001ace:	4505                	li	a0,1
    80001ad0:	00002097          	auipc	ra,0x2
    80001ad4:	c20080e7          	jalr	-992(ra) # 800036f0 <fsinit>
    80001ad8:	bff9                	j	80001ab6 <forkret+0x22>

0000000080001ada <allocpid>:
{
    80001ada:	1101                	addi	sp,sp,-32
    80001adc:	ec06                	sd	ra,24(sp)
    80001ade:	e822                	sd	s0,16(sp)
    80001ae0:	e426                	sd	s1,8(sp)
    80001ae2:	e04a                	sd	s2,0(sp)
    80001ae4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ae6:	0000f917          	auipc	s2,0xf
    80001aea:	73a90913          	addi	s2,s2,1850 # 80011220 <pid_lock>
    80001aee:	854a                	mv	a0,s2
    80001af0:	fffff097          	auipc	ra,0xfffff
    80001af4:	0e0080e7          	jalr	224(ra) # 80000bd0 <acquire>
  pid = nextpid;
    80001af8:	00007797          	auipc	a5,0x7
    80001afc:	d9478793          	addi	a5,a5,-620 # 8000888c <nextpid>
    80001b00:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b02:	0014871b          	addiw	a4,s1,1
    80001b06:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b08:	854a                	mv	a0,s2
    80001b0a:	fffff097          	auipc	ra,0xfffff
    80001b0e:	17a080e7          	jalr	378(ra) # 80000c84 <release>
}
    80001b12:	8526                	mv	a0,s1
    80001b14:	60e2                	ld	ra,24(sp)
    80001b16:	6442                	ld	s0,16(sp)
    80001b18:	64a2                	ld	s1,8(sp)
    80001b1a:	6902                	ld	s2,0(sp)
    80001b1c:	6105                	addi	sp,sp,32
    80001b1e:	8082                	ret

0000000080001b20 <proc_pagetable>:
{
    80001b20:	1101                	addi	sp,sp,-32
    80001b22:	ec06                	sd	ra,24(sp)
    80001b24:	e822                	sd	s0,16(sp)
    80001b26:	e426                	sd	s1,8(sp)
    80001b28:	e04a                	sd	s2,0(sp)
    80001b2a:	1000                	addi	s0,sp,32
    80001b2c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b2e:	fffff097          	auipc	ra,0xfffff
    80001b32:	7f0080e7          	jalr	2032(ra) # 8000131e <uvmcreate>
    80001b36:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b38:	c121                	beqz	a0,80001b78 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b3a:	4729                	li	a4,10
    80001b3c:	00005697          	auipc	a3,0x5
    80001b40:	4c468693          	addi	a3,a3,1220 # 80007000 <_trampoline>
    80001b44:	6605                	lui	a2,0x1
    80001b46:	040005b7          	lui	a1,0x4000
    80001b4a:	15fd                	addi	a1,a1,-1
    80001b4c:	05b2                	slli	a1,a1,0xc
    80001b4e:	fffff097          	auipc	ra,0xfffff
    80001b52:	546080e7          	jalr	1350(ra) # 80001094 <mappages>
    80001b56:	02054863          	bltz	a0,80001b86 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b5a:	4719                	li	a4,6
    80001b5c:	05893683          	ld	a3,88(s2)
    80001b60:	6605                	lui	a2,0x1
    80001b62:	020005b7          	lui	a1,0x2000
    80001b66:	15fd                	addi	a1,a1,-1
    80001b68:	05b6                	slli	a1,a1,0xd
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	fffff097          	auipc	ra,0xfffff
    80001b70:	528080e7          	jalr	1320(ra) # 80001094 <mappages>
    80001b74:	02054163          	bltz	a0,80001b96 <proc_pagetable+0x76>
}
    80001b78:	8526                	mv	a0,s1
    80001b7a:	60e2                	ld	ra,24(sp)
    80001b7c:	6442                	ld	s0,16(sp)
    80001b7e:	64a2                	ld	s1,8(sp)
    80001b80:	6902                	ld	s2,0(sp)
    80001b82:	6105                	addi	sp,sp,32
    80001b84:	8082                	ret
    uvmfree(pagetable, 0);
    80001b86:	4581                	li	a1,0
    80001b88:	8526                	mv	a0,s1
    80001b8a:	00000097          	auipc	ra,0x0
    80001b8e:	990080e7          	jalr	-1648(ra) # 8000151a <uvmfree>
    return 0;
    80001b92:	4481                	li	s1,0
    80001b94:	b7d5                	j	80001b78 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b96:	4681                	li	a3,0
    80001b98:	4605                	li	a2,1
    80001b9a:	040005b7          	lui	a1,0x4000
    80001b9e:	15fd                	addi	a1,a1,-1
    80001ba0:	05b2                	slli	a1,a1,0xc
    80001ba2:	8526                	mv	a0,s1
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	6b6080e7          	jalr	1718(ra) # 8000125a <uvmunmap>
    uvmfree(pagetable, 0);
    80001bac:	4581                	li	a1,0
    80001bae:	8526                	mv	a0,s1
    80001bb0:	00000097          	auipc	ra,0x0
    80001bb4:	96a080e7          	jalr	-1686(ra) # 8000151a <uvmfree>
    return 0;
    80001bb8:	4481                	li	s1,0
    80001bba:	bf7d                	j	80001b78 <proc_pagetable+0x58>

0000000080001bbc <proc_freepagetable>:
{
    80001bbc:	1101                	addi	sp,sp,-32
    80001bbe:	ec06                	sd	ra,24(sp)
    80001bc0:	e822                	sd	s0,16(sp)
    80001bc2:	e426                	sd	s1,8(sp)
    80001bc4:	e04a                	sd	s2,0(sp)
    80001bc6:	1000                	addi	s0,sp,32
    80001bc8:	84aa                	mv	s1,a0
    80001bca:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bcc:	4681                	li	a3,0
    80001bce:	4605                	li	a2,1
    80001bd0:	040005b7          	lui	a1,0x4000
    80001bd4:	15fd                	addi	a1,a1,-1
    80001bd6:	05b2                	slli	a1,a1,0xc
    80001bd8:	fffff097          	auipc	ra,0xfffff
    80001bdc:	682080e7          	jalr	1666(ra) # 8000125a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001be0:	4681                	li	a3,0
    80001be2:	4605                	li	a2,1
    80001be4:	020005b7          	lui	a1,0x2000
    80001be8:	15fd                	addi	a1,a1,-1
    80001bea:	05b6                	slli	a1,a1,0xd
    80001bec:	8526                	mv	a0,s1
    80001bee:	fffff097          	auipc	ra,0xfffff
    80001bf2:	66c080e7          	jalr	1644(ra) # 8000125a <uvmunmap>
  uvmfree(pagetable, sz);
    80001bf6:	85ca                	mv	a1,s2
    80001bf8:	8526                	mv	a0,s1
    80001bfa:	00000097          	auipc	ra,0x0
    80001bfe:	920080e7          	jalr	-1760(ra) # 8000151a <uvmfree>
}
    80001c02:	60e2                	ld	ra,24(sp)
    80001c04:	6442                	ld	s0,16(sp)
    80001c06:	64a2                	ld	s1,8(sp)
    80001c08:	6902                	ld	s2,0(sp)
    80001c0a:	6105                	addi	sp,sp,32
    80001c0c:	8082                	ret

0000000080001c0e <freeproc>:
{
    80001c0e:	1101                	addi	sp,sp,-32
    80001c10:	ec06                	sd	ra,24(sp)
    80001c12:	e822                	sd	s0,16(sp)
    80001c14:	e426                	sd	s1,8(sp)
    80001c16:	1000                	addi	s0,sp,32
    80001c18:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c1a:	6d28                	ld	a0,88(a0)
    80001c1c:	c509                	beqz	a0,80001c26 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c1e:	fffff097          	auipc	ra,0xfffff
    80001c22:	dc6080e7          	jalr	-570(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001c26:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c2a:	68a8                	ld	a0,80(s1)
    80001c2c:	c511                	beqz	a0,80001c38 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c2e:	64ac                	ld	a1,72(s1)
    80001c30:	00000097          	auipc	ra,0x0
    80001c34:	f8c080e7          	jalr	-116(ra) # 80001bbc <proc_freepagetable>
  p->pagetable = 0;
    80001c38:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c3c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c40:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c44:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c48:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c4c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c50:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c54:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c58:	0004ac23          	sw	zero,24(s1)
  p->nice = 0;
    80001c5c:	1604a423          	sw	zero,360(s1)
  p->runtime = 0;
    80001c60:	1604a823          	sw	zero,368(s1)
  p->queue = 0;
    80001c64:	1604aa23          	sw	zero,372(s1)
  p->pass = DEFAULT_PASS;
    80001c68:	4785                	li	a5,1
    80001c6a:	16f4bc23          	sd	a5,376(s1)
}
    80001c6e:	60e2                	ld	ra,24(sp)
    80001c70:	6442                	ld	s0,16(sp)
    80001c72:	64a2                	ld	s1,8(sp)
    80001c74:	6105                	addi	sp,sp,32
    80001c76:	8082                	ret

0000000080001c78 <allocproc>:
{
    80001c78:	1101                	addi	sp,sp,-32
    80001c7a:	ec06                	sd	ra,24(sp)
    80001c7c:	e822                	sd	s0,16(sp)
    80001c7e:	e426                	sd	s1,8(sp)
    80001c80:	e04a                	sd	s2,0(sp)
    80001c82:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c84:	00010497          	auipc	s1,0x10
    80001c88:	00c48493          	addi	s1,s1,12 # 80011c90 <proc>
    80001c8c:	00016917          	auipc	s2,0x16
    80001c90:	00490913          	addi	s2,s2,4 # 80017c90 <tickslock>
    acquire(&p->lock);
    80001c94:	8526                	mv	a0,s1
    80001c96:	fffff097          	auipc	ra,0xfffff
    80001c9a:	f3a080e7          	jalr	-198(ra) # 80000bd0 <acquire>
    if(p->state == UNUSED) {
    80001c9e:	4c9c                	lw	a5,24(s1)
    80001ca0:	cf81                	beqz	a5,80001cb8 <allocproc+0x40>
      release(&p->lock);
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	fe0080e7          	jalr	-32(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cac:	18048493          	addi	s1,s1,384
    80001cb0:	ff2492e3          	bne	s1,s2,80001c94 <allocproc+0x1c>
  return 0;
    80001cb4:	4481                	li	s1,0
    80001cb6:	a0bd                	j	80001d24 <allocproc+0xac>
  p->pid = allocpid();
    80001cb8:	00000097          	auipc	ra,0x0
    80001cbc:	e22080e7          	jalr	-478(ra) # 80001ada <allocpid>
    80001cc0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001cc2:	4785                	li	a5,1
    80001cc4:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cc6:	fffff097          	auipc	ra,0xfffff
    80001cca:	e1a080e7          	jalr	-486(ra) # 80000ae0 <kalloc>
    80001cce:	892a                	mv	s2,a0
    80001cd0:	eca8                	sd	a0,88(s1)
    80001cd2:	c125                	beqz	a0,80001d32 <allocproc+0xba>
  p->pagetable = proc_pagetable(p);
    80001cd4:	8526                	mv	a0,s1
    80001cd6:	00000097          	auipc	ra,0x0
    80001cda:	e4a080e7          	jalr	-438(ra) # 80001b20 <proc_pagetable>
    80001cde:	892a                	mv	s2,a0
    80001ce0:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001ce2:	c525                	beqz	a0,80001d4a <allocproc+0xd2>
  memset(&p->context, 0, sizeof(p->context));
    80001ce4:	07000613          	li	a2,112
    80001ce8:	4581                	li	a1,0
    80001cea:	06048513          	addi	a0,s1,96
    80001cee:	fffff097          	auipc	ra,0xfffff
    80001cf2:	fde080e7          	jalr	-34(ra) # 80000ccc <memset>
  p->context.ra = (uint64)forkret;
    80001cf6:	00000797          	auipc	a5,0x0
    80001cfa:	d9e78793          	addi	a5,a5,-610 # 80001a94 <forkret>
    80001cfe:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d00:	60bc                	ld	a5,64(s1)
    80001d02:	6705                	lui	a4,0x1
    80001d04:	97ba                	add	a5,a5,a4
    80001d06:	f4bc                	sd	a5,104(s1)
  p->queue = priority(p);
    80001d08:	1684a703          	lw	a4,360(s1)
    80001d0c:	46a9                	li	a3,10
    80001d0e:	4781                	li	a5,0
    80001d10:	00e6c563          	blt	a3,a4,80001d1a <allocproc+0xa2>
    80001d14:	ff772793          	slti	a5,a4,-9
    80001d18:	0785                	addi	a5,a5,1
    80001d1a:	16f4aa23          	sw	a5,372(s1)
  p->pass = DEFAULT_PASS;
    80001d1e:	4785                	li	a5,1
    80001d20:	16f4bc23          	sd	a5,376(s1)
}
    80001d24:	8526                	mv	a0,s1
    80001d26:	60e2                	ld	ra,24(sp)
    80001d28:	6442                	ld	s0,16(sp)
    80001d2a:	64a2                	ld	s1,8(sp)
    80001d2c:	6902                	ld	s2,0(sp)
    80001d2e:	6105                	addi	sp,sp,32
    80001d30:	8082                	ret
    freeproc(p);
    80001d32:	8526                	mv	a0,s1
    80001d34:	00000097          	auipc	ra,0x0
    80001d38:	eda080e7          	jalr	-294(ra) # 80001c0e <freeproc>
    release(&p->lock);
    80001d3c:	8526                	mv	a0,s1
    80001d3e:	fffff097          	auipc	ra,0xfffff
    80001d42:	f46080e7          	jalr	-186(ra) # 80000c84 <release>
    return 0;
    80001d46:	84ca                	mv	s1,s2
    80001d48:	bff1                	j	80001d24 <allocproc+0xac>
    freeproc(p);
    80001d4a:	8526                	mv	a0,s1
    80001d4c:	00000097          	auipc	ra,0x0
    80001d50:	ec2080e7          	jalr	-318(ra) # 80001c0e <freeproc>
    release(&p->lock);
    80001d54:	8526                	mv	a0,s1
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	f2e080e7          	jalr	-210(ra) # 80000c84 <release>
    return 0;
    80001d5e:	84ca                	mv	s1,s2
    80001d60:	b7d1                	j	80001d24 <allocproc+0xac>

0000000080001d62 <userinit>:
{
    80001d62:	1101                	addi	sp,sp,-32
    80001d64:	ec06                	sd	ra,24(sp)
    80001d66:	e822                	sd	s0,16(sp)
    80001d68:	e426                	sd	s1,8(sp)
    80001d6a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d6c:	00000097          	auipc	ra,0x0
    80001d70:	f0c080e7          	jalr	-244(ra) # 80001c78 <allocproc>
    80001d74:	84aa                	mv	s1,a0
  initproc = p;
    80001d76:	00007797          	auipc	a5,0x7
    80001d7a:	baa7b123          	sd	a0,-1118(a5) # 80008918 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d7e:	03400613          	li	a2,52
    80001d82:	00007597          	auipc	a1,0x7
    80001d86:	b0e58593          	addi	a1,a1,-1266 # 80008890 <initcode>
    80001d8a:	6928                	ld	a0,80(a0)
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	5c0080e7          	jalr	1472(ra) # 8000134c <uvmfirst>
  p->sz = PGSIZE;
    80001d94:	6785                	lui	a5,0x1
    80001d96:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d98:	6cb8                	ld	a4,88(s1)
    80001d9a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d9e:	6cb8                	ld	a4,88(s1)
    80001da0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001da2:	4641                	li	a2,16
    80001da4:	00006597          	auipc	a1,0x6
    80001da8:	45c58593          	addi	a1,a1,1116 # 80008200 <digits+0x1c0>
    80001dac:	15848513          	addi	a0,s1,344
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	066080e7          	jalr	102(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001db8:	00006517          	auipc	a0,0x6
    80001dbc:	45850513          	addi	a0,a0,1112 # 80008210 <digits+0x1d0>
    80001dc0:	00002097          	auipc	ra,0x2
    80001dc4:	35e080e7          	jalr	862(ra) # 8000411e <namei>
    80001dc8:	14a4b823          	sd	a0,336(s1)
  make_runnable(p);
    80001dcc:	8526                	mv	a0,s1
    80001dce:	00000097          	auipc	ra,0x0
    80001dd2:	a56080e7          	jalr	-1450(ra) # 80001824 <make_runnable>
  release(&p->lock);
    80001dd6:	8526                	mv	a0,s1
    80001dd8:	fffff097          	auipc	ra,0xfffff
    80001ddc:	eac080e7          	jalr	-340(ra) # 80000c84 <release>
}
    80001de0:	60e2                	ld	ra,24(sp)
    80001de2:	6442                	ld	s0,16(sp)
    80001de4:	64a2                	ld	s1,8(sp)
    80001de6:	6105                	addi	sp,sp,32
    80001de8:	8082                	ret

0000000080001dea <growproc>:
{
    80001dea:	1101                	addi	sp,sp,-32
    80001dec:	ec06                	sd	ra,24(sp)
    80001dee:	e822                	sd	s0,16(sp)
    80001df0:	e426                	sd	s1,8(sp)
    80001df2:	e04a                	sd	s2,0(sp)
    80001df4:	1000                	addi	s0,sp,32
    80001df6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001df8:	00000097          	auipc	ra,0x0
    80001dfc:	c0a080e7          	jalr	-1014(ra) # 80001a02 <myproc>
    80001e00:	892a                	mv	s2,a0
  sz = p->sz;
    80001e02:	652c                	ld	a1,72(a0)
    80001e04:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001e08:	00904f63          	bgtz	s1,80001e26 <growproc+0x3c>
  } else if(n < 0){
    80001e0c:	0204cc63          	bltz	s1,80001e44 <growproc+0x5a>
  p->sz = sz;
    80001e10:	1602                	slli	a2,a2,0x20
    80001e12:	9201                	srli	a2,a2,0x20
    80001e14:	04c93423          	sd	a2,72(s2)
  return 0;
    80001e18:	4501                	li	a0,0
}
    80001e1a:	60e2                	ld	ra,24(sp)
    80001e1c:	6442                	ld	s0,16(sp)
    80001e1e:	64a2                	ld	s1,8(sp)
    80001e20:	6902                	ld	s2,0(sp)
    80001e22:	6105                	addi	sp,sp,32
    80001e24:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e26:	9e25                	addw	a2,a2,s1
    80001e28:	1602                	slli	a2,a2,0x20
    80001e2a:	9201                	srli	a2,a2,0x20
    80001e2c:	1582                	slli	a1,a1,0x20
    80001e2e:	9181                	srli	a1,a1,0x20
    80001e30:	6928                	ld	a0,80(a0)
    80001e32:	fffff097          	auipc	ra,0xfffff
    80001e36:	5d4080e7          	jalr	1492(ra) # 80001406 <uvmalloc>
    80001e3a:	0005061b          	sext.w	a2,a0
    80001e3e:	fa69                	bnez	a2,80001e10 <growproc+0x26>
      return -1;
    80001e40:	557d                	li	a0,-1
    80001e42:	bfe1                	j	80001e1a <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e44:	9e25                	addw	a2,a2,s1
    80001e46:	1602                	slli	a2,a2,0x20
    80001e48:	9201                	srli	a2,a2,0x20
    80001e4a:	1582                	slli	a1,a1,0x20
    80001e4c:	9181                	srli	a1,a1,0x20
    80001e4e:	6928                	ld	a0,80(a0)
    80001e50:	fffff097          	auipc	ra,0xfffff
    80001e54:	56e080e7          	jalr	1390(ra) # 800013be <uvmdealloc>
    80001e58:	0005061b          	sext.w	a2,a0
    80001e5c:	bf55                	j	80001e10 <growproc+0x26>

0000000080001e5e <fork>:
{
    80001e5e:	7139                	addi	sp,sp,-64
    80001e60:	fc06                	sd	ra,56(sp)
    80001e62:	f822                	sd	s0,48(sp)
    80001e64:	f426                	sd	s1,40(sp)
    80001e66:	f04a                	sd	s2,32(sp)
    80001e68:	ec4e                	sd	s3,24(sp)
    80001e6a:	e852                	sd	s4,16(sp)
    80001e6c:	e456                	sd	s5,8(sp)
    80001e6e:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e70:	00000097          	auipc	ra,0x0
    80001e74:	b92080e7          	jalr	-1134(ra) # 80001a02 <myproc>
    80001e78:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e7a:	00000097          	auipc	ra,0x0
    80001e7e:	dfe080e7          	jalr	-514(ra) # 80001c78 <allocproc>
    80001e82:	10050e63          	beqz	a0,80001f9e <fork+0x140>
    80001e86:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e88:	048ab603          	ld	a2,72(s5)
    80001e8c:	692c                	ld	a1,80(a0)
    80001e8e:	050ab503          	ld	a0,80(s5)
    80001e92:	fffff097          	auipc	ra,0xfffff
    80001e96:	6c0080e7          	jalr	1728(ra) # 80001552 <uvmcopy>
    80001e9a:	04054863          	bltz	a0,80001eea <fork+0x8c>
  np->sz = p->sz;
    80001e9e:	048ab783          	ld	a5,72(s5)
    80001ea2:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ea6:	058ab683          	ld	a3,88(s5)
    80001eaa:	87b6                	mv	a5,a3
    80001eac:	058a3703          	ld	a4,88(s4)
    80001eb0:	12068693          	addi	a3,a3,288
    80001eb4:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001eb8:	6788                	ld	a0,8(a5)
    80001eba:	6b8c                	ld	a1,16(a5)
    80001ebc:	6f90                	ld	a2,24(a5)
    80001ebe:	01073023          	sd	a6,0(a4)
    80001ec2:	e708                	sd	a0,8(a4)
    80001ec4:	eb0c                	sd	a1,16(a4)
    80001ec6:	ef10                	sd	a2,24(a4)
    80001ec8:	02078793          	addi	a5,a5,32
    80001ecc:	02070713          	addi	a4,a4,32
    80001ed0:	fed792e3          	bne	a5,a3,80001eb4 <fork+0x56>
  np->trapframe->a0 = 0;
    80001ed4:	058a3783          	ld	a5,88(s4)
    80001ed8:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001edc:	0d0a8493          	addi	s1,s5,208
    80001ee0:	0d0a0913          	addi	s2,s4,208
    80001ee4:	150a8993          	addi	s3,s5,336
    80001ee8:	a00d                	j	80001f0a <fork+0xac>
    freeproc(np);
    80001eea:	8552                	mv	a0,s4
    80001eec:	00000097          	auipc	ra,0x0
    80001ef0:	d22080e7          	jalr	-734(ra) # 80001c0e <freeproc>
    release(&np->lock);
    80001ef4:	8552                	mv	a0,s4
    80001ef6:	fffff097          	auipc	ra,0xfffff
    80001efa:	d8e080e7          	jalr	-626(ra) # 80000c84 <release>
    return -1;
    80001efe:	597d                	li	s2,-1
    80001f00:	a069                	j	80001f8a <fork+0x12c>
  for(i = 0; i < NOFILE; i++)
    80001f02:	04a1                	addi	s1,s1,8
    80001f04:	0921                	addi	s2,s2,8
    80001f06:	01348b63          	beq	s1,s3,80001f1c <fork+0xbe>
    if(p->ofile[i])
    80001f0a:	6088                	ld	a0,0(s1)
    80001f0c:	d97d                	beqz	a0,80001f02 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f0e:	00003097          	auipc	ra,0x3
    80001f12:	8a6080e7          	jalr	-1882(ra) # 800047b4 <filedup>
    80001f16:	00a93023          	sd	a0,0(s2)
    80001f1a:	b7e5                	j	80001f02 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001f1c:	150ab503          	ld	a0,336(s5)
    80001f20:	00002097          	auipc	ra,0x2
    80001f24:	a0a080e7          	jalr	-1526(ra) # 8000392a <idup>
    80001f28:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f2c:	4641                	li	a2,16
    80001f2e:	158a8593          	addi	a1,s5,344
    80001f32:	158a0513          	addi	a0,s4,344
    80001f36:	fffff097          	auipc	ra,0xfffff
    80001f3a:	ee0080e7          	jalr	-288(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001f3e:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001f42:	8552                	mv	a0,s4
    80001f44:	fffff097          	auipc	ra,0xfffff
    80001f48:	d40080e7          	jalr	-704(ra) # 80000c84 <release>
  acquire(&wait_lock);
    80001f4c:	0000f497          	auipc	s1,0xf
    80001f50:	2ec48493          	addi	s1,s1,748 # 80011238 <wait_lock>
    80001f54:	8526                	mv	a0,s1
    80001f56:	fffff097          	auipc	ra,0xfffff
    80001f5a:	c7a080e7          	jalr	-902(ra) # 80000bd0 <acquire>
  np->parent = p;
    80001f5e:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f62:	8526                	mv	a0,s1
    80001f64:	fffff097          	auipc	ra,0xfffff
    80001f68:	d20080e7          	jalr	-736(ra) # 80000c84 <release>
  acquire(&np->lock);
    80001f6c:	8552                	mv	a0,s4
    80001f6e:	fffff097          	auipc	ra,0xfffff
    80001f72:	c62080e7          	jalr	-926(ra) # 80000bd0 <acquire>
  make_runnable(np);
    80001f76:	8552                	mv	a0,s4
    80001f78:	00000097          	auipc	ra,0x0
    80001f7c:	8ac080e7          	jalr	-1876(ra) # 80001824 <make_runnable>
  release(&np->lock);
    80001f80:	8552                	mv	a0,s4
    80001f82:	fffff097          	auipc	ra,0xfffff
    80001f86:	d02080e7          	jalr	-766(ra) # 80000c84 <release>
}
    80001f8a:	854a                	mv	a0,s2
    80001f8c:	70e2                	ld	ra,56(sp)
    80001f8e:	7442                	ld	s0,48(sp)
    80001f90:	74a2                	ld	s1,40(sp)
    80001f92:	7902                	ld	s2,32(sp)
    80001f94:	69e2                	ld	s3,24(sp)
    80001f96:	6a42                	ld	s4,16(sp)
    80001f98:	6aa2                	ld	s5,8(sp)
    80001f9a:	6121                	addi	sp,sp,64
    80001f9c:	8082                	ret
    return -1;
    80001f9e:	597d                	li	s2,-1
    80001fa0:	b7ed                	j	80001f8a <fork+0x12c>

0000000080001fa2 <scheduler>:
{
    80001fa2:	711d                	addi	sp,sp,-96
    80001fa4:	ec86                	sd	ra,88(sp)
    80001fa6:	e8a2                	sd	s0,80(sp)
    80001fa8:	e4a6                	sd	s1,72(sp)
    80001faa:	e0ca                	sd	s2,64(sp)
    80001fac:	fc4e                	sd	s3,56(sp)
    80001fae:	f852                	sd	s4,48(sp)
    80001fb0:	f456                	sd	s5,40(sp)
    80001fb2:	f05a                	sd	s6,32(sp)
    80001fb4:	ec5e                	sd	s7,24(sp)
    80001fb6:	e862                	sd	s8,16(sp)
    80001fb8:	e466                	sd	s9,8(sp)
    80001fba:	e06a                	sd	s10,0(sp)
    80001fbc:	1080                	addi	s0,sp,96
    80001fbe:	8792                	mv	a5,tp
  int id = r_tp();
    80001fc0:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fc2:	00779a93          	slli	s5,a5,0x7
    80001fc6:	0000f717          	auipc	a4,0xf
    80001fca:	bca70713          	addi	a4,a4,-1078 # 80010b90 <qtable>
    80001fce:	9756                	add	a4,a4,s5
    80001fd0:	6c073023          	sd	zero,1728(a4)
    swtch(&c->context, &p->context);
    80001fd4:	0000f717          	auipc	a4,0xf
    80001fd8:	28470713          	addi	a4,a4,644 # 80011258 <cpus+0x8>
    80001fdc:	9aba                	add	s5,s5,a4
  struct proc *p = 0;
    80001fde:	4481                	li	s1,0
    if (p_kicked) {
    80001fe0:	00007917          	auipc	s2,0x7
    80001fe4:	8a890913          	addi	s2,s2,-1880 # 80008888 <p_kicked>
    c->proc = p;
    80001fe8:	0000fb17          	auipc	s6,0xf
    80001fec:	ba8b0b13          	addi	s6,s6,-1112 # 80010b90 <qtable>
    80001ff0:	079e                	slli	a5,a5,0x7
    80001ff2:	00fb09b3          	add	s3,s6,a5
    if (log_count < LOG_SIZE && !(log_count && schedlog[log_count - 1].pid == p->pid && schedlog[log_count-1].queue == p->queue))
    80001ff6:	00007a17          	auipc	s4,0x7
    80001ffa:	88ea0a13          	addi	s4,s4,-1906 # 80008884 <log_count>
      schedlog[log_count].priority_boost = 0;
    80001ffe:	00010b97          	auipc	s7,0x10
    80002002:	b92b8b93          	addi	s7,s7,-1134 # 80011b90 <schedlog+0x540>
      schedlog[log_count++].time = time;
    80002006:	00007c97          	auipc	s9,0x7
    8000200a:	91ac8c93          	addi	s9,s9,-1766 # 80008920 <time>
      p = &proc[process_id];
    8000200e:	00010c17          	auipc	s8,0x10
    80002012:	c82c0c13          	addi	s8,s8,-894 # 80011c90 <proc>
    80002016:	a0a9                	j	80002060 <scheduler+0xbe>
      schedlog[log_count].priority_boost = 0;
    80002018:	00479713          	slli	a4,a5,0x4
    8000201c:	975e                	add	a4,a4,s7
    8000201e:	ac072623          	sw	zero,-1332(a4)
      schedlog[log_count].queue = p->queue;
    80002022:	1744a683          	lw	a3,372(s1)
    80002026:	acd72423          	sw	a3,-1336(a4)
      schedlog[log_count].pid = p->pid;
    8000202a:	5894                	lw	a3,48(s1)
    8000202c:	acd72023          	sw	a3,-1344(a4)
      schedlog[log_count++].time = time;
    80002030:	2785                	addiw	a5,a5,1
    80002032:	00fa2023          	sw	a5,0(s4)
    80002036:	000ca783          	lw	a5,0(s9)
    8000203a:	acf72223          	sw	a5,-1340(a4)
    p_kicked = 1;
    8000203e:	4785                	li	a5,1
    80002040:	00f92023          	sw	a5,0(s2)
    swtch(&c->context, &p->context);
    80002044:	06048593          	addi	a1,s1,96
    80002048:	8556                	mv	a0,s5
    8000204a:	00001097          	auipc	ra,0x1
    8000204e:	894080e7          	jalr	-1900(ra) # 800028de <swtch>
    c->proc = 0;
    80002052:	6c09b023          	sd	zero,1728(s3)
    release(&p->lock);
    80002056:	856a                	mv	a0,s10
    80002058:	fffff097          	auipc	ra,0xfffff
    8000205c:	c2c080e7          	jalr	-980(ra) # 80000c84 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002060:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002064:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002068:	10079073          	csrw	sstatus,a5
    if (p_kicked) {
    8000206c:	00092783          	lw	a5,0(s2)
    80002070:	cf91                	beqz	a5,8000208c <scheduler+0xea>
      process_id = dequeue(qtable);
    80002072:	855a                	mv	a0,s6
    80002074:	00004097          	auipc	ra,0x4
    80002078:	530080e7          	jalr	1328(ra) # 800065a4 <dequeue>
      if (process_id == EMPTY)
    8000207c:	57fd                	li	a5,-1
    8000207e:	fef501e3          	beq	a0,a5,80002060 <scheduler+0xbe>
      p = &proc[process_id];
    80002082:	00151493          	slli	s1,a0,0x1
    80002086:	94aa                	add	s1,s1,a0
    80002088:	049e                	slli	s1,s1,0x7
    8000208a:	94e2                	add	s1,s1,s8
    acquire(&p->lock);
    8000208c:	8d26                	mv	s10,s1
    8000208e:	8526                	mv	a0,s1
    80002090:	fffff097          	auipc	ra,0xfffff
    80002094:	b40080e7          	jalr	-1216(ra) # 80000bd0 <acquire>
    p->state = RUNNING;
    80002098:	4791                	li	a5,4
    8000209a:	cc9c                	sw	a5,24(s1)
    c->proc = p;
    8000209c:	6c99b023          	sd	s1,1728(s3)
    if (log_count < LOG_SIZE && !(log_count && schedlog[log_count - 1].pid == p->pid && schedlog[log_count-1].queue == p->queue))
    800020a0:	000a2783          	lw	a5,0(s4)
    800020a4:	06300713          	li	a4,99
    800020a8:	f8f74be3          	blt	a4,a5,8000203e <scheduler+0x9c>
    800020ac:	d7b5                	beqz	a5,80002018 <scheduler+0x76>
    800020ae:	fff7869b          	addiw	a3,a5,-1
    800020b2:	00469713          	slli	a4,a3,0x4
    800020b6:	975e                	add	a4,a4,s7
    800020b8:	ac072603          	lw	a2,-1344(a4)
    800020bc:	5898                	lw	a4,48(s1)
    800020be:	f4e61de3          	bne	a2,a4,80002018 <scheduler+0x76>
    800020c2:	0692                	slli	a3,a3,0x4
    800020c4:	96de                	add	a3,a3,s7
    800020c6:	ac86a683          	lw	a3,-1336(a3)
    800020ca:	1744a703          	lw	a4,372(s1)
    800020ce:	f4e695e3          	bne	a3,a4,80002018 <scheduler+0x76>
    800020d2:	b7b5                	j	8000203e <scheduler+0x9c>

00000000800020d4 <sched>:
{
    800020d4:	7179                	addi	sp,sp,-48
    800020d6:	f406                	sd	ra,40(sp)
    800020d8:	f022                	sd	s0,32(sp)
    800020da:	ec26                	sd	s1,24(sp)
    800020dc:	e84a                	sd	s2,16(sp)
    800020de:	e44e                	sd	s3,8(sp)
    800020e0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800020e2:	00000097          	auipc	ra,0x0
    800020e6:	920080e7          	jalr	-1760(ra) # 80001a02 <myproc>
    800020ea:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800020ec:	fffff097          	auipc	ra,0xfffff
    800020f0:	a6a080e7          	jalr	-1430(ra) # 80000b56 <holding>
    800020f4:	c93d                	beqz	a0,8000216a <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020f6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020f8:	2781                	sext.w	a5,a5
    800020fa:	079e                	slli	a5,a5,0x7
    800020fc:	0000f717          	auipc	a4,0xf
    80002100:	a9470713          	addi	a4,a4,-1388 # 80010b90 <qtable>
    80002104:	97ba                	add	a5,a5,a4
    80002106:	7387a703          	lw	a4,1848(a5)
    8000210a:	4785                	li	a5,1
    8000210c:	06f71763          	bne	a4,a5,8000217a <sched+0xa6>
  if(p->state == RUNNING)
    80002110:	4c98                	lw	a4,24(s1)
    80002112:	4791                	li	a5,4
    80002114:	06f70b63          	beq	a4,a5,8000218a <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002118:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000211c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000211e:	efb5                	bnez	a5,8000219a <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002120:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002122:	0000f917          	auipc	s2,0xf
    80002126:	a6e90913          	addi	s2,s2,-1426 # 80010b90 <qtable>
    8000212a:	2781                	sext.w	a5,a5
    8000212c:	079e                	slli	a5,a5,0x7
    8000212e:	97ca                	add	a5,a5,s2
    80002130:	73c7a983          	lw	s3,1852(a5)
    80002134:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002136:	2781                	sext.w	a5,a5
    80002138:	079e                	slli	a5,a5,0x7
    8000213a:	0000f597          	auipc	a1,0xf
    8000213e:	11e58593          	addi	a1,a1,286 # 80011258 <cpus+0x8>
    80002142:	95be                	add	a1,a1,a5
    80002144:	06048513          	addi	a0,s1,96
    80002148:	00000097          	auipc	ra,0x0
    8000214c:	796080e7          	jalr	1942(ra) # 800028de <swtch>
    80002150:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002152:	2781                	sext.w	a5,a5
    80002154:	079e                	slli	a5,a5,0x7
    80002156:	97ca                	add	a5,a5,s2
    80002158:	7337ae23          	sw	s3,1852(a5)
}
    8000215c:	70a2                	ld	ra,40(sp)
    8000215e:	7402                	ld	s0,32(sp)
    80002160:	64e2                	ld	s1,24(sp)
    80002162:	6942                	ld	s2,16(sp)
    80002164:	69a2                	ld	s3,8(sp)
    80002166:	6145                	addi	sp,sp,48
    80002168:	8082                	ret
    panic("sched p->lock");
    8000216a:	00006517          	auipc	a0,0x6
    8000216e:	0ae50513          	addi	a0,a0,174 # 80008218 <digits+0x1d8>
    80002172:	ffffe097          	auipc	ra,0xffffe
    80002176:	3c6080e7          	jalr	966(ra) # 80000538 <panic>
    panic("sched locks");
    8000217a:	00006517          	auipc	a0,0x6
    8000217e:	0ae50513          	addi	a0,a0,174 # 80008228 <digits+0x1e8>
    80002182:	ffffe097          	auipc	ra,0xffffe
    80002186:	3b6080e7          	jalr	950(ra) # 80000538 <panic>
    panic("sched running");
    8000218a:	00006517          	auipc	a0,0x6
    8000218e:	0ae50513          	addi	a0,a0,174 # 80008238 <digits+0x1f8>
    80002192:	ffffe097          	auipc	ra,0xffffe
    80002196:	3a6080e7          	jalr	934(ra) # 80000538 <panic>
    panic("sched interruptible");
    8000219a:	00006517          	auipc	a0,0x6
    8000219e:	0ae50513          	addi	a0,a0,174 # 80008248 <digits+0x208>
    800021a2:	ffffe097          	auipc	ra,0xffffe
    800021a6:	396080e7          	jalr	918(ra) # 80000538 <panic>

00000000800021aa <yield>:
{
    800021aa:	711d                	addi	sp,sp,-96
    800021ac:	ec86                	sd	ra,88(sp)
    800021ae:	e8a2                	sd	s0,80(sp)
    800021b0:	e4a6                	sd	s1,72(sp)
    800021b2:	e0ca                	sd	s2,64(sp)
    800021b4:	fc4e                	sd	s3,56(sp)
    800021b6:	f852                	sd	s4,48(sp)
    800021b8:	f456                	sd	s5,40(sp)
    800021ba:	f05a                	sd	s6,32(sp)
    800021bc:	ec5e                	sd	s7,24(sp)
    800021be:	e862                	sd	s8,16(sp)
    800021c0:	e466                	sd	s9,8(sp)
    800021c2:	e06a                	sd	s10,0(sp)
    800021c4:	1080                	addi	s0,sp,96
  struct proc *p = myproc();
    800021c6:	00000097          	auipc	ra,0x0
    800021ca:	83c080e7          	jalr	-1988(ra) # 80001a02 <myproc>
    800021ce:	8caa                	mv	s9,a0
  acquire(&p->lock);
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	a00080e7          	jalr	-1536(ra) # 80000bd0 <acquire>
  if (p->state != UNUSED)
    800021d8:	018ca783          	lw	a5,24(s9)
    800021dc:	c791                	beqz	a5,800021e8 <yield+0x3e>
    ++p->runtime;
    800021de:	170ca783          	lw	a5,368(s9)
    800021e2:	2785                	addiw	a5,a5,1
    800021e4:	16fca823          	sw	a5,368(s9)
  p->state = RUNNABLE;
    800021e8:	478d                	li	a5,3
    800021ea:	00fcac23          	sw	a5,24(s9)
  if (p->runtime >= quantum(p))
    800021ee:	170ca683          	lw	a3,368(s9)
    800021f2:	174ca783          	lw	a5,372(s9)
    800021f6:	4609                	li	a2,2
    800021f8:	4705                	li	a4,1
    800021fa:	00c78763          	beq	a5,a2,80002208 <yield+0x5e>
    800021fe:	4605                	li	a2,1
    80002200:	4729                	li	a4,10
    80002202:	00c78363          	beq	a5,a2,80002208 <yield+0x5e>
    80002206:	473d                	li	a4,15
    80002208:	08e6de63          	bge	a3,a4,800022a4 <yield+0xfa>
    p_kicked = 0;
    8000220c:	00006797          	auipc	a5,0x6
    80002210:	6607ae23          	sw	zero,1660(a5) # 80008888 <p_kicked>
  if (time % 60 == 0) {
    80002214:	00006797          	auipc	a5,0x6
    80002218:	70c7a783          	lw	a5,1804(a5) # 80008920 <time>
    8000221c:	03c00a13          	li	s4,60
    80002220:	0347ea3b          	remw	s4,a5,s4
    80002224:	100a1463          	bnez	s4,8000232c <yield+0x182>
    if (log_count < LOG_SIZE) {
    80002228:	00006717          	auipc	a4,0x6
    8000222c:	65c72703          	lw	a4,1628(a4) # 80008884 <log_count>
    80002230:	06300693          	li	a3,99
    80002234:	02e6c363          	blt	a3,a4,8000225a <yield+0xb0>
      schedlog[log_count].priority_boost = 1;
    80002238:	00471613          	slli	a2,a4,0x4
    8000223c:	00010697          	auipc	a3,0x10
    80002240:	95468693          	addi	a3,a3,-1708 # 80011b90 <schedlog+0x540>
    80002244:	96b2                	add	a3,a3,a2
    80002246:	4605                	li	a2,1
    80002248:	acc6a623          	sw	a2,-1332(a3)
      schedlog[log_count++].time = time;
    8000224c:	2705                	addiw	a4,a4,1
    8000224e:	00006617          	auipc	a2,0x6
    80002252:	62e62b23          	sw	a4,1590(a2) # 80008884 <log_count>
    80002256:	acf6a223          	sw	a5,-1340(a3)
    initialize(qtable, NUM_QUEUES);
    8000225a:	458d                	li	a1,3
    8000225c:	0000f517          	auipc	a0,0xf
    80002260:	93450513          	addi	a0,a0,-1740 # 80010b90 <qtable>
    80002264:	00004097          	auipc	ra,0x4
    80002268:	39c080e7          	jalr	924(ra) # 80006600 <initialize>
    p->runtime = 0;
    8000226c:	160ca823          	sw	zero,368(s9)
    p_kicked = 1;
    80002270:	4785                	li	a5,1
    80002272:	00006717          	auipc	a4,0x6
    80002276:	60f72b23          	sw	a5,1558(a4) # 80008888 <p_kicked>
    for (i = 0; i < NPROC; ++i) {
    8000227a:	00010497          	auipc	s1,0x10
    8000227e:	a1648493          	addi	s1,s1,-1514 # 80011c90 <proc>
    80002282:	00016997          	auipc	s3,0x16
    80002286:	a0e98993          	addi	s3,s3,-1522 # 80017c90 <tickslock>
      if (proc[i].state == RUNNABLE) {
    8000228a:	490d                	li	s2,3
        proc[i].queue = priority((&proc[i]));
    8000228c:	4c29                	li	s8,10
        add_to_queue((&proc[i]));
    8000228e:	8ba6                	mv	s7,s1
    80002290:	00006b17          	auipc	s6,0x6
    80002294:	d70b0b13          	addi	s6,s6,-656 # 80008000 <etext>
    80002298:	0000fa97          	auipc	s5,0xf
    8000229c:	8f8a8a93          	addi	s5,s5,-1800 # 80010b90 <qtable>
        proc[i].queue = priority((&proc[i]));
    800022a0:	5d5d                	li	s10,-9
    800022a2:	a885                	j	80002312 <yield+0x168>
    p->queue = MAX(QUEUE_LOW, p->queue - 1);
    800022a4:	85be                	mv	a1,a5
    800022a6:	02f05f63          	blez	a5,800022e4 <yield+0x13a>
    800022aa:	35fd                	addiw	a1,a1,-1
    800022ac:	16bcaa23          	sw	a1,372(s9)
    p->runtime = 0;
    800022b0:	160ca823          	sw	zero,368(s9)
    enqueue_back(qtable, p->queue, p - proc, DEFAULT_PASS);
    800022b4:	00010797          	auipc	a5,0x10
    800022b8:	9dc78793          	addi	a5,a5,-1572 # 80011c90 <proc>
    800022bc:	40fc87b3          	sub	a5,s9,a5
    800022c0:	879d                	srai	a5,a5,0x7
    800022c2:	4685                	li	a3,1
    800022c4:	00006617          	auipc	a2,0x6
    800022c8:	d3c63603          	ld	a2,-708(a2) # 80008000 <etext>
    800022cc:	02c78633          	mul	a2,a5,a2
    800022d0:	2581                	sext.w	a1,a1
    800022d2:	0000f517          	auipc	a0,0xf
    800022d6:	8be50513          	addi	a0,a0,-1858 # 80010b90 <qtable>
    800022da:	00004097          	auipc	ra,0x4
    800022de:	242080e7          	jalr	578(ra) # 8000651c <enqueue_back>
    800022e2:	bf0d                	j	80002214 <yield+0x6a>
    p->queue = MAX(QUEUE_LOW, p->queue - 1);
    800022e4:	4585                	li	a1,1
    800022e6:	b7d1                	j	800022aa <yield+0x100>
        proc[i].queue = priority((&proc[i]));
    800022e8:	16b62a23          	sw	a1,372(a2)
        proc[i].runtime = 0;
    800022ec:	16062823          	sw	zero,368(a2)
        add_to_queue((&proc[i]));
    800022f0:	41760633          	sub	a2,a2,s7
    800022f4:	861d                	srai	a2,a2,0x7
    800022f6:	000b3783          	ld	a5,0(s6)
    800022fa:	4685                	li	a3,1
    800022fc:	02f60633          	mul	a2,a2,a5
    80002300:	8556                	mv	a0,s5
    80002302:	00004097          	auipc	ra,0x4
    80002306:	21a080e7          	jalr	538(ra) # 8000651c <enqueue_back>
    for (i = 0; i < NPROC; ++i) {
    8000230a:	18048493          	addi	s1,s1,384
    8000230e:	01348f63          	beq	s1,s3,8000232c <yield+0x182>
      if (proc[i].state == RUNNABLE) {
    80002312:	8626                	mv	a2,s1
    80002314:	4c9c                	lw	a5,24(s1)
    80002316:	ff279ae3          	bne	a5,s2,8000230a <yield+0x160>
        proc[i].queue = priority((&proc[i]));
    8000231a:	1684a783          	lw	a5,360(s1)
    8000231e:	85d2                	mv	a1,s4
    80002320:	fcfc44e3          	blt	s8,a5,800022e8 <yield+0x13e>
    80002324:	01a7a5b3          	slt	a1,a5,s10
    80002328:	0585                	addi	a1,a1,1
    8000232a:	bf7d                	j	800022e8 <yield+0x13e>
  sched();
    8000232c:	00000097          	auipc	ra,0x0
    80002330:	da8080e7          	jalr	-600(ra) # 800020d4 <sched>
  release(&p->lock);
    80002334:	8566                	mv	a0,s9
    80002336:	fffff097          	auipc	ra,0xfffff
    8000233a:	94e080e7          	jalr	-1714(ra) # 80000c84 <release>
}
    8000233e:	60e6                	ld	ra,88(sp)
    80002340:	6446                	ld	s0,80(sp)
    80002342:	64a6                	ld	s1,72(sp)
    80002344:	6906                	ld	s2,64(sp)
    80002346:	79e2                	ld	s3,56(sp)
    80002348:	7a42                	ld	s4,48(sp)
    8000234a:	7aa2                	ld	s5,40(sp)
    8000234c:	7b02                	ld	s6,32(sp)
    8000234e:	6be2                	ld	s7,24(sp)
    80002350:	6c42                	ld	s8,16(sp)
    80002352:	6ca2                	ld	s9,8(sp)
    80002354:	6d02                	ld	s10,0(sp)
    80002356:	6125                	addi	sp,sp,96
    80002358:	8082                	ret

000000008000235a <sys_nice>:
{
    8000235a:	7179                	addi	sp,sp,-48
    8000235c:	f406                	sd	ra,40(sp)
    8000235e:	f022                	sd	s0,32(sp)
    80002360:	ec26                	sd	s1,24(sp)
    80002362:	1800                	addi	s0,sp,48
  argint(0, &inc);
    80002364:	fdc40593          	addi	a1,s0,-36
    80002368:	4501                	li	a0,0
    8000236a:	00001097          	auipc	ra,0x1
    8000236e:	a7a080e7          	jalr	-1414(ra) # 80002de4 <argint>
  struct proc *p = myproc();
    80002372:	fffff097          	auipc	ra,0xfffff
    80002376:	690080e7          	jalr	1680(ra) # 80001a02 <myproc>
    8000237a:	84aa                	mv	s1,a0
  p->nice = MAX(MIN(p->nice + inc, NICE_MAX), NICE_MIN);
    8000237c:	16852783          	lw	a5,360(a0)
    80002380:	fdc42703          	lw	a4,-36(s0)
    80002384:	9fb9                	addw	a5,a5,a4
    80002386:	0007869b          	sext.w	a3,a5
    8000238a:	873e                	mv	a4,a5
    8000238c:	464d                	li	a2,19
    8000238e:	00d65363          	bge	a2,a3,80002394 <sys_nice+0x3a>
    80002392:	474d                	li	a4,19
    80002394:	87ba                	mv	a5,a4
    80002396:	2701                	sext.w	a4,a4
    80002398:	5631                	li	a2,-20
    8000239a:	00c75363          	bge	a4,a2,800023a0 <sys_nice+0x46>
    8000239e:	57b1                	li	a5,-20
    800023a0:	16f4a423          	sw	a5,360(s1)
  p->queue = priority(p);
    800023a4:	4729                	li	a4,10
    800023a6:	4781                	li	a5,0
    800023a8:	00d74563          	blt	a4,a3,800023b2 <sys_nice+0x58>
    800023ac:	ff76a793          	slti	a5,a3,-9
    800023b0:	0785                	addi	a5,a5,1
    800023b2:	16f4aa23          	sw	a5,372(s1)
  p->runtime = 0;
    800023b6:	1604a823          	sw	zero,368(s1)
  p_kicked = 1;
    800023ba:	4785                	li	a5,1
    800023bc:	00006717          	auipc	a4,0x6
    800023c0:	4cf72623          	sw	a5,1228(a4) # 80008888 <p_kicked>
  yield();
    800023c4:	00000097          	auipc	ra,0x0
    800023c8:	de6080e7          	jalr	-538(ra) # 800021aa <yield>
}
    800023cc:	1684a503          	lw	a0,360(s1)
    800023d0:	70a2                	ld	ra,40(sp)
    800023d2:	7402                	ld	s0,32(sp)
    800023d4:	64e2                	ld	s1,24(sp)
    800023d6:	6145                	addi	sp,sp,48
    800023d8:	8082                	ret

00000000800023da <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800023da:	7179                	addi	sp,sp,-48
    800023dc:	f406                	sd	ra,40(sp)
    800023de:	f022                	sd	s0,32(sp)
    800023e0:	ec26                	sd	s1,24(sp)
    800023e2:	e84a                	sd	s2,16(sp)
    800023e4:	e44e                	sd	s3,8(sp)
    800023e6:	1800                	addi	s0,sp,48
    800023e8:	89aa                	mv	s3,a0
    800023ea:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800023ec:	fffff097          	auipc	ra,0xfffff
    800023f0:	616080e7          	jalr	1558(ra) # 80001a02 <myproc>
    800023f4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800023f6:	ffffe097          	auipc	ra,0xffffe
    800023fa:	7da080e7          	jalr	2010(ra) # 80000bd0 <acquire>
  release(lk);
    800023fe:	854a                	mv	a0,s2
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	884080e7          	jalr	-1916(ra) # 80000c84 <release>

  // Go to sleep.
  p->chan = chan;
    80002408:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000240c:	4789                	li	a5,2
    8000240e:	cc9c                	sw	a5,24(s1)

  sched();
    80002410:	00000097          	auipc	ra,0x0
    80002414:	cc4080e7          	jalr	-828(ra) # 800020d4 <sched>

  // Tidy up.
  p->chan = 0;
    80002418:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000241c:	8526                	mv	a0,s1
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	866080e7          	jalr	-1946(ra) # 80000c84 <release>
  acquire(lk);
    80002426:	854a                	mv	a0,s2
    80002428:	ffffe097          	auipc	ra,0xffffe
    8000242c:	7a8080e7          	jalr	1960(ra) # 80000bd0 <acquire>
}
    80002430:	70a2                	ld	ra,40(sp)
    80002432:	7402                	ld	s0,32(sp)
    80002434:	64e2                	ld	s1,24(sp)
    80002436:	6942                	ld	s2,16(sp)
    80002438:	69a2                	ld	s3,8(sp)
    8000243a:	6145                	addi	sp,sp,48
    8000243c:	8082                	ret

000000008000243e <wait>:
{
    8000243e:	715d                	addi	sp,sp,-80
    80002440:	e486                	sd	ra,72(sp)
    80002442:	e0a2                	sd	s0,64(sp)
    80002444:	fc26                	sd	s1,56(sp)
    80002446:	f84a                	sd	s2,48(sp)
    80002448:	f44e                	sd	s3,40(sp)
    8000244a:	f052                	sd	s4,32(sp)
    8000244c:	ec56                	sd	s5,24(sp)
    8000244e:	e85a                	sd	s6,16(sp)
    80002450:	e45e                	sd	s7,8(sp)
    80002452:	e062                	sd	s8,0(sp)
    80002454:	0880                	addi	s0,sp,80
    80002456:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002458:	fffff097          	auipc	ra,0xfffff
    8000245c:	5aa080e7          	jalr	1450(ra) # 80001a02 <myproc>
    80002460:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002462:	0000f517          	auipc	a0,0xf
    80002466:	dd650513          	addi	a0,a0,-554 # 80011238 <wait_lock>
    8000246a:	ffffe097          	auipc	ra,0xffffe
    8000246e:	766080e7          	jalr	1894(ra) # 80000bd0 <acquire>
    havekids = 0;
    80002472:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002474:	4a15                	li	s4,5
        havekids = 1;
    80002476:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002478:	00016997          	auipc	s3,0x16
    8000247c:	81898993          	addi	s3,s3,-2024 # 80017c90 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002480:	0000fc17          	auipc	s8,0xf
    80002484:	db8c0c13          	addi	s8,s8,-584 # 80011238 <wait_lock>
    havekids = 0;
    80002488:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000248a:	00010497          	auipc	s1,0x10
    8000248e:	80648493          	addi	s1,s1,-2042 # 80011c90 <proc>
    80002492:	a0bd                	j	80002500 <wait+0xc2>
          pid = np->pid;
    80002494:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002498:	000b0e63          	beqz	s6,800024b4 <wait+0x76>
    8000249c:	4691                	li	a3,4
    8000249e:	02c48613          	addi	a2,s1,44
    800024a2:	85da                	mv	a1,s6
    800024a4:	05093503          	ld	a0,80(s2)
    800024a8:	fffff097          	auipc	ra,0xfffff
    800024ac:	1ae080e7          	jalr	430(ra) # 80001656 <copyout>
    800024b0:	02054563          	bltz	a0,800024da <wait+0x9c>
          freeproc(np);
    800024b4:	8526                	mv	a0,s1
    800024b6:	fffff097          	auipc	ra,0xfffff
    800024ba:	758080e7          	jalr	1880(ra) # 80001c0e <freeproc>
          release(&np->lock);
    800024be:	8526                	mv	a0,s1
    800024c0:	ffffe097          	auipc	ra,0xffffe
    800024c4:	7c4080e7          	jalr	1988(ra) # 80000c84 <release>
          release(&wait_lock);
    800024c8:	0000f517          	auipc	a0,0xf
    800024cc:	d7050513          	addi	a0,a0,-656 # 80011238 <wait_lock>
    800024d0:	ffffe097          	auipc	ra,0xffffe
    800024d4:	7b4080e7          	jalr	1972(ra) # 80000c84 <release>
          return pid;
    800024d8:	a09d                	j	8000253e <wait+0x100>
            release(&np->lock);
    800024da:	8526                	mv	a0,s1
    800024dc:	ffffe097          	auipc	ra,0xffffe
    800024e0:	7a8080e7          	jalr	1960(ra) # 80000c84 <release>
            release(&wait_lock);
    800024e4:	0000f517          	auipc	a0,0xf
    800024e8:	d5450513          	addi	a0,a0,-684 # 80011238 <wait_lock>
    800024ec:	ffffe097          	auipc	ra,0xffffe
    800024f0:	798080e7          	jalr	1944(ra) # 80000c84 <release>
            return -1;
    800024f4:	59fd                	li	s3,-1
    800024f6:	a0a1                	j	8000253e <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    800024f8:	18048493          	addi	s1,s1,384
    800024fc:	03348463          	beq	s1,s3,80002524 <wait+0xe6>
      if(np->parent == p){
    80002500:	7c9c                	ld	a5,56(s1)
    80002502:	ff279be3          	bne	a5,s2,800024f8 <wait+0xba>
        acquire(&np->lock);
    80002506:	8526                	mv	a0,s1
    80002508:	ffffe097          	auipc	ra,0xffffe
    8000250c:	6c8080e7          	jalr	1736(ra) # 80000bd0 <acquire>
        if(np->state == ZOMBIE){
    80002510:	4c9c                	lw	a5,24(s1)
    80002512:	f94781e3          	beq	a5,s4,80002494 <wait+0x56>
        release(&np->lock);
    80002516:	8526                	mv	a0,s1
    80002518:	ffffe097          	auipc	ra,0xffffe
    8000251c:	76c080e7          	jalr	1900(ra) # 80000c84 <release>
        havekids = 1;
    80002520:	8756                	mv	a4,s5
    80002522:	bfd9                	j	800024f8 <wait+0xba>
    if(!havekids || p->killed){
    80002524:	c701                	beqz	a4,8000252c <wait+0xee>
    80002526:	02892783          	lw	a5,40(s2)
    8000252a:	c79d                	beqz	a5,80002558 <wait+0x11a>
      release(&wait_lock);
    8000252c:	0000f517          	auipc	a0,0xf
    80002530:	d0c50513          	addi	a0,a0,-756 # 80011238 <wait_lock>
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	750080e7          	jalr	1872(ra) # 80000c84 <release>
      return -1;
    8000253c:	59fd                	li	s3,-1
}
    8000253e:	854e                	mv	a0,s3
    80002540:	60a6                	ld	ra,72(sp)
    80002542:	6406                	ld	s0,64(sp)
    80002544:	74e2                	ld	s1,56(sp)
    80002546:	7942                	ld	s2,48(sp)
    80002548:	79a2                	ld	s3,40(sp)
    8000254a:	7a02                	ld	s4,32(sp)
    8000254c:	6ae2                	ld	s5,24(sp)
    8000254e:	6b42                	ld	s6,16(sp)
    80002550:	6ba2                	ld	s7,8(sp)
    80002552:	6c02                	ld	s8,0(sp)
    80002554:	6161                	addi	sp,sp,80
    80002556:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002558:	85e2                	mv	a1,s8
    8000255a:	854a                	mv	a0,s2
    8000255c:	00000097          	auipc	ra,0x0
    80002560:	e7e080e7          	jalr	-386(ra) # 800023da <sleep>
    havekids = 0;
    80002564:	b715                	j	80002488 <wait+0x4a>

0000000080002566 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002566:	7179                	addi	sp,sp,-48
    80002568:	f406                	sd	ra,40(sp)
    8000256a:	f022                	sd	s0,32(sp)
    8000256c:	ec26                	sd	s1,24(sp)
    8000256e:	e84a                	sd	s2,16(sp)
    80002570:	e44e                	sd	s3,8(sp)
    80002572:	e052                	sd	s4,0(sp)
    80002574:	1800                	addi	s0,sp,48
    80002576:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002578:	0000f497          	auipc	s1,0xf
    8000257c:	71848493          	addi	s1,s1,1816 # 80011c90 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002580:	4989                	li	s3,2
  for(p = proc; p < &proc[NPROC]; p++) {
    80002582:	00015917          	auipc	s2,0x15
    80002586:	70e90913          	addi	s2,s2,1806 # 80017c90 <tickslock>
    8000258a:	a811                	j	8000259e <wakeup+0x38>
        // updated: make the process runnable
        make_runnable(p);
      }
      release(&p->lock);
    8000258c:	8526                	mv	a0,s1
    8000258e:	ffffe097          	auipc	ra,0xffffe
    80002592:	6f6080e7          	jalr	1782(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002596:	18048493          	addi	s1,s1,384
    8000259a:	03248963          	beq	s1,s2,800025cc <wakeup+0x66>
    if(p != myproc()){
    8000259e:	fffff097          	auipc	ra,0xfffff
    800025a2:	464080e7          	jalr	1124(ra) # 80001a02 <myproc>
    800025a6:	fea488e3          	beq	s1,a0,80002596 <wakeup+0x30>
      acquire(&p->lock);
    800025aa:	8526                	mv	a0,s1
    800025ac:	ffffe097          	auipc	ra,0xffffe
    800025b0:	624080e7          	jalr	1572(ra) # 80000bd0 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800025b4:	4c9c                	lw	a5,24(s1)
    800025b6:	fd379be3          	bne	a5,s3,8000258c <wakeup+0x26>
    800025ba:	709c                	ld	a5,32(s1)
    800025bc:	fd4798e3          	bne	a5,s4,8000258c <wakeup+0x26>
        make_runnable(p);
    800025c0:	8526                	mv	a0,s1
    800025c2:	fffff097          	auipc	ra,0xfffff
    800025c6:	262080e7          	jalr	610(ra) # 80001824 <make_runnable>
    800025ca:	b7c9                	j	8000258c <wakeup+0x26>
    }
  }
}
    800025cc:	70a2                	ld	ra,40(sp)
    800025ce:	7402                	ld	s0,32(sp)
    800025d0:	64e2                	ld	s1,24(sp)
    800025d2:	6942                	ld	s2,16(sp)
    800025d4:	69a2                	ld	s3,8(sp)
    800025d6:	6a02                	ld	s4,0(sp)
    800025d8:	6145                	addi	sp,sp,48
    800025da:	8082                	ret

00000000800025dc <reparent>:
{
    800025dc:	7179                	addi	sp,sp,-48
    800025de:	f406                	sd	ra,40(sp)
    800025e0:	f022                	sd	s0,32(sp)
    800025e2:	ec26                	sd	s1,24(sp)
    800025e4:	e84a                	sd	s2,16(sp)
    800025e6:	e44e                	sd	s3,8(sp)
    800025e8:	e052                	sd	s4,0(sp)
    800025ea:	1800                	addi	s0,sp,48
    800025ec:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800025ee:	0000f497          	auipc	s1,0xf
    800025f2:	6a248493          	addi	s1,s1,1698 # 80011c90 <proc>
      pp->parent = initproc;
    800025f6:	00006a17          	auipc	s4,0x6
    800025fa:	322a0a13          	addi	s4,s4,802 # 80008918 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800025fe:	00015997          	auipc	s3,0x15
    80002602:	69298993          	addi	s3,s3,1682 # 80017c90 <tickslock>
    80002606:	a029                	j	80002610 <reparent+0x34>
    80002608:	18048493          	addi	s1,s1,384
    8000260c:	01348d63          	beq	s1,s3,80002626 <reparent+0x4a>
    if(pp->parent == p){
    80002610:	7c9c                	ld	a5,56(s1)
    80002612:	ff279be3          	bne	a5,s2,80002608 <reparent+0x2c>
      pp->parent = initproc;
    80002616:	000a3503          	ld	a0,0(s4)
    8000261a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000261c:	00000097          	auipc	ra,0x0
    80002620:	f4a080e7          	jalr	-182(ra) # 80002566 <wakeup>
    80002624:	b7d5                	j	80002608 <reparent+0x2c>
}
    80002626:	70a2                	ld	ra,40(sp)
    80002628:	7402                	ld	s0,32(sp)
    8000262a:	64e2                	ld	s1,24(sp)
    8000262c:	6942                	ld	s2,16(sp)
    8000262e:	69a2                	ld	s3,8(sp)
    80002630:	6a02                	ld	s4,0(sp)
    80002632:	6145                	addi	sp,sp,48
    80002634:	8082                	ret

0000000080002636 <exit>:
{
    80002636:	7179                	addi	sp,sp,-48
    80002638:	f406                	sd	ra,40(sp)
    8000263a:	f022                	sd	s0,32(sp)
    8000263c:	ec26                	sd	s1,24(sp)
    8000263e:	e84a                	sd	s2,16(sp)
    80002640:	e44e                	sd	s3,8(sp)
    80002642:	e052                	sd	s4,0(sp)
    80002644:	1800                	addi	s0,sp,48
    80002646:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002648:	fffff097          	auipc	ra,0xfffff
    8000264c:	3ba080e7          	jalr	954(ra) # 80001a02 <myproc>
    80002650:	89aa                	mv	s3,a0
  if(p == initproc)
    80002652:	00006797          	auipc	a5,0x6
    80002656:	2c67b783          	ld	a5,710(a5) # 80008918 <initproc>
    8000265a:	0d050493          	addi	s1,a0,208
    8000265e:	15050913          	addi	s2,a0,336
    80002662:	02a79363          	bne	a5,a0,80002688 <exit+0x52>
    panic("init exiting");
    80002666:	00006517          	auipc	a0,0x6
    8000266a:	bfa50513          	addi	a0,a0,-1030 # 80008260 <digits+0x220>
    8000266e:	ffffe097          	auipc	ra,0xffffe
    80002672:	eca080e7          	jalr	-310(ra) # 80000538 <panic>
      fileclose(f);
    80002676:	00002097          	auipc	ra,0x2
    8000267a:	190080e7          	jalr	400(ra) # 80004806 <fileclose>
      p->ofile[fd] = 0;
    8000267e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002682:	04a1                	addi	s1,s1,8
    80002684:	01248563          	beq	s1,s2,8000268e <exit+0x58>
    if(p->ofile[fd]){
    80002688:	6088                	ld	a0,0(s1)
    8000268a:	f575                	bnez	a0,80002676 <exit+0x40>
    8000268c:	bfdd                	j	80002682 <exit+0x4c>
  begin_op();
    8000268e:	00002097          	auipc	ra,0x2
    80002692:	cac080e7          	jalr	-852(ra) # 8000433a <begin_op>
  iput(p->cwd);
    80002696:	1509b503          	ld	a0,336(s3)
    8000269a:	00001097          	auipc	ra,0x1
    8000269e:	488080e7          	jalr	1160(ra) # 80003b22 <iput>
  end_op();
    800026a2:	00002097          	auipc	ra,0x2
    800026a6:	d18080e7          	jalr	-744(ra) # 800043ba <end_op>
  p->cwd = 0;
    800026aa:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800026ae:	0000f497          	auipc	s1,0xf
    800026b2:	b8a48493          	addi	s1,s1,-1142 # 80011238 <wait_lock>
    800026b6:	8526                	mv	a0,s1
    800026b8:	ffffe097          	auipc	ra,0xffffe
    800026bc:	518080e7          	jalr	1304(ra) # 80000bd0 <acquire>
  reparent(p);
    800026c0:	854e                	mv	a0,s3
    800026c2:	00000097          	auipc	ra,0x0
    800026c6:	f1a080e7          	jalr	-230(ra) # 800025dc <reparent>
  wakeup(p->parent);
    800026ca:	0389b503          	ld	a0,56(s3)
    800026ce:	00000097          	auipc	ra,0x0
    800026d2:	e98080e7          	jalr	-360(ra) # 80002566 <wakeup>
  acquire(&p->lock);
    800026d6:	854e                	mv	a0,s3
    800026d8:	ffffe097          	auipc	ra,0xffffe
    800026dc:	4f8080e7          	jalr	1272(ra) # 80000bd0 <acquire>
  p->xstate = status;
    800026e0:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800026e4:	4795                	li	a5,5
    800026e6:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800026ea:	8526                	mv	a0,s1
    800026ec:	ffffe097          	auipc	ra,0xffffe
    800026f0:	598080e7          	jalr	1432(ra) # 80000c84 <release>
  sched();
    800026f4:	00000097          	auipc	ra,0x0
    800026f8:	9e0080e7          	jalr	-1568(ra) # 800020d4 <sched>
  panic("zombie exit");
    800026fc:	00006517          	auipc	a0,0x6
    80002700:	b7450513          	addi	a0,a0,-1164 # 80008270 <digits+0x230>
    80002704:	ffffe097          	auipc	ra,0xffffe
    80002708:	e34080e7          	jalr	-460(ra) # 80000538 <panic>

000000008000270c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000270c:	7179                	addi	sp,sp,-48
    8000270e:	f406                	sd	ra,40(sp)
    80002710:	f022                	sd	s0,32(sp)
    80002712:	ec26                	sd	s1,24(sp)
    80002714:	e84a                	sd	s2,16(sp)
    80002716:	e44e                	sd	s3,8(sp)
    80002718:	1800                	addi	s0,sp,48
    8000271a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000271c:	0000f497          	auipc	s1,0xf
    80002720:	57448493          	addi	s1,s1,1396 # 80011c90 <proc>
    80002724:	00015997          	auipc	s3,0x15
    80002728:	56c98993          	addi	s3,s3,1388 # 80017c90 <tickslock>
    acquire(&p->lock);
    8000272c:	8526                	mv	a0,s1
    8000272e:	ffffe097          	auipc	ra,0xffffe
    80002732:	4a2080e7          	jalr	1186(ra) # 80000bd0 <acquire>
    if(p->pid == pid){
    80002736:	589c                	lw	a5,48(s1)
    80002738:	01278d63          	beq	a5,s2,80002752 <kill+0x46>
        make_runnable(p);
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000273c:	8526                	mv	a0,s1
    8000273e:	ffffe097          	auipc	ra,0xffffe
    80002742:	546080e7          	jalr	1350(ra) # 80000c84 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002746:	18048493          	addi	s1,s1,384
    8000274a:	ff3491e3          	bne	s1,s3,8000272c <kill+0x20>
  }
  return -1;
    8000274e:	557d                	li	a0,-1
    80002750:	a829                	j	8000276a <kill+0x5e>
      p->killed = 1;
    80002752:	4785                	li	a5,1
    80002754:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002756:	4c98                	lw	a4,24(s1)
    80002758:	4789                	li	a5,2
    8000275a:	00f70f63          	beq	a4,a5,80002778 <kill+0x6c>
      release(&p->lock);
    8000275e:	8526                	mv	a0,s1
    80002760:	ffffe097          	auipc	ra,0xffffe
    80002764:	524080e7          	jalr	1316(ra) # 80000c84 <release>
      return 0;
    80002768:	4501                	li	a0,0
}
    8000276a:	70a2                	ld	ra,40(sp)
    8000276c:	7402                	ld	s0,32(sp)
    8000276e:	64e2                	ld	s1,24(sp)
    80002770:	6942                	ld	s2,16(sp)
    80002772:	69a2                	ld	s3,8(sp)
    80002774:	6145                	addi	sp,sp,48
    80002776:	8082                	ret
        make_runnable(p);
    80002778:	8526                	mv	a0,s1
    8000277a:	fffff097          	auipc	ra,0xfffff
    8000277e:	0aa080e7          	jalr	170(ra) # 80001824 <make_runnable>
    80002782:	bff1                	j	8000275e <kill+0x52>

0000000080002784 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002784:	7179                	addi	sp,sp,-48
    80002786:	f406                	sd	ra,40(sp)
    80002788:	f022                	sd	s0,32(sp)
    8000278a:	ec26                	sd	s1,24(sp)
    8000278c:	e84a                	sd	s2,16(sp)
    8000278e:	e44e                	sd	s3,8(sp)
    80002790:	e052                	sd	s4,0(sp)
    80002792:	1800                	addi	s0,sp,48
    80002794:	84aa                	mv	s1,a0
    80002796:	892e                	mv	s2,a1
    80002798:	89b2                	mv	s3,a2
    8000279a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000279c:	fffff097          	auipc	ra,0xfffff
    800027a0:	266080e7          	jalr	614(ra) # 80001a02 <myproc>
  if(user_dst){
    800027a4:	c08d                	beqz	s1,800027c6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800027a6:	86d2                	mv	a3,s4
    800027a8:	864e                	mv	a2,s3
    800027aa:	85ca                	mv	a1,s2
    800027ac:	6928                	ld	a0,80(a0)
    800027ae:	fffff097          	auipc	ra,0xfffff
    800027b2:	ea8080e7          	jalr	-344(ra) # 80001656 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800027b6:	70a2                	ld	ra,40(sp)
    800027b8:	7402                	ld	s0,32(sp)
    800027ba:	64e2                	ld	s1,24(sp)
    800027bc:	6942                	ld	s2,16(sp)
    800027be:	69a2                	ld	s3,8(sp)
    800027c0:	6a02                	ld	s4,0(sp)
    800027c2:	6145                	addi	sp,sp,48
    800027c4:	8082                	ret
    memmove((char *)dst, src, len);
    800027c6:	000a061b          	sext.w	a2,s4
    800027ca:	85ce                	mv	a1,s3
    800027cc:	854a                	mv	a0,s2
    800027ce:	ffffe097          	auipc	ra,0xffffe
    800027d2:	55a080e7          	jalr	1370(ra) # 80000d28 <memmove>
    return 0;
    800027d6:	8526                	mv	a0,s1
    800027d8:	bff9                	j	800027b6 <either_copyout+0x32>

00000000800027da <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800027da:	7179                	addi	sp,sp,-48
    800027dc:	f406                	sd	ra,40(sp)
    800027de:	f022                	sd	s0,32(sp)
    800027e0:	ec26                	sd	s1,24(sp)
    800027e2:	e84a                	sd	s2,16(sp)
    800027e4:	e44e                	sd	s3,8(sp)
    800027e6:	e052                	sd	s4,0(sp)
    800027e8:	1800                	addi	s0,sp,48
    800027ea:	892a                	mv	s2,a0
    800027ec:	84ae                	mv	s1,a1
    800027ee:	89b2                	mv	s3,a2
    800027f0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027f2:	fffff097          	auipc	ra,0xfffff
    800027f6:	210080e7          	jalr	528(ra) # 80001a02 <myproc>
  if(user_src){
    800027fa:	c08d                	beqz	s1,8000281c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800027fc:	86d2                	mv	a3,s4
    800027fe:	864e                	mv	a2,s3
    80002800:	85ca                	mv	a1,s2
    80002802:	6928                	ld	a0,80(a0)
    80002804:	fffff097          	auipc	ra,0xfffff
    80002808:	ede080e7          	jalr	-290(ra) # 800016e2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000280c:	70a2                	ld	ra,40(sp)
    8000280e:	7402                	ld	s0,32(sp)
    80002810:	64e2                	ld	s1,24(sp)
    80002812:	6942                	ld	s2,16(sp)
    80002814:	69a2                	ld	s3,8(sp)
    80002816:	6a02                	ld	s4,0(sp)
    80002818:	6145                	addi	sp,sp,48
    8000281a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000281c:	000a061b          	sext.w	a2,s4
    80002820:	85ce                	mv	a1,s3
    80002822:	854a                	mv	a0,s2
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	504080e7          	jalr	1284(ra) # 80000d28 <memmove>
    return 0;
    8000282c:	8526                	mv	a0,s1
    8000282e:	bff9                	j	8000280c <either_copyin+0x32>

0000000080002830 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002830:	715d                	addi	sp,sp,-80
    80002832:	e486                	sd	ra,72(sp)
    80002834:	e0a2                	sd	s0,64(sp)
    80002836:	fc26                	sd	s1,56(sp)
    80002838:	f84a                	sd	s2,48(sp)
    8000283a:	f44e                	sd	s3,40(sp)
    8000283c:	f052                	sd	s4,32(sp)
    8000283e:	ec56                	sd	s5,24(sp)
    80002840:	e85a                	sd	s6,16(sp)
    80002842:	e45e                	sd	s7,8(sp)
    80002844:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002846:	00006517          	auipc	a0,0x6
    8000284a:	88250513          	addi	a0,a0,-1918 # 800080c8 <digits+0x88>
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	d34080e7          	jalr	-716(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002856:	0000f497          	auipc	s1,0xf
    8000285a:	59248493          	addi	s1,s1,1426 # 80011de8 <proc+0x158>
    8000285e:	00015917          	auipc	s2,0x15
    80002862:	58a90913          	addi	s2,s2,1418 # 80017de8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002866:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002868:	00006997          	auipc	s3,0x6
    8000286c:	a1898993          	addi	s3,s3,-1512 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002870:	00006a97          	auipc	s5,0x6
    80002874:	a18a8a93          	addi	s5,s5,-1512 # 80008288 <digits+0x248>
    printf("\n");
    80002878:	00006a17          	auipc	s4,0x6
    8000287c:	850a0a13          	addi	s4,s4,-1968 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002880:	00006b97          	auipc	s7,0x6
    80002884:	a40b8b93          	addi	s7,s7,-1472 # 800082c0 <states.0>
    80002888:	a00d                	j	800028aa <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000288a:	ed86a583          	lw	a1,-296(a3)
    8000288e:	8556                	mv	a0,s5
    80002890:	ffffe097          	auipc	ra,0xffffe
    80002894:	cf2080e7          	jalr	-782(ra) # 80000582 <printf>
    printf("\n");
    80002898:	8552                	mv	a0,s4
    8000289a:	ffffe097          	auipc	ra,0xffffe
    8000289e:	ce8080e7          	jalr	-792(ra) # 80000582 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028a2:	18048493          	addi	s1,s1,384
    800028a6:	03248163          	beq	s1,s2,800028c8 <procdump+0x98>
    if(p->state == UNUSED)
    800028aa:	86a6                	mv	a3,s1
    800028ac:	ec04a783          	lw	a5,-320(s1)
    800028b0:	dbed                	beqz	a5,800028a2 <procdump+0x72>
      state = "???";
    800028b2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028b4:	fcfb6be3          	bltu	s6,a5,8000288a <procdump+0x5a>
    800028b8:	1782                	slli	a5,a5,0x20
    800028ba:	9381                	srli	a5,a5,0x20
    800028bc:	078e                	slli	a5,a5,0x3
    800028be:	97de                	add	a5,a5,s7
    800028c0:	6390                	ld	a2,0(a5)
    800028c2:	f661                	bnez	a2,8000288a <procdump+0x5a>
      state = "???";
    800028c4:	864e                	mv	a2,s3
    800028c6:	b7d1                	j	8000288a <procdump+0x5a>
  }
}
    800028c8:	60a6                	ld	ra,72(sp)
    800028ca:	6406                	ld	s0,64(sp)
    800028cc:	74e2                	ld	s1,56(sp)
    800028ce:	7942                	ld	s2,48(sp)
    800028d0:	79a2                	ld	s3,40(sp)
    800028d2:	7a02                	ld	s4,32(sp)
    800028d4:	6ae2                	ld	s5,24(sp)
    800028d6:	6b42                	ld	s6,16(sp)
    800028d8:	6ba2                	ld	s7,8(sp)
    800028da:	6161                	addi	sp,sp,80
    800028dc:	8082                	ret

00000000800028de <swtch>:
    800028de:	00153023          	sd	ra,0(a0)
    800028e2:	00253423          	sd	sp,8(a0)
    800028e6:	e900                	sd	s0,16(a0)
    800028e8:	ed04                	sd	s1,24(a0)
    800028ea:	03253023          	sd	s2,32(a0)
    800028ee:	03353423          	sd	s3,40(a0)
    800028f2:	03453823          	sd	s4,48(a0)
    800028f6:	03553c23          	sd	s5,56(a0)
    800028fa:	05653023          	sd	s6,64(a0)
    800028fe:	05753423          	sd	s7,72(a0)
    80002902:	05853823          	sd	s8,80(a0)
    80002906:	05953c23          	sd	s9,88(a0)
    8000290a:	07a53023          	sd	s10,96(a0)
    8000290e:	07b53423          	sd	s11,104(a0)
    80002912:	0005b083          	ld	ra,0(a1)
    80002916:	0085b103          	ld	sp,8(a1)
    8000291a:	6980                	ld	s0,16(a1)
    8000291c:	6d84                	ld	s1,24(a1)
    8000291e:	0205b903          	ld	s2,32(a1)
    80002922:	0285b983          	ld	s3,40(a1)
    80002926:	0305ba03          	ld	s4,48(a1)
    8000292a:	0385ba83          	ld	s5,56(a1)
    8000292e:	0405bb03          	ld	s6,64(a1)
    80002932:	0485bb83          	ld	s7,72(a1)
    80002936:	0505bc03          	ld	s8,80(a1)
    8000293a:	0585bc83          	ld	s9,88(a1)
    8000293e:	0605bd03          	ld	s10,96(a1)
    80002942:	0685bd83          	ld	s11,104(a1)
    80002946:	8082                	ret

0000000080002948 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002948:	1141                	addi	sp,sp,-16
    8000294a:	e406                	sd	ra,8(sp)
    8000294c:	e022                	sd	s0,0(sp)
    8000294e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002950:	00006597          	auipc	a1,0x6
    80002954:	9a058593          	addi	a1,a1,-1632 # 800082f0 <states.0+0x30>
    80002958:	00015517          	auipc	a0,0x15
    8000295c:	33850513          	addi	a0,a0,824 # 80017c90 <tickslock>
    80002960:	ffffe097          	auipc	ra,0xffffe
    80002964:	1e0080e7          	jalr	480(ra) # 80000b40 <initlock>
}
    80002968:	60a2                	ld	ra,8(sp)
    8000296a:	6402                	ld	s0,0(sp)
    8000296c:	0141                	addi	sp,sp,16
    8000296e:	8082                	ret

0000000080002970 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002970:	1141                	addi	sp,sp,-16
    80002972:	e422                	sd	s0,8(sp)
    80002974:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002976:	00003797          	auipc	a5,0x3
    8000297a:	4ba78793          	addi	a5,a5,1210 # 80005e30 <kernelvec>
    8000297e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002982:	6422                	ld	s0,8(sp)
    80002984:	0141                	addi	sp,sp,16
    80002986:	8082                	ret

0000000080002988 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002988:	1141                	addi	sp,sp,-16
    8000298a:	e406                	sd	ra,8(sp)
    8000298c:	e022                	sd	s0,0(sp)
    8000298e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002990:	fffff097          	auipc	ra,0xfffff
    80002994:	072080e7          	jalr	114(ra) # 80001a02 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002998:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000299c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000299e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029a2:	00004617          	auipc	a2,0x4
    800029a6:	65e60613          	addi	a2,a2,1630 # 80007000 <_trampoline>
    800029aa:	00004697          	auipc	a3,0x4
    800029ae:	65668693          	addi	a3,a3,1622 # 80007000 <_trampoline>
    800029b2:	8e91                	sub	a3,a3,a2
    800029b4:	040007b7          	lui	a5,0x4000
    800029b8:	17fd                	addi	a5,a5,-1
    800029ba:	07b2                	slli	a5,a5,0xc
    800029bc:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029be:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029c2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029c4:	180026f3          	csrr	a3,satp
    800029c8:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029ca:	6d38                	ld	a4,88(a0)
    800029cc:	6134                	ld	a3,64(a0)
    800029ce:	6585                	lui	a1,0x1
    800029d0:	96ae                	add	a3,a3,a1
    800029d2:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029d4:	6d38                	ld	a4,88(a0)
    800029d6:	00000697          	auipc	a3,0x0
    800029da:	13068693          	addi	a3,a3,304 # 80002b06 <usertrap>
    800029de:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800029e0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029e2:	8692                	mv	a3,tp
    800029e4:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e6:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029ea:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029ee:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029f2:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029f6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029f8:	6f18                	ld	a4,24(a4)
    800029fa:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800029fe:	6928                	ld	a0,80(a0)
    80002a00:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002a02:	00004717          	auipc	a4,0x4
    80002a06:	69670713          	addi	a4,a4,1686 # 80007098 <userret>
    80002a0a:	8f11                	sub	a4,a4,a2
    80002a0c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002a0e:	577d                	li	a4,-1
    80002a10:	177e                	slli	a4,a4,0x3f
    80002a12:	8d59                	or	a0,a0,a4
    80002a14:	9782                	jalr	a5
}
    80002a16:	60a2                	ld	ra,8(sp)
    80002a18:	6402                	ld	s0,0(sp)
    80002a1a:	0141                	addi	sp,sp,16
    80002a1c:	8082                	ret

0000000080002a1e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a1e:	1101                	addi	sp,sp,-32
    80002a20:	ec06                	sd	ra,24(sp)
    80002a22:	e822                	sd	s0,16(sp)
    80002a24:	e426                	sd	s1,8(sp)
    80002a26:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a28:	00015497          	auipc	s1,0x15
    80002a2c:	26848493          	addi	s1,s1,616 # 80017c90 <tickslock>
    80002a30:	8526                	mv	a0,s1
    80002a32:	ffffe097          	auipc	ra,0xffffe
    80002a36:	19e080e7          	jalr	414(ra) # 80000bd0 <acquire>
  ticks++;
    80002a3a:	00006517          	auipc	a0,0x6
    80002a3e:	eea50513          	addi	a0,a0,-278 # 80008924 <ticks>
    80002a42:	411c                	lw	a5,0(a0)
    80002a44:	2785                	addiw	a5,a5,1
    80002a46:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a48:	00000097          	auipc	ra,0x0
    80002a4c:	b1e080e7          	jalr	-1250(ra) # 80002566 <wakeup>
  release(&tickslock);
    80002a50:	8526                	mv	a0,s1
    80002a52:	ffffe097          	auipc	ra,0xffffe
    80002a56:	232080e7          	jalr	562(ra) # 80000c84 <release>
}
    80002a5a:	60e2                	ld	ra,24(sp)
    80002a5c:	6442                	ld	s0,16(sp)
    80002a5e:	64a2                	ld	s1,8(sp)
    80002a60:	6105                	addi	sp,sp,32
    80002a62:	8082                	ret

0000000080002a64 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a64:	1101                	addi	sp,sp,-32
    80002a66:	ec06                	sd	ra,24(sp)
    80002a68:	e822                	sd	s0,16(sp)
    80002a6a:	e426                	sd	s1,8(sp)
    80002a6c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a6e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002a72:	00074d63          	bltz	a4,80002a8c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002a76:	57fd                	li	a5,-1
    80002a78:	17fe                	slli	a5,a5,0x3f
    80002a7a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002a7c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002a7e:	06f70363          	beq	a4,a5,80002ae4 <devintr+0x80>
  }
}
    80002a82:	60e2                	ld	ra,24(sp)
    80002a84:	6442                	ld	s0,16(sp)
    80002a86:	64a2                	ld	s1,8(sp)
    80002a88:	6105                	addi	sp,sp,32
    80002a8a:	8082                	ret
     (scause & 0xff) == 9){
    80002a8c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002a90:	46a5                	li	a3,9
    80002a92:	fed792e3          	bne	a5,a3,80002a76 <devintr+0x12>
    int irq = plic_claim();
    80002a96:	00003097          	auipc	ra,0x3
    80002a9a:	4a2080e7          	jalr	1186(ra) # 80005f38 <plic_claim>
    80002a9e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002aa0:	47a9                	li	a5,10
    80002aa2:	02f50763          	beq	a0,a5,80002ad0 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002aa6:	4785                	li	a5,1
    80002aa8:	02f50963          	beq	a0,a5,80002ada <devintr+0x76>
    return 1;
    80002aac:	4505                	li	a0,1
    } else if(irq){
    80002aae:	d8f1                	beqz	s1,80002a82 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002ab0:	85a6                	mv	a1,s1
    80002ab2:	00006517          	auipc	a0,0x6
    80002ab6:	84650513          	addi	a0,a0,-1978 # 800082f8 <states.0+0x38>
    80002aba:	ffffe097          	auipc	ra,0xffffe
    80002abe:	ac8080e7          	jalr	-1336(ra) # 80000582 <printf>
      plic_complete(irq);
    80002ac2:	8526                	mv	a0,s1
    80002ac4:	00003097          	auipc	ra,0x3
    80002ac8:	498080e7          	jalr	1176(ra) # 80005f5c <plic_complete>
    return 1;
    80002acc:	4505                	li	a0,1
    80002ace:	bf55                	j	80002a82 <devintr+0x1e>
      uartintr();
    80002ad0:	ffffe097          	auipc	ra,0xffffe
    80002ad4:	ec4080e7          	jalr	-316(ra) # 80000994 <uartintr>
    80002ad8:	b7ed                	j	80002ac2 <devintr+0x5e>
      virtio_disk_intr();
    80002ada:	00004097          	auipc	ra,0x4
    80002ade:	94e080e7          	jalr	-1714(ra) # 80006428 <virtio_disk_intr>
    80002ae2:	b7c5                	j	80002ac2 <devintr+0x5e>
    if(cpuid() == 0){
    80002ae4:	fffff097          	auipc	ra,0xfffff
    80002ae8:	ef2080e7          	jalr	-270(ra) # 800019d6 <cpuid>
    80002aec:	c901                	beqz	a0,80002afc <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002aee:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002af2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002af4:	14479073          	csrw	sip,a5
    return 2;
    80002af8:	4509                	li	a0,2
    80002afa:	b761                	j	80002a82 <devintr+0x1e>
      clockintr();
    80002afc:	00000097          	auipc	ra,0x0
    80002b00:	f22080e7          	jalr	-222(ra) # 80002a1e <clockintr>
    80002b04:	b7ed                	j	80002aee <devintr+0x8a>

0000000080002b06 <usertrap>:
{
    80002b06:	1101                	addi	sp,sp,-32
    80002b08:	ec06                	sd	ra,24(sp)
    80002b0a:	e822                	sd	s0,16(sp)
    80002b0c:	e426                	sd	s1,8(sp)
    80002b0e:	e04a                	sd	s2,0(sp)
    80002b10:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b12:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b16:	1007f793          	andi	a5,a5,256
    80002b1a:	e3ad                	bnez	a5,80002b7c <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b1c:	00003797          	auipc	a5,0x3
    80002b20:	31478793          	addi	a5,a5,788 # 80005e30 <kernelvec>
    80002b24:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b28:	fffff097          	auipc	ra,0xfffff
    80002b2c:	eda080e7          	jalr	-294(ra) # 80001a02 <myproc>
    80002b30:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b32:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b34:	14102773          	csrr	a4,sepc
    80002b38:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b3a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b3e:	47a1                	li	a5,8
    80002b40:	04f71c63          	bne	a4,a5,80002b98 <usertrap+0x92>
    if(p->killed)
    80002b44:	551c                	lw	a5,40(a0)
    80002b46:	e3b9                	bnez	a5,80002b8c <usertrap+0x86>
    p->trapframe->epc += 4;
    80002b48:	6cb8                	ld	a4,88(s1)
    80002b4a:	6f1c                	ld	a5,24(a4)
    80002b4c:	0791                	addi	a5,a5,4
    80002b4e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b50:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b54:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b58:	10079073          	csrw	sstatus,a5
    syscall();
    80002b5c:	00000097          	auipc	ra,0x0
    80002b60:	2fc080e7          	jalr	764(ra) # 80002e58 <syscall>
  if(p->killed)
    80002b64:	549c                	lw	a5,40(s1)
    80002b66:	efd9                	bnez	a5,80002c04 <usertrap+0xfe>
  usertrapret();
    80002b68:	00000097          	auipc	ra,0x0
    80002b6c:	e20080e7          	jalr	-480(ra) # 80002988 <usertrapret>
}
    80002b70:	60e2                	ld	ra,24(sp)
    80002b72:	6442                	ld	s0,16(sp)
    80002b74:	64a2                	ld	s1,8(sp)
    80002b76:	6902                	ld	s2,0(sp)
    80002b78:	6105                	addi	sp,sp,32
    80002b7a:	8082                	ret
    panic("usertrap: not from user mode");
    80002b7c:	00005517          	auipc	a0,0x5
    80002b80:	79c50513          	addi	a0,a0,1948 # 80008318 <states.0+0x58>
    80002b84:	ffffe097          	auipc	ra,0xffffe
    80002b88:	9b4080e7          	jalr	-1612(ra) # 80000538 <panic>
      exit(-1);
    80002b8c:	557d                	li	a0,-1
    80002b8e:	00000097          	auipc	ra,0x0
    80002b92:	aa8080e7          	jalr	-1368(ra) # 80002636 <exit>
    80002b96:	bf4d                	j	80002b48 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002b98:	00000097          	auipc	ra,0x0
    80002b9c:	ecc080e7          	jalr	-308(ra) # 80002a64 <devintr>
    80002ba0:	892a                	mv	s2,a0
    80002ba2:	c501                	beqz	a0,80002baa <usertrap+0xa4>
  if(p->killed)
    80002ba4:	549c                	lw	a5,40(s1)
    80002ba6:	c3a1                	beqz	a5,80002be6 <usertrap+0xe0>
    80002ba8:	a815                	j	80002bdc <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002baa:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002bae:	5890                	lw	a2,48(s1)
    80002bb0:	00005517          	auipc	a0,0x5
    80002bb4:	78850513          	addi	a0,a0,1928 # 80008338 <states.0+0x78>
    80002bb8:	ffffe097          	auipc	ra,0xffffe
    80002bbc:	9ca080e7          	jalr	-1590(ra) # 80000582 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bc0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bc4:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bc8:	00005517          	auipc	a0,0x5
    80002bcc:	7a050513          	addi	a0,a0,1952 # 80008368 <states.0+0xa8>
    80002bd0:	ffffe097          	auipc	ra,0xffffe
    80002bd4:	9b2080e7          	jalr	-1614(ra) # 80000582 <printf>
    p->killed = 1;
    80002bd8:	4785                	li	a5,1
    80002bda:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002bdc:	557d                	li	a0,-1
    80002bde:	00000097          	auipc	ra,0x0
    80002be2:	a58080e7          	jalr	-1448(ra) # 80002636 <exit>
  if (which_dev == 2)
    80002be6:	4789                	li	a5,2
    80002be8:	f8f910e3          	bne	s2,a5,80002b68 <usertrap+0x62>
    ++time;
    80002bec:	00006717          	auipc	a4,0x6
    80002bf0:	d3470713          	addi	a4,a4,-716 # 80008920 <time>
    80002bf4:	431c                	lw	a5,0(a4)
    80002bf6:	2785                	addiw	a5,a5,1
    80002bf8:	c31c                	sw	a5,0(a4)
    yield();
    80002bfa:	fffff097          	auipc	ra,0xfffff
    80002bfe:	5b0080e7          	jalr	1456(ra) # 800021aa <yield>
    80002c02:	b79d                	j	80002b68 <usertrap+0x62>
  int which_dev = 0;
    80002c04:	4901                	li	s2,0
    80002c06:	bfd9                	j	80002bdc <usertrap+0xd6>

0000000080002c08 <kerneltrap>:
{
    80002c08:	7179                	addi	sp,sp,-48
    80002c0a:	f406                	sd	ra,40(sp)
    80002c0c:	f022                	sd	s0,32(sp)
    80002c0e:	ec26                	sd	s1,24(sp)
    80002c10:	e84a                	sd	s2,16(sp)
    80002c12:	e44e                	sd	s3,8(sp)
    80002c14:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c16:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c1a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c1e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c22:	1004f793          	andi	a5,s1,256
    80002c26:	cb85                	beqz	a5,80002c56 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c28:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c2c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c2e:	ef85                	bnez	a5,80002c66 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c30:	00000097          	auipc	ra,0x0
    80002c34:	e34080e7          	jalr	-460(ra) # 80002a64 <devintr>
    80002c38:	cd1d                	beqz	a0,80002c76 <kerneltrap+0x6e>
  if (which_dev == 2)
    80002c3a:	4789                	li	a5,2
    80002c3c:	06f50a63          	beq	a0,a5,80002cb0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c40:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c44:	10049073          	csrw	sstatus,s1
}
    80002c48:	70a2                	ld	ra,40(sp)
    80002c4a:	7402                	ld	s0,32(sp)
    80002c4c:	64e2                	ld	s1,24(sp)
    80002c4e:	6942                	ld	s2,16(sp)
    80002c50:	69a2                	ld	s3,8(sp)
    80002c52:	6145                	addi	sp,sp,48
    80002c54:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c56:	00005517          	auipc	a0,0x5
    80002c5a:	73250513          	addi	a0,a0,1842 # 80008388 <states.0+0xc8>
    80002c5e:	ffffe097          	auipc	ra,0xffffe
    80002c62:	8da080e7          	jalr	-1830(ra) # 80000538 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c66:	00005517          	auipc	a0,0x5
    80002c6a:	74a50513          	addi	a0,a0,1866 # 800083b0 <states.0+0xf0>
    80002c6e:	ffffe097          	auipc	ra,0xffffe
    80002c72:	8ca080e7          	jalr	-1846(ra) # 80000538 <panic>
    printf("scause %p\n", scause);
    80002c76:	85ce                	mv	a1,s3
    80002c78:	00005517          	auipc	a0,0x5
    80002c7c:	75850513          	addi	a0,a0,1880 # 800083d0 <states.0+0x110>
    80002c80:	ffffe097          	auipc	ra,0xffffe
    80002c84:	902080e7          	jalr	-1790(ra) # 80000582 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c88:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c8c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c90:	00005517          	auipc	a0,0x5
    80002c94:	75050513          	addi	a0,a0,1872 # 800083e0 <states.0+0x120>
    80002c98:	ffffe097          	auipc	ra,0xffffe
    80002c9c:	8ea080e7          	jalr	-1814(ra) # 80000582 <printf>
    panic("kerneltrap");
    80002ca0:	00005517          	auipc	a0,0x5
    80002ca4:	75850513          	addi	a0,a0,1880 # 800083f8 <states.0+0x138>
    80002ca8:	ffffe097          	auipc	ra,0xffffe
    80002cac:	890080e7          	jalr	-1904(ra) # 80000538 <panic>
    ++time;
    80002cb0:	00006717          	auipc	a4,0x6
    80002cb4:	c7070713          	addi	a4,a4,-912 # 80008920 <time>
    80002cb8:	431c                	lw	a5,0(a4)
    80002cba:	2785                	addiw	a5,a5,1
    80002cbc:	c31c                	sw	a5,0(a4)
    if (myproc() != 0 && myproc()->state == RUNNING)
    80002cbe:	fffff097          	auipc	ra,0xfffff
    80002cc2:	d44080e7          	jalr	-700(ra) # 80001a02 <myproc>
    80002cc6:	dd2d                	beqz	a0,80002c40 <kerneltrap+0x38>
    80002cc8:	fffff097          	auipc	ra,0xfffff
    80002ccc:	d3a080e7          	jalr	-710(ra) # 80001a02 <myproc>
    80002cd0:	4d18                	lw	a4,24(a0)
    80002cd2:	4791                	li	a5,4
    80002cd4:	f6f716e3          	bne	a4,a5,80002c40 <kerneltrap+0x38>
      yield();
    80002cd8:	fffff097          	auipc	ra,0xfffff
    80002cdc:	4d2080e7          	jalr	1234(ra) # 800021aa <yield>
    80002ce0:	b785                	j	80002c40 <kerneltrap+0x38>

0000000080002ce2 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ce2:	1101                	addi	sp,sp,-32
    80002ce4:	ec06                	sd	ra,24(sp)
    80002ce6:	e822                	sd	s0,16(sp)
    80002ce8:	e426                	sd	s1,8(sp)
    80002cea:	1000                	addi	s0,sp,32
    80002cec:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	d14080e7          	jalr	-748(ra) # 80001a02 <myproc>
  switch (n) {
    80002cf6:	4795                	li	a5,5
    80002cf8:	0497e163          	bltu	a5,s1,80002d3a <argraw+0x58>
    80002cfc:	048a                	slli	s1,s1,0x2
    80002cfe:	00005717          	auipc	a4,0x5
    80002d02:	73270713          	addi	a4,a4,1842 # 80008430 <states.0+0x170>
    80002d06:	94ba                	add	s1,s1,a4
    80002d08:	409c                	lw	a5,0(s1)
    80002d0a:	97ba                	add	a5,a5,a4
    80002d0c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d0e:	6d3c                	ld	a5,88(a0)
    80002d10:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d12:	60e2                	ld	ra,24(sp)
    80002d14:	6442                	ld	s0,16(sp)
    80002d16:	64a2                	ld	s1,8(sp)
    80002d18:	6105                	addi	sp,sp,32
    80002d1a:	8082                	ret
    return p->trapframe->a1;
    80002d1c:	6d3c                	ld	a5,88(a0)
    80002d1e:	7fa8                	ld	a0,120(a5)
    80002d20:	bfcd                	j	80002d12 <argraw+0x30>
    return p->trapframe->a2;
    80002d22:	6d3c                	ld	a5,88(a0)
    80002d24:	63c8                	ld	a0,128(a5)
    80002d26:	b7f5                	j	80002d12 <argraw+0x30>
    return p->trapframe->a3;
    80002d28:	6d3c                	ld	a5,88(a0)
    80002d2a:	67c8                	ld	a0,136(a5)
    80002d2c:	b7dd                	j	80002d12 <argraw+0x30>
    return p->trapframe->a4;
    80002d2e:	6d3c                	ld	a5,88(a0)
    80002d30:	6bc8                	ld	a0,144(a5)
    80002d32:	b7c5                	j	80002d12 <argraw+0x30>
    return p->trapframe->a5;
    80002d34:	6d3c                	ld	a5,88(a0)
    80002d36:	6fc8                	ld	a0,152(a5)
    80002d38:	bfe9                	j	80002d12 <argraw+0x30>
  panic("argraw");
    80002d3a:	00005517          	auipc	a0,0x5
    80002d3e:	6ce50513          	addi	a0,a0,1742 # 80008408 <states.0+0x148>
    80002d42:	ffffd097          	auipc	ra,0xffffd
    80002d46:	7f6080e7          	jalr	2038(ra) # 80000538 <panic>

0000000080002d4a <fetchaddr>:
{
    80002d4a:	1101                	addi	sp,sp,-32
    80002d4c:	ec06                	sd	ra,24(sp)
    80002d4e:	e822                	sd	s0,16(sp)
    80002d50:	e426                	sd	s1,8(sp)
    80002d52:	e04a                	sd	s2,0(sp)
    80002d54:	1000                	addi	s0,sp,32
    80002d56:	84aa                	mv	s1,a0
    80002d58:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d5a:	fffff097          	auipc	ra,0xfffff
    80002d5e:	ca8080e7          	jalr	-856(ra) # 80001a02 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002d62:	653c                	ld	a5,72(a0)
    80002d64:	02f4f863          	bgeu	s1,a5,80002d94 <fetchaddr+0x4a>
    80002d68:	00848713          	addi	a4,s1,8
    80002d6c:	02e7e663          	bltu	a5,a4,80002d98 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d70:	46a1                	li	a3,8
    80002d72:	8626                	mv	a2,s1
    80002d74:	85ca                	mv	a1,s2
    80002d76:	6928                	ld	a0,80(a0)
    80002d78:	fffff097          	auipc	ra,0xfffff
    80002d7c:	96a080e7          	jalr	-1686(ra) # 800016e2 <copyin>
    80002d80:	00a03533          	snez	a0,a0
    80002d84:	40a00533          	neg	a0,a0
}
    80002d88:	60e2                	ld	ra,24(sp)
    80002d8a:	6442                	ld	s0,16(sp)
    80002d8c:	64a2                	ld	s1,8(sp)
    80002d8e:	6902                	ld	s2,0(sp)
    80002d90:	6105                	addi	sp,sp,32
    80002d92:	8082                	ret
    return -1;
    80002d94:	557d                	li	a0,-1
    80002d96:	bfcd                	j	80002d88 <fetchaddr+0x3e>
    80002d98:	557d                	li	a0,-1
    80002d9a:	b7fd                	j	80002d88 <fetchaddr+0x3e>

0000000080002d9c <fetchstr>:
{
    80002d9c:	7179                	addi	sp,sp,-48
    80002d9e:	f406                	sd	ra,40(sp)
    80002da0:	f022                	sd	s0,32(sp)
    80002da2:	ec26                	sd	s1,24(sp)
    80002da4:	e84a                	sd	s2,16(sp)
    80002da6:	e44e                	sd	s3,8(sp)
    80002da8:	1800                	addi	s0,sp,48
    80002daa:	892a                	mv	s2,a0
    80002dac:	84ae                	mv	s1,a1
    80002dae:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002db0:	fffff097          	auipc	ra,0xfffff
    80002db4:	c52080e7          	jalr	-942(ra) # 80001a02 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002db8:	86ce                	mv	a3,s3
    80002dba:	864a                	mv	a2,s2
    80002dbc:	85a6                	mv	a1,s1
    80002dbe:	6928                	ld	a0,80(a0)
    80002dc0:	fffff097          	auipc	ra,0xfffff
    80002dc4:	9b0080e7          	jalr	-1616(ra) # 80001770 <copyinstr>
  if(err < 0)
    80002dc8:	00054763          	bltz	a0,80002dd6 <fetchstr+0x3a>
  return strlen(buf);
    80002dcc:	8526                	mv	a0,s1
    80002dce:	ffffe097          	auipc	ra,0xffffe
    80002dd2:	07a080e7          	jalr	122(ra) # 80000e48 <strlen>
}
    80002dd6:	70a2                	ld	ra,40(sp)
    80002dd8:	7402                	ld	s0,32(sp)
    80002dda:	64e2                	ld	s1,24(sp)
    80002ddc:	6942                	ld	s2,16(sp)
    80002dde:	69a2                	ld	s3,8(sp)
    80002de0:	6145                	addi	sp,sp,48
    80002de2:	8082                	ret

0000000080002de4 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002de4:	1101                	addi	sp,sp,-32
    80002de6:	ec06                	sd	ra,24(sp)
    80002de8:	e822                	sd	s0,16(sp)
    80002dea:	e426                	sd	s1,8(sp)
    80002dec:	1000                	addi	s0,sp,32
    80002dee:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002df0:	00000097          	auipc	ra,0x0
    80002df4:	ef2080e7          	jalr	-270(ra) # 80002ce2 <argraw>
    80002df8:	c088                	sw	a0,0(s1)
  return 0;
}
    80002dfa:	4501                	li	a0,0
    80002dfc:	60e2                	ld	ra,24(sp)
    80002dfe:	6442                	ld	s0,16(sp)
    80002e00:	64a2                	ld	s1,8(sp)
    80002e02:	6105                	addi	sp,sp,32
    80002e04:	8082                	ret

0000000080002e06 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e06:	1101                	addi	sp,sp,-32
    80002e08:	ec06                	sd	ra,24(sp)
    80002e0a:	e822                	sd	s0,16(sp)
    80002e0c:	e426                	sd	s1,8(sp)
    80002e0e:	1000                	addi	s0,sp,32
    80002e10:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e12:	00000097          	auipc	ra,0x0
    80002e16:	ed0080e7          	jalr	-304(ra) # 80002ce2 <argraw>
    80002e1a:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e1c:	4501                	li	a0,0
    80002e1e:	60e2                	ld	ra,24(sp)
    80002e20:	6442                	ld	s0,16(sp)
    80002e22:	64a2                	ld	s1,8(sp)
    80002e24:	6105                	addi	sp,sp,32
    80002e26:	8082                	ret

0000000080002e28 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e28:	1101                	addi	sp,sp,-32
    80002e2a:	ec06                	sd	ra,24(sp)
    80002e2c:	e822                	sd	s0,16(sp)
    80002e2e:	e426                	sd	s1,8(sp)
    80002e30:	e04a                	sd	s2,0(sp)
    80002e32:	1000                	addi	s0,sp,32
    80002e34:	84ae                	mv	s1,a1
    80002e36:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002e38:	00000097          	auipc	ra,0x0
    80002e3c:	eaa080e7          	jalr	-342(ra) # 80002ce2 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002e40:	864a                	mv	a2,s2
    80002e42:	85a6                	mv	a1,s1
    80002e44:	00000097          	auipc	ra,0x0
    80002e48:	f58080e7          	jalr	-168(ra) # 80002d9c <fetchstr>
}
    80002e4c:	60e2                	ld	ra,24(sp)
    80002e4e:	6442                	ld	s0,16(sp)
    80002e50:	64a2                	ld	s1,8(sp)
    80002e52:	6902                	ld	s2,0(sp)
    80002e54:	6105                	addi	sp,sp,32
    80002e56:	8082                	ret

0000000080002e58 <syscall>:
[SYS_nice]    sys_nice,
};

void
syscall(void)
{
    80002e58:	1101                	addi	sp,sp,-32
    80002e5a:	ec06                	sd	ra,24(sp)
    80002e5c:	e822                	sd	s0,16(sp)
    80002e5e:	e426                	sd	s1,8(sp)
    80002e60:	e04a                	sd	s2,0(sp)
    80002e62:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e64:	fffff097          	auipc	ra,0xfffff
    80002e68:	b9e080e7          	jalr	-1122(ra) # 80001a02 <myproc>
    80002e6c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e6e:	05853903          	ld	s2,88(a0)
    80002e72:	0a893783          	ld	a5,168(s2)
    80002e76:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e7a:	37fd                	addiw	a5,a5,-1
    80002e7c:	475d                	li	a4,23
    80002e7e:	00f76f63          	bltu	a4,a5,80002e9c <syscall+0x44>
    80002e82:	00369713          	slli	a4,a3,0x3
    80002e86:	00005797          	auipc	a5,0x5
    80002e8a:	5c278793          	addi	a5,a5,1474 # 80008448 <syscalls>
    80002e8e:	97ba                	add	a5,a5,a4
    80002e90:	639c                	ld	a5,0(a5)
    80002e92:	c789                	beqz	a5,80002e9c <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002e94:	9782                	jalr	a5
    80002e96:	06a93823          	sd	a0,112(s2)
    80002e9a:	a839                	j	80002eb8 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e9c:	15848613          	addi	a2,s1,344
    80002ea0:	588c                	lw	a1,48(s1)
    80002ea2:	00005517          	auipc	a0,0x5
    80002ea6:	56e50513          	addi	a0,a0,1390 # 80008410 <states.0+0x150>
    80002eaa:	ffffd097          	auipc	ra,0xffffd
    80002eae:	6d8080e7          	jalr	1752(ra) # 80000582 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002eb2:	6cbc                	ld	a5,88(s1)
    80002eb4:	577d                	li	a4,-1
    80002eb6:	fbb8                	sd	a4,112(a5)
  }
}
    80002eb8:	60e2                	ld	ra,24(sp)
    80002eba:	6442                	ld	s0,16(sp)
    80002ebc:	64a2                	ld	s1,8(sp)
    80002ebe:	6902                	ld	s2,0(sp)
    80002ec0:	6105                	addi	sp,sp,32
    80002ec2:	8082                	ret

0000000080002ec4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ec4:	1101                	addi	sp,sp,-32
    80002ec6:	ec06                	sd	ra,24(sp)
    80002ec8:	e822                	sd	s0,16(sp)
    80002eca:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002ecc:	fec40593          	addi	a1,s0,-20
    80002ed0:	4501                	li	a0,0
    80002ed2:	00000097          	auipc	ra,0x0
    80002ed6:	f12080e7          	jalr	-238(ra) # 80002de4 <argint>
    return -1;
    80002eda:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002edc:	00054963          	bltz	a0,80002eee <sys_exit+0x2a>
  exit(n);
    80002ee0:	fec42503          	lw	a0,-20(s0)
    80002ee4:	fffff097          	auipc	ra,0xfffff
    80002ee8:	752080e7          	jalr	1874(ra) # 80002636 <exit>
  return 0;  // not reached
    80002eec:	4781                	li	a5,0
}
    80002eee:	853e                	mv	a0,a5
    80002ef0:	60e2                	ld	ra,24(sp)
    80002ef2:	6442                	ld	s0,16(sp)
    80002ef4:	6105                	addi	sp,sp,32
    80002ef6:	8082                	ret

0000000080002ef8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ef8:	1141                	addi	sp,sp,-16
    80002efa:	e406                	sd	ra,8(sp)
    80002efc:	e022                	sd	s0,0(sp)
    80002efe:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f00:	fffff097          	auipc	ra,0xfffff
    80002f04:	b02080e7          	jalr	-1278(ra) # 80001a02 <myproc>
}
    80002f08:	5908                	lw	a0,48(a0)
    80002f0a:	60a2                	ld	ra,8(sp)
    80002f0c:	6402                	ld	s0,0(sp)
    80002f0e:	0141                	addi	sp,sp,16
    80002f10:	8082                	ret

0000000080002f12 <sys_fork>:

uint64
sys_fork(void)
{
    80002f12:	1141                	addi	sp,sp,-16
    80002f14:	e406                	sd	ra,8(sp)
    80002f16:	e022                	sd	s0,0(sp)
    80002f18:	0800                	addi	s0,sp,16
  return fork();
    80002f1a:	fffff097          	auipc	ra,0xfffff
    80002f1e:	f44080e7          	jalr	-188(ra) # 80001e5e <fork>
}
    80002f22:	60a2                	ld	ra,8(sp)
    80002f24:	6402                	ld	s0,0(sp)
    80002f26:	0141                	addi	sp,sp,16
    80002f28:	8082                	ret

0000000080002f2a <sys_wait>:

uint64
sys_wait(void)
{
    80002f2a:	1101                	addi	sp,sp,-32
    80002f2c:	ec06                	sd	ra,24(sp)
    80002f2e:	e822                	sd	s0,16(sp)
    80002f30:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002f32:	fe840593          	addi	a1,s0,-24
    80002f36:	4501                	li	a0,0
    80002f38:	00000097          	auipc	ra,0x0
    80002f3c:	ece080e7          	jalr	-306(ra) # 80002e06 <argaddr>
    80002f40:	87aa                	mv	a5,a0
    return -1;
    80002f42:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002f44:	0007c863          	bltz	a5,80002f54 <sys_wait+0x2a>
  return wait(p);
    80002f48:	fe843503          	ld	a0,-24(s0)
    80002f4c:	fffff097          	auipc	ra,0xfffff
    80002f50:	4f2080e7          	jalr	1266(ra) # 8000243e <wait>
}
    80002f54:	60e2                	ld	ra,24(sp)
    80002f56:	6442                	ld	s0,16(sp)
    80002f58:	6105                	addi	sp,sp,32
    80002f5a:	8082                	ret

0000000080002f5c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f5c:	7179                	addi	sp,sp,-48
    80002f5e:	f406                	sd	ra,40(sp)
    80002f60:	f022                	sd	s0,32(sp)
    80002f62:	ec26                	sd	s1,24(sp)
    80002f64:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002f66:	fdc40593          	addi	a1,s0,-36
    80002f6a:	4501                	li	a0,0
    80002f6c:	00000097          	auipc	ra,0x0
    80002f70:	e78080e7          	jalr	-392(ra) # 80002de4 <argint>
    return -1;
    80002f74:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002f76:	00054f63          	bltz	a0,80002f94 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002f7a:	fffff097          	auipc	ra,0xfffff
    80002f7e:	a88080e7          	jalr	-1400(ra) # 80001a02 <myproc>
    80002f82:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002f84:	fdc42503          	lw	a0,-36(s0)
    80002f88:	fffff097          	auipc	ra,0xfffff
    80002f8c:	e62080e7          	jalr	-414(ra) # 80001dea <growproc>
    80002f90:	00054863          	bltz	a0,80002fa0 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002f94:	8526                	mv	a0,s1
    80002f96:	70a2                	ld	ra,40(sp)
    80002f98:	7402                	ld	s0,32(sp)
    80002f9a:	64e2                	ld	s1,24(sp)
    80002f9c:	6145                	addi	sp,sp,48
    80002f9e:	8082                	ret
    return -1;
    80002fa0:	54fd                	li	s1,-1
    80002fa2:	bfcd                	j	80002f94 <sys_sbrk+0x38>

0000000080002fa4 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002fa4:	7139                	addi	sp,sp,-64
    80002fa6:	fc06                	sd	ra,56(sp)
    80002fa8:	f822                	sd	s0,48(sp)
    80002faa:	f426                	sd	s1,40(sp)
    80002fac:	f04a                	sd	s2,32(sp)
    80002fae:	ec4e                	sd	s3,24(sp)
    80002fb0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002fb2:	fcc40593          	addi	a1,s0,-52
    80002fb6:	4501                	li	a0,0
    80002fb8:	00000097          	auipc	ra,0x0
    80002fbc:	e2c080e7          	jalr	-468(ra) # 80002de4 <argint>
    return -1;
    80002fc0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002fc2:	06054563          	bltz	a0,8000302c <sys_sleep+0x88>
  acquire(&tickslock);
    80002fc6:	00015517          	auipc	a0,0x15
    80002fca:	cca50513          	addi	a0,a0,-822 # 80017c90 <tickslock>
    80002fce:	ffffe097          	auipc	ra,0xffffe
    80002fd2:	c02080e7          	jalr	-1022(ra) # 80000bd0 <acquire>
  ticks0 = ticks;
    80002fd6:	00006917          	auipc	s2,0x6
    80002fda:	94e92903          	lw	s2,-1714(s2) # 80008924 <ticks>
  while(ticks - ticks0 < n){
    80002fde:	fcc42783          	lw	a5,-52(s0)
    80002fe2:	cf85                	beqz	a5,8000301a <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002fe4:	00015997          	auipc	s3,0x15
    80002fe8:	cac98993          	addi	s3,s3,-852 # 80017c90 <tickslock>
    80002fec:	00006497          	auipc	s1,0x6
    80002ff0:	93848493          	addi	s1,s1,-1736 # 80008924 <ticks>
    if(myproc()->killed){
    80002ff4:	fffff097          	auipc	ra,0xfffff
    80002ff8:	a0e080e7          	jalr	-1522(ra) # 80001a02 <myproc>
    80002ffc:	551c                	lw	a5,40(a0)
    80002ffe:	ef9d                	bnez	a5,8000303c <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003000:	85ce                	mv	a1,s3
    80003002:	8526                	mv	a0,s1
    80003004:	fffff097          	auipc	ra,0xfffff
    80003008:	3d6080e7          	jalr	982(ra) # 800023da <sleep>
  while(ticks - ticks0 < n){
    8000300c:	409c                	lw	a5,0(s1)
    8000300e:	412787bb          	subw	a5,a5,s2
    80003012:	fcc42703          	lw	a4,-52(s0)
    80003016:	fce7efe3          	bltu	a5,a4,80002ff4 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000301a:	00015517          	auipc	a0,0x15
    8000301e:	c7650513          	addi	a0,a0,-906 # 80017c90 <tickslock>
    80003022:	ffffe097          	auipc	ra,0xffffe
    80003026:	c62080e7          	jalr	-926(ra) # 80000c84 <release>
  return 0;
    8000302a:	4781                	li	a5,0
}
    8000302c:	853e                	mv	a0,a5
    8000302e:	70e2                	ld	ra,56(sp)
    80003030:	7442                	ld	s0,48(sp)
    80003032:	74a2                	ld	s1,40(sp)
    80003034:	7902                	ld	s2,32(sp)
    80003036:	69e2                	ld	s3,24(sp)
    80003038:	6121                	addi	sp,sp,64
    8000303a:	8082                	ret
      release(&tickslock);
    8000303c:	00015517          	auipc	a0,0x15
    80003040:	c5450513          	addi	a0,a0,-940 # 80017c90 <tickslock>
    80003044:	ffffe097          	auipc	ra,0xffffe
    80003048:	c40080e7          	jalr	-960(ra) # 80000c84 <release>
      return -1;
    8000304c:	57fd                	li	a5,-1
    8000304e:	bff9                	j	8000302c <sys_sleep+0x88>

0000000080003050 <sys_kill>:

uint64
sys_kill(void)
{
    80003050:	1101                	addi	sp,sp,-32
    80003052:	ec06                	sd	ra,24(sp)
    80003054:	e822                	sd	s0,16(sp)
    80003056:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80003058:	fec40593          	addi	a1,s0,-20
    8000305c:	4501                	li	a0,0
    8000305e:	00000097          	auipc	ra,0x0
    80003062:	d86080e7          	jalr	-634(ra) # 80002de4 <argint>
    80003066:	87aa                	mv	a5,a0
    return -1;
    80003068:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    8000306a:	0007c863          	bltz	a5,8000307a <sys_kill+0x2a>
  return kill(pid);
    8000306e:	fec42503          	lw	a0,-20(s0)
    80003072:	fffff097          	auipc	ra,0xfffff
    80003076:	69a080e7          	jalr	1690(ra) # 8000270c <kill>
}
    8000307a:	60e2                	ld	ra,24(sp)
    8000307c:	6442                	ld	s0,16(sp)
    8000307e:	6105                	addi	sp,sp,32
    80003080:	8082                	ret

0000000080003082 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003082:	1101                	addi	sp,sp,-32
    80003084:	ec06                	sd	ra,24(sp)
    80003086:	e822                	sd	s0,16(sp)
    80003088:	e426                	sd	s1,8(sp)
    8000308a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000308c:	00015517          	auipc	a0,0x15
    80003090:	c0450513          	addi	a0,a0,-1020 # 80017c90 <tickslock>
    80003094:	ffffe097          	auipc	ra,0xffffe
    80003098:	b3c080e7          	jalr	-1220(ra) # 80000bd0 <acquire>
  xticks = ticks;
    8000309c:	00006497          	auipc	s1,0x6
    800030a0:	8884a483          	lw	s1,-1912(s1) # 80008924 <ticks>
  release(&tickslock);
    800030a4:	00015517          	auipc	a0,0x15
    800030a8:	bec50513          	addi	a0,a0,-1044 # 80017c90 <tickslock>
    800030ac:	ffffe097          	auipc	ra,0xffffe
    800030b0:	bd8080e7          	jalr	-1064(ra) # 80000c84 <release>
  return xticks;
}
    800030b4:	02049513          	slli	a0,s1,0x20
    800030b8:	9101                	srli	a0,a0,0x20
    800030ba:	60e2                	ld	ra,24(sp)
    800030bc:	6442                	ld	s0,16(sp)
    800030be:	64a2                	ld	s1,8(sp)
    800030c0:	6105                	addi	sp,sp,32
    800030c2:	8082                	ret

00000000800030c4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030c4:	7179                	addi	sp,sp,-48
    800030c6:	f406                	sd	ra,40(sp)
    800030c8:	f022                	sd	s0,32(sp)
    800030ca:	ec26                	sd	s1,24(sp)
    800030cc:	e84a                	sd	s2,16(sp)
    800030ce:	e44e                	sd	s3,8(sp)
    800030d0:	e052                	sd	s4,0(sp)
    800030d2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030d4:	00005597          	auipc	a1,0x5
    800030d8:	43c58593          	addi	a1,a1,1084 # 80008510 <syscalls+0xc8>
    800030dc:	00015517          	auipc	a0,0x15
    800030e0:	bcc50513          	addi	a0,a0,-1076 # 80017ca8 <bcache>
    800030e4:	ffffe097          	auipc	ra,0xffffe
    800030e8:	a5c080e7          	jalr	-1444(ra) # 80000b40 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030ec:	0001d797          	auipc	a5,0x1d
    800030f0:	bbc78793          	addi	a5,a5,-1092 # 8001fca8 <bcache+0x8000>
    800030f4:	0001d717          	auipc	a4,0x1d
    800030f8:	e1c70713          	addi	a4,a4,-484 # 8001ff10 <bcache+0x8268>
    800030fc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003100:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003104:	00015497          	auipc	s1,0x15
    80003108:	bbc48493          	addi	s1,s1,-1092 # 80017cc0 <bcache+0x18>
    b->next = bcache.head.next;
    8000310c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000310e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003110:	00005a17          	auipc	s4,0x5
    80003114:	408a0a13          	addi	s4,s4,1032 # 80008518 <syscalls+0xd0>
    b->next = bcache.head.next;
    80003118:	2b893783          	ld	a5,696(s2)
    8000311c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000311e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003122:	85d2                	mv	a1,s4
    80003124:	01048513          	addi	a0,s1,16
    80003128:	00001097          	auipc	ra,0x1
    8000312c:	4d0080e7          	jalr	1232(ra) # 800045f8 <initsleeplock>
    bcache.head.next->prev = b;
    80003130:	2b893783          	ld	a5,696(s2)
    80003134:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003136:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000313a:	45848493          	addi	s1,s1,1112
    8000313e:	fd349de3          	bne	s1,s3,80003118 <binit+0x54>
  }
}
    80003142:	70a2                	ld	ra,40(sp)
    80003144:	7402                	ld	s0,32(sp)
    80003146:	64e2                	ld	s1,24(sp)
    80003148:	6942                	ld	s2,16(sp)
    8000314a:	69a2                	ld	s3,8(sp)
    8000314c:	6a02                	ld	s4,0(sp)
    8000314e:	6145                	addi	sp,sp,48
    80003150:	8082                	ret

0000000080003152 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003152:	7179                	addi	sp,sp,-48
    80003154:	f406                	sd	ra,40(sp)
    80003156:	f022                	sd	s0,32(sp)
    80003158:	ec26                	sd	s1,24(sp)
    8000315a:	e84a                	sd	s2,16(sp)
    8000315c:	e44e                	sd	s3,8(sp)
    8000315e:	1800                	addi	s0,sp,48
    80003160:	892a                	mv	s2,a0
    80003162:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003164:	00015517          	auipc	a0,0x15
    80003168:	b4450513          	addi	a0,a0,-1212 # 80017ca8 <bcache>
    8000316c:	ffffe097          	auipc	ra,0xffffe
    80003170:	a64080e7          	jalr	-1436(ra) # 80000bd0 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003174:	0001d497          	auipc	s1,0x1d
    80003178:	dec4b483          	ld	s1,-532(s1) # 8001ff60 <bcache+0x82b8>
    8000317c:	0001d797          	auipc	a5,0x1d
    80003180:	d9478793          	addi	a5,a5,-620 # 8001ff10 <bcache+0x8268>
    80003184:	02f48f63          	beq	s1,a5,800031c2 <bread+0x70>
    80003188:	873e                	mv	a4,a5
    8000318a:	a021                	j	80003192 <bread+0x40>
    8000318c:	68a4                	ld	s1,80(s1)
    8000318e:	02e48a63          	beq	s1,a4,800031c2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003192:	449c                	lw	a5,8(s1)
    80003194:	ff279ce3          	bne	a5,s2,8000318c <bread+0x3a>
    80003198:	44dc                	lw	a5,12(s1)
    8000319a:	ff3799e3          	bne	a5,s3,8000318c <bread+0x3a>
      b->refcnt++;
    8000319e:	40bc                	lw	a5,64(s1)
    800031a0:	2785                	addiw	a5,a5,1
    800031a2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031a4:	00015517          	auipc	a0,0x15
    800031a8:	b0450513          	addi	a0,a0,-1276 # 80017ca8 <bcache>
    800031ac:	ffffe097          	auipc	ra,0xffffe
    800031b0:	ad8080e7          	jalr	-1320(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    800031b4:	01048513          	addi	a0,s1,16
    800031b8:	00001097          	auipc	ra,0x1
    800031bc:	47a080e7          	jalr	1146(ra) # 80004632 <acquiresleep>
      return b;
    800031c0:	a8b9                	j	8000321e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031c2:	0001d497          	auipc	s1,0x1d
    800031c6:	d964b483          	ld	s1,-618(s1) # 8001ff58 <bcache+0x82b0>
    800031ca:	0001d797          	auipc	a5,0x1d
    800031ce:	d4678793          	addi	a5,a5,-698 # 8001ff10 <bcache+0x8268>
    800031d2:	00f48863          	beq	s1,a5,800031e2 <bread+0x90>
    800031d6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031d8:	40bc                	lw	a5,64(s1)
    800031da:	cf81                	beqz	a5,800031f2 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031dc:	64a4                	ld	s1,72(s1)
    800031de:	fee49de3          	bne	s1,a4,800031d8 <bread+0x86>
  panic("bget: no buffers");
    800031e2:	00005517          	auipc	a0,0x5
    800031e6:	33e50513          	addi	a0,a0,830 # 80008520 <syscalls+0xd8>
    800031ea:	ffffd097          	auipc	ra,0xffffd
    800031ee:	34e080e7          	jalr	846(ra) # 80000538 <panic>
      b->dev = dev;
    800031f2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031f6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031fa:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031fe:	4785                	li	a5,1
    80003200:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003202:	00015517          	auipc	a0,0x15
    80003206:	aa650513          	addi	a0,a0,-1370 # 80017ca8 <bcache>
    8000320a:	ffffe097          	auipc	ra,0xffffe
    8000320e:	a7a080e7          	jalr	-1414(ra) # 80000c84 <release>
      acquiresleep(&b->lock);
    80003212:	01048513          	addi	a0,s1,16
    80003216:	00001097          	auipc	ra,0x1
    8000321a:	41c080e7          	jalr	1052(ra) # 80004632 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000321e:	409c                	lw	a5,0(s1)
    80003220:	cb89                	beqz	a5,80003232 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003222:	8526                	mv	a0,s1
    80003224:	70a2                	ld	ra,40(sp)
    80003226:	7402                	ld	s0,32(sp)
    80003228:	64e2                	ld	s1,24(sp)
    8000322a:	6942                	ld	s2,16(sp)
    8000322c:	69a2                	ld	s3,8(sp)
    8000322e:	6145                	addi	sp,sp,48
    80003230:	8082                	ret
    virtio_disk_rw(b, 0);
    80003232:	4581                	li	a1,0
    80003234:	8526                	mv	a0,s1
    80003236:	00003097          	auipc	ra,0x3
    8000323a:	fbe080e7          	jalr	-66(ra) # 800061f4 <virtio_disk_rw>
    b->valid = 1;
    8000323e:	4785                	li	a5,1
    80003240:	c09c                	sw	a5,0(s1)
  return b;
    80003242:	b7c5                	j	80003222 <bread+0xd0>

0000000080003244 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003244:	1101                	addi	sp,sp,-32
    80003246:	ec06                	sd	ra,24(sp)
    80003248:	e822                	sd	s0,16(sp)
    8000324a:	e426                	sd	s1,8(sp)
    8000324c:	1000                	addi	s0,sp,32
    8000324e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003250:	0541                	addi	a0,a0,16
    80003252:	00001097          	auipc	ra,0x1
    80003256:	47a080e7          	jalr	1146(ra) # 800046cc <holdingsleep>
    8000325a:	cd01                	beqz	a0,80003272 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000325c:	4585                	li	a1,1
    8000325e:	8526                	mv	a0,s1
    80003260:	00003097          	auipc	ra,0x3
    80003264:	f94080e7          	jalr	-108(ra) # 800061f4 <virtio_disk_rw>
}
    80003268:	60e2                	ld	ra,24(sp)
    8000326a:	6442                	ld	s0,16(sp)
    8000326c:	64a2                	ld	s1,8(sp)
    8000326e:	6105                	addi	sp,sp,32
    80003270:	8082                	ret
    panic("bwrite");
    80003272:	00005517          	auipc	a0,0x5
    80003276:	2c650513          	addi	a0,a0,710 # 80008538 <syscalls+0xf0>
    8000327a:	ffffd097          	auipc	ra,0xffffd
    8000327e:	2be080e7          	jalr	702(ra) # 80000538 <panic>

0000000080003282 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003282:	1101                	addi	sp,sp,-32
    80003284:	ec06                	sd	ra,24(sp)
    80003286:	e822                	sd	s0,16(sp)
    80003288:	e426                	sd	s1,8(sp)
    8000328a:	e04a                	sd	s2,0(sp)
    8000328c:	1000                	addi	s0,sp,32
    8000328e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003290:	01050913          	addi	s2,a0,16
    80003294:	854a                	mv	a0,s2
    80003296:	00001097          	auipc	ra,0x1
    8000329a:	436080e7          	jalr	1078(ra) # 800046cc <holdingsleep>
    8000329e:	c92d                	beqz	a0,80003310 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800032a0:	854a                	mv	a0,s2
    800032a2:	00001097          	auipc	ra,0x1
    800032a6:	3e6080e7          	jalr	998(ra) # 80004688 <releasesleep>

  acquire(&bcache.lock);
    800032aa:	00015517          	auipc	a0,0x15
    800032ae:	9fe50513          	addi	a0,a0,-1538 # 80017ca8 <bcache>
    800032b2:	ffffe097          	auipc	ra,0xffffe
    800032b6:	91e080e7          	jalr	-1762(ra) # 80000bd0 <acquire>
  b->refcnt--;
    800032ba:	40bc                	lw	a5,64(s1)
    800032bc:	37fd                	addiw	a5,a5,-1
    800032be:	0007871b          	sext.w	a4,a5
    800032c2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800032c4:	eb05                	bnez	a4,800032f4 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800032c6:	68bc                	ld	a5,80(s1)
    800032c8:	64b8                	ld	a4,72(s1)
    800032ca:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800032cc:	64bc                	ld	a5,72(s1)
    800032ce:	68b8                	ld	a4,80(s1)
    800032d0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800032d2:	0001d797          	auipc	a5,0x1d
    800032d6:	9d678793          	addi	a5,a5,-1578 # 8001fca8 <bcache+0x8000>
    800032da:	2b87b703          	ld	a4,696(a5)
    800032de:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032e0:	0001d717          	auipc	a4,0x1d
    800032e4:	c3070713          	addi	a4,a4,-976 # 8001ff10 <bcache+0x8268>
    800032e8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800032ea:	2b87b703          	ld	a4,696(a5)
    800032ee:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032f0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800032f4:	00015517          	auipc	a0,0x15
    800032f8:	9b450513          	addi	a0,a0,-1612 # 80017ca8 <bcache>
    800032fc:	ffffe097          	auipc	ra,0xffffe
    80003300:	988080e7          	jalr	-1656(ra) # 80000c84 <release>
}
    80003304:	60e2                	ld	ra,24(sp)
    80003306:	6442                	ld	s0,16(sp)
    80003308:	64a2                	ld	s1,8(sp)
    8000330a:	6902                	ld	s2,0(sp)
    8000330c:	6105                	addi	sp,sp,32
    8000330e:	8082                	ret
    panic("brelse");
    80003310:	00005517          	auipc	a0,0x5
    80003314:	23050513          	addi	a0,a0,560 # 80008540 <syscalls+0xf8>
    80003318:	ffffd097          	auipc	ra,0xffffd
    8000331c:	220080e7          	jalr	544(ra) # 80000538 <panic>

0000000080003320 <bpin>:

void
bpin(struct buf *b) {
    80003320:	1101                	addi	sp,sp,-32
    80003322:	ec06                	sd	ra,24(sp)
    80003324:	e822                	sd	s0,16(sp)
    80003326:	e426                	sd	s1,8(sp)
    80003328:	1000                	addi	s0,sp,32
    8000332a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000332c:	00015517          	auipc	a0,0x15
    80003330:	97c50513          	addi	a0,a0,-1668 # 80017ca8 <bcache>
    80003334:	ffffe097          	auipc	ra,0xffffe
    80003338:	89c080e7          	jalr	-1892(ra) # 80000bd0 <acquire>
  b->refcnt++;
    8000333c:	40bc                	lw	a5,64(s1)
    8000333e:	2785                	addiw	a5,a5,1
    80003340:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003342:	00015517          	auipc	a0,0x15
    80003346:	96650513          	addi	a0,a0,-1690 # 80017ca8 <bcache>
    8000334a:	ffffe097          	auipc	ra,0xffffe
    8000334e:	93a080e7          	jalr	-1734(ra) # 80000c84 <release>
}
    80003352:	60e2                	ld	ra,24(sp)
    80003354:	6442                	ld	s0,16(sp)
    80003356:	64a2                	ld	s1,8(sp)
    80003358:	6105                	addi	sp,sp,32
    8000335a:	8082                	ret

000000008000335c <bunpin>:

void
bunpin(struct buf *b) {
    8000335c:	1101                	addi	sp,sp,-32
    8000335e:	ec06                	sd	ra,24(sp)
    80003360:	e822                	sd	s0,16(sp)
    80003362:	e426                	sd	s1,8(sp)
    80003364:	1000                	addi	s0,sp,32
    80003366:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003368:	00015517          	auipc	a0,0x15
    8000336c:	94050513          	addi	a0,a0,-1728 # 80017ca8 <bcache>
    80003370:	ffffe097          	auipc	ra,0xffffe
    80003374:	860080e7          	jalr	-1952(ra) # 80000bd0 <acquire>
  b->refcnt--;
    80003378:	40bc                	lw	a5,64(s1)
    8000337a:	37fd                	addiw	a5,a5,-1
    8000337c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000337e:	00015517          	auipc	a0,0x15
    80003382:	92a50513          	addi	a0,a0,-1750 # 80017ca8 <bcache>
    80003386:	ffffe097          	auipc	ra,0xffffe
    8000338a:	8fe080e7          	jalr	-1794(ra) # 80000c84 <release>
}
    8000338e:	60e2                	ld	ra,24(sp)
    80003390:	6442                	ld	s0,16(sp)
    80003392:	64a2                	ld	s1,8(sp)
    80003394:	6105                	addi	sp,sp,32
    80003396:	8082                	ret

0000000080003398 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003398:	1101                	addi	sp,sp,-32
    8000339a:	ec06                	sd	ra,24(sp)
    8000339c:	e822                	sd	s0,16(sp)
    8000339e:	e426                	sd	s1,8(sp)
    800033a0:	e04a                	sd	s2,0(sp)
    800033a2:	1000                	addi	s0,sp,32
    800033a4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033a6:	00d5d59b          	srliw	a1,a1,0xd
    800033aa:	0001d797          	auipc	a5,0x1d
    800033ae:	fda7a783          	lw	a5,-38(a5) # 80020384 <sb+0x1c>
    800033b2:	9dbd                	addw	a1,a1,a5
    800033b4:	00000097          	auipc	ra,0x0
    800033b8:	d9e080e7          	jalr	-610(ra) # 80003152 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800033bc:	0074f713          	andi	a4,s1,7
    800033c0:	4785                	li	a5,1
    800033c2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800033c6:	14ce                	slli	s1,s1,0x33
    800033c8:	90d9                	srli	s1,s1,0x36
    800033ca:	00950733          	add	a4,a0,s1
    800033ce:	05874703          	lbu	a4,88(a4)
    800033d2:	00e7f6b3          	and	a3,a5,a4
    800033d6:	c69d                	beqz	a3,80003404 <bfree+0x6c>
    800033d8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033da:	94aa                	add	s1,s1,a0
    800033dc:	fff7c793          	not	a5,a5
    800033e0:	8ff9                	and	a5,a5,a4
    800033e2:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800033e6:	00001097          	auipc	ra,0x1
    800033ea:	12c080e7          	jalr	300(ra) # 80004512 <log_write>
  brelse(bp);
    800033ee:	854a                	mv	a0,s2
    800033f0:	00000097          	auipc	ra,0x0
    800033f4:	e92080e7          	jalr	-366(ra) # 80003282 <brelse>
}
    800033f8:	60e2                	ld	ra,24(sp)
    800033fa:	6442                	ld	s0,16(sp)
    800033fc:	64a2                	ld	s1,8(sp)
    800033fe:	6902                	ld	s2,0(sp)
    80003400:	6105                	addi	sp,sp,32
    80003402:	8082                	ret
    panic("freeing free block");
    80003404:	00005517          	auipc	a0,0x5
    80003408:	14450513          	addi	a0,a0,324 # 80008548 <syscalls+0x100>
    8000340c:	ffffd097          	auipc	ra,0xffffd
    80003410:	12c080e7          	jalr	300(ra) # 80000538 <panic>

0000000080003414 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
    80003414:	7179                	addi	sp,sp,-48
    80003416:	f406                	sd	ra,40(sp)
    80003418:	f022                	sd	s0,32(sp)
    8000341a:	ec26                	sd	s1,24(sp)
    8000341c:	e84a                	sd	s2,16(sp)
    8000341e:	e44e                	sd	s3,8(sp)
    80003420:	e052                	sd	s4,0(sp)
    80003422:	1800                	addi	s0,sp,48
    80003424:	89aa                	mv	s3,a0
    80003426:	8a2e                	mv	s4,a1
  struct inode *ip, *empty;

  acquire(&itable.lock);
    80003428:	0001d517          	auipc	a0,0x1d
    8000342c:	f6050513          	addi	a0,a0,-160 # 80020388 <itable>
    80003430:	ffffd097          	auipc	ra,0xffffd
    80003434:	7a0080e7          	jalr	1952(ra) # 80000bd0 <acquire>

  // Is the inode already in the table?
  empty = 0;
    80003438:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000343a:	0001d497          	auipc	s1,0x1d
    8000343e:	f6648493          	addi	s1,s1,-154 # 800203a0 <itable+0x18>
    80003442:	0001f697          	auipc	a3,0x1f
    80003446:	9ee68693          	addi	a3,a3,-1554 # 80021e30 <log>
    8000344a:	a039                	j	80003458 <iget+0x44>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&itable.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000344c:	02090b63          	beqz	s2,80003482 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003450:	08848493          	addi	s1,s1,136
    80003454:	02d48a63          	beq	s1,a3,80003488 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003458:	449c                	lw	a5,8(s1)
    8000345a:	fef059e3          	blez	a5,8000344c <iget+0x38>
    8000345e:	4098                	lw	a4,0(s1)
    80003460:	ff3716e3          	bne	a4,s3,8000344c <iget+0x38>
    80003464:	40d8                	lw	a4,4(s1)
    80003466:	ff4713e3          	bne	a4,s4,8000344c <iget+0x38>
      ip->ref++;
    8000346a:	2785                	addiw	a5,a5,1
    8000346c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000346e:	0001d517          	auipc	a0,0x1d
    80003472:	f1a50513          	addi	a0,a0,-230 # 80020388 <itable>
    80003476:	ffffe097          	auipc	ra,0xffffe
    8000347a:	80e080e7          	jalr	-2034(ra) # 80000c84 <release>
      return ip;
    8000347e:	8926                	mv	s2,s1
    80003480:	a03d                	j	800034ae <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003482:	f7f9                	bnez	a5,80003450 <iget+0x3c>
    80003484:	8926                	mv	s2,s1
    80003486:	b7e9                	j	80003450 <iget+0x3c>
      empty = ip;
  }

  // Recycle an inode entry.
  if(empty == 0)
    80003488:	02090c63          	beqz	s2,800034c0 <iget+0xac>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
    8000348c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003490:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003494:	4785                	li	a5,1
    80003496:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000349a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000349e:	0001d517          	auipc	a0,0x1d
    800034a2:	eea50513          	addi	a0,a0,-278 # 80020388 <itable>
    800034a6:	ffffd097          	auipc	ra,0xffffd
    800034aa:	7de080e7          	jalr	2014(ra) # 80000c84 <release>

  return ip;
}
    800034ae:	854a                	mv	a0,s2
    800034b0:	70a2                	ld	ra,40(sp)
    800034b2:	7402                	ld	s0,32(sp)
    800034b4:	64e2                	ld	s1,24(sp)
    800034b6:	6942                	ld	s2,16(sp)
    800034b8:	69a2                	ld	s3,8(sp)
    800034ba:	6a02                	ld	s4,0(sp)
    800034bc:	6145                	addi	sp,sp,48
    800034be:	8082                	ret
    panic("iget: no inodes");
    800034c0:	00005517          	auipc	a0,0x5
    800034c4:	0a050513          	addi	a0,a0,160 # 80008560 <syscalls+0x118>
    800034c8:	ffffd097          	auipc	ra,0xffffd
    800034cc:	070080e7          	jalr	112(ra) # 80000538 <panic>

00000000800034d0 <balloc>:
{
    800034d0:	711d                	addi	sp,sp,-96
    800034d2:	ec86                	sd	ra,88(sp)
    800034d4:	e8a2                	sd	s0,80(sp)
    800034d6:	e4a6                	sd	s1,72(sp)
    800034d8:	e0ca                	sd	s2,64(sp)
    800034da:	fc4e                	sd	s3,56(sp)
    800034dc:	f852                	sd	s4,48(sp)
    800034de:	f456                	sd	s5,40(sp)
    800034e0:	f05a                	sd	s6,32(sp)
    800034e2:	ec5e                	sd	s7,24(sp)
    800034e4:	e862                	sd	s8,16(sp)
    800034e6:	e466                	sd	s9,8(sp)
    800034e8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800034ea:	0001d797          	auipc	a5,0x1d
    800034ee:	e827a783          	lw	a5,-382(a5) # 8002036c <sb+0x4>
    800034f2:	10078163          	beqz	a5,800035f4 <balloc+0x124>
    800034f6:	8baa                	mv	s7,a0
    800034f8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800034fa:	0001db17          	auipc	s6,0x1d
    800034fe:	e6eb0b13          	addi	s6,s6,-402 # 80020368 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003502:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003504:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003506:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003508:	6c89                	lui	s9,0x2
    8000350a:	a061                	j	80003592 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000350c:	974a                	add	a4,a4,s2
    8000350e:	8fd5                	or	a5,a5,a3
    80003510:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003514:	854a                	mv	a0,s2
    80003516:	00001097          	auipc	ra,0x1
    8000351a:	ffc080e7          	jalr	-4(ra) # 80004512 <log_write>
        brelse(bp);
    8000351e:	854a                	mv	a0,s2
    80003520:	00000097          	auipc	ra,0x0
    80003524:	d62080e7          	jalr	-670(ra) # 80003282 <brelse>
  bp = bread(dev, bno);
    80003528:	85a6                	mv	a1,s1
    8000352a:	855e                	mv	a0,s7
    8000352c:	00000097          	auipc	ra,0x0
    80003530:	c26080e7          	jalr	-986(ra) # 80003152 <bread>
    80003534:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003536:	40000613          	li	a2,1024
    8000353a:	4581                	li	a1,0
    8000353c:	05850513          	addi	a0,a0,88
    80003540:	ffffd097          	auipc	ra,0xffffd
    80003544:	78c080e7          	jalr	1932(ra) # 80000ccc <memset>
  log_write(bp);
    80003548:	854a                	mv	a0,s2
    8000354a:	00001097          	auipc	ra,0x1
    8000354e:	fc8080e7          	jalr	-56(ra) # 80004512 <log_write>
  brelse(bp);
    80003552:	854a                	mv	a0,s2
    80003554:	00000097          	auipc	ra,0x0
    80003558:	d2e080e7          	jalr	-722(ra) # 80003282 <brelse>
}
    8000355c:	8526                	mv	a0,s1
    8000355e:	60e6                	ld	ra,88(sp)
    80003560:	6446                	ld	s0,80(sp)
    80003562:	64a6                	ld	s1,72(sp)
    80003564:	6906                	ld	s2,64(sp)
    80003566:	79e2                	ld	s3,56(sp)
    80003568:	7a42                	ld	s4,48(sp)
    8000356a:	7aa2                	ld	s5,40(sp)
    8000356c:	7b02                	ld	s6,32(sp)
    8000356e:	6be2                	ld	s7,24(sp)
    80003570:	6c42                	ld	s8,16(sp)
    80003572:	6ca2                	ld	s9,8(sp)
    80003574:	6125                	addi	sp,sp,96
    80003576:	8082                	ret
    brelse(bp);
    80003578:	854a                	mv	a0,s2
    8000357a:	00000097          	auipc	ra,0x0
    8000357e:	d08080e7          	jalr	-760(ra) # 80003282 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003582:	015c87bb          	addw	a5,s9,s5
    80003586:	00078a9b          	sext.w	s5,a5
    8000358a:	004b2703          	lw	a4,4(s6)
    8000358e:	06eaf363          	bgeu	s5,a4,800035f4 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003592:	41fad79b          	sraiw	a5,s5,0x1f
    80003596:	0137d79b          	srliw	a5,a5,0x13
    8000359a:	015787bb          	addw	a5,a5,s5
    8000359e:	40d7d79b          	sraiw	a5,a5,0xd
    800035a2:	01cb2583          	lw	a1,28(s6)
    800035a6:	9dbd                	addw	a1,a1,a5
    800035a8:	855e                	mv	a0,s7
    800035aa:	00000097          	auipc	ra,0x0
    800035ae:	ba8080e7          	jalr	-1112(ra) # 80003152 <bread>
    800035b2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035b4:	004b2503          	lw	a0,4(s6)
    800035b8:	000a849b          	sext.w	s1,s5
    800035bc:	8662                	mv	a2,s8
    800035be:	faa4fde3          	bgeu	s1,a0,80003578 <balloc+0xa8>
      m = 1 << (bi % 8);
    800035c2:	41f6579b          	sraiw	a5,a2,0x1f
    800035c6:	01d7d69b          	srliw	a3,a5,0x1d
    800035ca:	00c6873b          	addw	a4,a3,a2
    800035ce:	00777793          	andi	a5,a4,7
    800035d2:	9f95                	subw	a5,a5,a3
    800035d4:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800035d8:	4037571b          	sraiw	a4,a4,0x3
    800035dc:	00e906b3          	add	a3,s2,a4
    800035e0:	0586c683          	lbu	a3,88(a3)
    800035e4:	00d7f5b3          	and	a1,a5,a3
    800035e8:	d195                	beqz	a1,8000350c <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035ea:	2605                	addiw	a2,a2,1
    800035ec:	2485                	addiw	s1,s1,1
    800035ee:	fd4618e3          	bne	a2,s4,800035be <balloc+0xee>
    800035f2:	b759                	j	80003578 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800035f4:	00005517          	auipc	a0,0x5
    800035f8:	f7c50513          	addi	a0,a0,-132 # 80008570 <syscalls+0x128>
    800035fc:	ffffd097          	auipc	ra,0xffffd
    80003600:	f86080e7          	jalr	-122(ra) # 80000582 <printf>
  return 0;
    80003604:	4481                	li	s1,0
    80003606:	bf99                	j	8000355c <balloc+0x8c>

0000000080003608 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003608:	7179                	addi	sp,sp,-48
    8000360a:	f406                	sd	ra,40(sp)
    8000360c:	f022                	sd	s0,32(sp)
    8000360e:	ec26                	sd	s1,24(sp)
    80003610:	e84a                	sd	s2,16(sp)
    80003612:	e44e                	sd	s3,8(sp)
    80003614:	e052                	sd	s4,0(sp)
    80003616:	1800                	addi	s0,sp,48
    80003618:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000361a:	47ad                	li	a5,11
    8000361c:	02b7e763          	bltu	a5,a1,8000364a <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003620:	02059493          	slli	s1,a1,0x20
    80003624:	9081                	srli	s1,s1,0x20
    80003626:	048a                	slli	s1,s1,0x2
    80003628:	94aa                	add	s1,s1,a0
    8000362a:	0504a903          	lw	s2,80(s1)
    8000362e:	06091e63          	bnez	s2,800036aa <bmap+0xa2>
      addr = balloc(ip->dev);
    80003632:	4108                	lw	a0,0(a0)
    80003634:	00000097          	auipc	ra,0x0
    80003638:	e9c080e7          	jalr	-356(ra) # 800034d0 <balloc>
    8000363c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003640:	06090563          	beqz	s2,800036aa <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003644:	0524a823          	sw	s2,80(s1)
    80003648:	a08d                	j	800036aa <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000364a:	ff45849b          	addiw	s1,a1,-12
    8000364e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003652:	0ff00793          	li	a5,255
    80003656:	08e7e563          	bltu	a5,a4,800036e0 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000365a:	08052903          	lw	s2,128(a0)
    8000365e:	00091d63          	bnez	s2,80003678 <bmap+0x70>
      addr = balloc(ip->dev);
    80003662:	4108                	lw	a0,0(a0)
    80003664:	00000097          	auipc	ra,0x0
    80003668:	e6c080e7          	jalr	-404(ra) # 800034d0 <balloc>
    8000366c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003670:	02090d63          	beqz	s2,800036aa <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003674:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003678:	85ca                	mv	a1,s2
    8000367a:	0009a503          	lw	a0,0(s3)
    8000367e:	00000097          	auipc	ra,0x0
    80003682:	ad4080e7          	jalr	-1324(ra) # 80003152 <bread>
    80003686:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003688:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000368c:	02049593          	slli	a1,s1,0x20
    80003690:	9181                	srli	a1,a1,0x20
    80003692:	058a                	slli	a1,a1,0x2
    80003694:	00b784b3          	add	s1,a5,a1
    80003698:	0004a903          	lw	s2,0(s1)
    8000369c:	02090063          	beqz	s2,800036bc <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800036a0:	8552                	mv	a0,s4
    800036a2:	00000097          	auipc	ra,0x0
    800036a6:	be0080e7          	jalr	-1056(ra) # 80003282 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800036aa:	854a                	mv	a0,s2
    800036ac:	70a2                	ld	ra,40(sp)
    800036ae:	7402                	ld	s0,32(sp)
    800036b0:	64e2                	ld	s1,24(sp)
    800036b2:	6942                	ld	s2,16(sp)
    800036b4:	69a2                	ld	s3,8(sp)
    800036b6:	6a02                	ld	s4,0(sp)
    800036b8:	6145                	addi	sp,sp,48
    800036ba:	8082                	ret
      addr = balloc(ip->dev);
    800036bc:	0009a503          	lw	a0,0(s3)
    800036c0:	00000097          	auipc	ra,0x0
    800036c4:	e10080e7          	jalr	-496(ra) # 800034d0 <balloc>
    800036c8:	0005091b          	sext.w	s2,a0
      if(addr){
    800036cc:	fc090ae3          	beqz	s2,800036a0 <bmap+0x98>
        a[bn] = addr;
    800036d0:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800036d4:	8552                	mv	a0,s4
    800036d6:	00001097          	auipc	ra,0x1
    800036da:	e3c080e7          	jalr	-452(ra) # 80004512 <log_write>
    800036de:	b7c9                	j	800036a0 <bmap+0x98>
  panic("bmap: out of range");
    800036e0:	00005517          	auipc	a0,0x5
    800036e4:	ea850513          	addi	a0,a0,-344 # 80008588 <syscalls+0x140>
    800036e8:	ffffd097          	auipc	ra,0xffffd
    800036ec:	e50080e7          	jalr	-432(ra) # 80000538 <panic>

00000000800036f0 <fsinit>:
fsinit(int dev) {
    800036f0:	7179                	addi	sp,sp,-48
    800036f2:	f406                	sd	ra,40(sp)
    800036f4:	f022                	sd	s0,32(sp)
    800036f6:	ec26                	sd	s1,24(sp)
    800036f8:	e84a                	sd	s2,16(sp)
    800036fa:	e44e                	sd	s3,8(sp)
    800036fc:	1800                	addi	s0,sp,48
    800036fe:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003700:	4585                	li	a1,1
    80003702:	00000097          	auipc	ra,0x0
    80003706:	a50080e7          	jalr	-1456(ra) # 80003152 <bread>
    8000370a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000370c:	0001d997          	auipc	s3,0x1d
    80003710:	c5c98993          	addi	s3,s3,-932 # 80020368 <sb>
    80003714:	02000613          	li	a2,32
    80003718:	05850593          	addi	a1,a0,88
    8000371c:	854e                	mv	a0,s3
    8000371e:	ffffd097          	auipc	ra,0xffffd
    80003722:	60a080e7          	jalr	1546(ra) # 80000d28 <memmove>
  brelse(bp);
    80003726:	8526                	mv	a0,s1
    80003728:	00000097          	auipc	ra,0x0
    8000372c:	b5a080e7          	jalr	-1190(ra) # 80003282 <brelse>
  if(sb.magic != FSMAGIC)
    80003730:	0009a703          	lw	a4,0(s3)
    80003734:	102037b7          	lui	a5,0x10203
    80003738:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000373c:	02f71263          	bne	a4,a5,80003760 <fsinit+0x70>
  initlog(dev, &sb);
    80003740:	0001d597          	auipc	a1,0x1d
    80003744:	c2858593          	addi	a1,a1,-984 # 80020368 <sb>
    80003748:	854a                	mv	a0,s2
    8000374a:	00001097          	auipc	ra,0x1
    8000374e:	b4c080e7          	jalr	-1204(ra) # 80004296 <initlog>
}
    80003752:	70a2                	ld	ra,40(sp)
    80003754:	7402                	ld	s0,32(sp)
    80003756:	64e2                	ld	s1,24(sp)
    80003758:	6942                	ld	s2,16(sp)
    8000375a:	69a2                	ld	s3,8(sp)
    8000375c:	6145                	addi	sp,sp,48
    8000375e:	8082                	ret
    panic("invalid file system");
    80003760:	00005517          	auipc	a0,0x5
    80003764:	e4050513          	addi	a0,a0,-448 # 800085a0 <syscalls+0x158>
    80003768:	ffffd097          	auipc	ra,0xffffd
    8000376c:	dd0080e7          	jalr	-560(ra) # 80000538 <panic>

0000000080003770 <iinit>:
{
    80003770:	7179                	addi	sp,sp,-48
    80003772:	f406                	sd	ra,40(sp)
    80003774:	f022                	sd	s0,32(sp)
    80003776:	ec26                	sd	s1,24(sp)
    80003778:	e84a                	sd	s2,16(sp)
    8000377a:	e44e                	sd	s3,8(sp)
    8000377c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000377e:	00005597          	auipc	a1,0x5
    80003782:	e3a58593          	addi	a1,a1,-454 # 800085b8 <syscalls+0x170>
    80003786:	0001d517          	auipc	a0,0x1d
    8000378a:	c0250513          	addi	a0,a0,-1022 # 80020388 <itable>
    8000378e:	ffffd097          	auipc	ra,0xffffd
    80003792:	3b2080e7          	jalr	946(ra) # 80000b40 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003796:	0001d497          	auipc	s1,0x1d
    8000379a:	c1a48493          	addi	s1,s1,-998 # 800203b0 <itable+0x28>
    8000379e:	0001e997          	auipc	s3,0x1e
    800037a2:	6a298993          	addi	s3,s3,1698 # 80021e40 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800037a6:	00005917          	auipc	s2,0x5
    800037aa:	e1a90913          	addi	s2,s2,-486 # 800085c0 <syscalls+0x178>
    800037ae:	85ca                	mv	a1,s2
    800037b0:	8526                	mv	a0,s1
    800037b2:	00001097          	auipc	ra,0x1
    800037b6:	e46080e7          	jalr	-442(ra) # 800045f8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800037ba:	08848493          	addi	s1,s1,136
    800037be:	ff3498e3          	bne	s1,s3,800037ae <iinit+0x3e>
}
    800037c2:	70a2                	ld	ra,40(sp)
    800037c4:	7402                	ld	s0,32(sp)
    800037c6:	64e2                	ld	s1,24(sp)
    800037c8:	6942                	ld	s2,16(sp)
    800037ca:	69a2                	ld	s3,8(sp)
    800037cc:	6145                	addi	sp,sp,48
    800037ce:	8082                	ret

00000000800037d0 <ialloc>:
{
    800037d0:	715d                	addi	sp,sp,-80
    800037d2:	e486                	sd	ra,72(sp)
    800037d4:	e0a2                	sd	s0,64(sp)
    800037d6:	fc26                	sd	s1,56(sp)
    800037d8:	f84a                	sd	s2,48(sp)
    800037da:	f44e                	sd	s3,40(sp)
    800037dc:	f052                	sd	s4,32(sp)
    800037de:	ec56                	sd	s5,24(sp)
    800037e0:	e85a                	sd	s6,16(sp)
    800037e2:	e45e                	sd	s7,8(sp)
    800037e4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800037e6:	0001d717          	auipc	a4,0x1d
    800037ea:	b8e72703          	lw	a4,-1138(a4) # 80020374 <sb+0xc>
    800037ee:	4785                	li	a5,1
    800037f0:	04e7fa63          	bgeu	a5,a4,80003844 <ialloc+0x74>
    800037f4:	8aaa                	mv	s5,a0
    800037f6:	8bae                	mv	s7,a1
    800037f8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037fa:	0001da17          	auipc	s4,0x1d
    800037fe:	b6ea0a13          	addi	s4,s4,-1170 # 80020368 <sb>
    80003802:	00048b1b          	sext.w	s6,s1
    80003806:	0044d793          	srli	a5,s1,0x4
    8000380a:	018a2583          	lw	a1,24(s4)
    8000380e:	9dbd                	addw	a1,a1,a5
    80003810:	8556                	mv	a0,s5
    80003812:	00000097          	auipc	ra,0x0
    80003816:	940080e7          	jalr	-1728(ra) # 80003152 <bread>
    8000381a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000381c:	05850993          	addi	s3,a0,88
    80003820:	00f4f793          	andi	a5,s1,15
    80003824:	079a                	slli	a5,a5,0x6
    80003826:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003828:	00099783          	lh	a5,0(s3)
    8000382c:	c785                	beqz	a5,80003854 <ialloc+0x84>
    brelse(bp);
    8000382e:	00000097          	auipc	ra,0x0
    80003832:	a54080e7          	jalr	-1452(ra) # 80003282 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003836:	0485                	addi	s1,s1,1
    80003838:	00ca2703          	lw	a4,12(s4)
    8000383c:	0004879b          	sext.w	a5,s1
    80003840:	fce7e1e3          	bltu	a5,a4,80003802 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003844:	00005517          	auipc	a0,0x5
    80003848:	d8450513          	addi	a0,a0,-636 # 800085c8 <syscalls+0x180>
    8000384c:	ffffd097          	auipc	ra,0xffffd
    80003850:	cec080e7          	jalr	-788(ra) # 80000538 <panic>
      memset(dip, 0, sizeof(*dip));
    80003854:	04000613          	li	a2,64
    80003858:	4581                	li	a1,0
    8000385a:	854e                	mv	a0,s3
    8000385c:	ffffd097          	auipc	ra,0xffffd
    80003860:	470080e7          	jalr	1136(ra) # 80000ccc <memset>
      dip->type = type;
    80003864:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003868:	854a                	mv	a0,s2
    8000386a:	00001097          	auipc	ra,0x1
    8000386e:	ca8080e7          	jalr	-856(ra) # 80004512 <log_write>
      brelse(bp);
    80003872:	854a                	mv	a0,s2
    80003874:	00000097          	auipc	ra,0x0
    80003878:	a0e080e7          	jalr	-1522(ra) # 80003282 <brelse>
      return iget(dev, inum);
    8000387c:	85da                	mv	a1,s6
    8000387e:	8556                	mv	a0,s5
    80003880:	00000097          	auipc	ra,0x0
    80003884:	b94080e7          	jalr	-1132(ra) # 80003414 <iget>
}
    80003888:	60a6                	ld	ra,72(sp)
    8000388a:	6406                	ld	s0,64(sp)
    8000388c:	74e2                	ld	s1,56(sp)
    8000388e:	7942                	ld	s2,48(sp)
    80003890:	79a2                	ld	s3,40(sp)
    80003892:	7a02                	ld	s4,32(sp)
    80003894:	6ae2                	ld	s5,24(sp)
    80003896:	6b42                	ld	s6,16(sp)
    80003898:	6ba2                	ld	s7,8(sp)
    8000389a:	6161                	addi	sp,sp,80
    8000389c:	8082                	ret

000000008000389e <iupdate>:
{
    8000389e:	1101                	addi	sp,sp,-32
    800038a0:	ec06                	sd	ra,24(sp)
    800038a2:	e822                	sd	s0,16(sp)
    800038a4:	e426                	sd	s1,8(sp)
    800038a6:	e04a                	sd	s2,0(sp)
    800038a8:	1000                	addi	s0,sp,32
    800038aa:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038ac:	415c                	lw	a5,4(a0)
    800038ae:	0047d79b          	srliw	a5,a5,0x4
    800038b2:	0001d597          	auipc	a1,0x1d
    800038b6:	ace5a583          	lw	a1,-1330(a1) # 80020380 <sb+0x18>
    800038ba:	9dbd                	addw	a1,a1,a5
    800038bc:	4108                	lw	a0,0(a0)
    800038be:	00000097          	auipc	ra,0x0
    800038c2:	894080e7          	jalr	-1900(ra) # 80003152 <bread>
    800038c6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038c8:	05850793          	addi	a5,a0,88
    800038cc:	40c8                	lw	a0,4(s1)
    800038ce:	893d                	andi	a0,a0,15
    800038d0:	051a                	slli	a0,a0,0x6
    800038d2:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800038d4:	04449703          	lh	a4,68(s1)
    800038d8:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800038dc:	04649703          	lh	a4,70(s1)
    800038e0:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800038e4:	04849703          	lh	a4,72(s1)
    800038e8:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800038ec:	04a49703          	lh	a4,74(s1)
    800038f0:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800038f4:	44f8                	lw	a4,76(s1)
    800038f6:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038f8:	03400613          	li	a2,52
    800038fc:	05048593          	addi	a1,s1,80
    80003900:	0531                	addi	a0,a0,12
    80003902:	ffffd097          	auipc	ra,0xffffd
    80003906:	426080e7          	jalr	1062(ra) # 80000d28 <memmove>
  log_write(bp);
    8000390a:	854a                	mv	a0,s2
    8000390c:	00001097          	auipc	ra,0x1
    80003910:	c06080e7          	jalr	-1018(ra) # 80004512 <log_write>
  brelse(bp);
    80003914:	854a                	mv	a0,s2
    80003916:	00000097          	auipc	ra,0x0
    8000391a:	96c080e7          	jalr	-1684(ra) # 80003282 <brelse>
}
    8000391e:	60e2                	ld	ra,24(sp)
    80003920:	6442                	ld	s0,16(sp)
    80003922:	64a2                	ld	s1,8(sp)
    80003924:	6902                	ld	s2,0(sp)
    80003926:	6105                	addi	sp,sp,32
    80003928:	8082                	ret

000000008000392a <idup>:
{
    8000392a:	1101                	addi	sp,sp,-32
    8000392c:	ec06                	sd	ra,24(sp)
    8000392e:	e822                	sd	s0,16(sp)
    80003930:	e426                	sd	s1,8(sp)
    80003932:	1000                	addi	s0,sp,32
    80003934:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003936:	0001d517          	auipc	a0,0x1d
    8000393a:	a5250513          	addi	a0,a0,-1454 # 80020388 <itable>
    8000393e:	ffffd097          	auipc	ra,0xffffd
    80003942:	292080e7          	jalr	658(ra) # 80000bd0 <acquire>
  ip->ref++;
    80003946:	449c                	lw	a5,8(s1)
    80003948:	2785                	addiw	a5,a5,1
    8000394a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000394c:	0001d517          	auipc	a0,0x1d
    80003950:	a3c50513          	addi	a0,a0,-1476 # 80020388 <itable>
    80003954:	ffffd097          	auipc	ra,0xffffd
    80003958:	330080e7          	jalr	816(ra) # 80000c84 <release>
}
    8000395c:	8526                	mv	a0,s1
    8000395e:	60e2                	ld	ra,24(sp)
    80003960:	6442                	ld	s0,16(sp)
    80003962:	64a2                	ld	s1,8(sp)
    80003964:	6105                	addi	sp,sp,32
    80003966:	8082                	ret

0000000080003968 <ilock>:
{
    80003968:	1101                	addi	sp,sp,-32
    8000396a:	ec06                	sd	ra,24(sp)
    8000396c:	e822                	sd	s0,16(sp)
    8000396e:	e426                	sd	s1,8(sp)
    80003970:	e04a                	sd	s2,0(sp)
    80003972:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003974:	c115                	beqz	a0,80003998 <ilock+0x30>
    80003976:	84aa                	mv	s1,a0
    80003978:	451c                	lw	a5,8(a0)
    8000397a:	00f05f63          	blez	a5,80003998 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000397e:	0541                	addi	a0,a0,16
    80003980:	00001097          	auipc	ra,0x1
    80003984:	cb2080e7          	jalr	-846(ra) # 80004632 <acquiresleep>
  if(ip->valid == 0){
    80003988:	40bc                	lw	a5,64(s1)
    8000398a:	cf99                	beqz	a5,800039a8 <ilock+0x40>
}
    8000398c:	60e2                	ld	ra,24(sp)
    8000398e:	6442                	ld	s0,16(sp)
    80003990:	64a2                	ld	s1,8(sp)
    80003992:	6902                	ld	s2,0(sp)
    80003994:	6105                	addi	sp,sp,32
    80003996:	8082                	ret
    panic("ilock");
    80003998:	00005517          	auipc	a0,0x5
    8000399c:	c4850513          	addi	a0,a0,-952 # 800085e0 <syscalls+0x198>
    800039a0:	ffffd097          	auipc	ra,0xffffd
    800039a4:	b98080e7          	jalr	-1128(ra) # 80000538 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039a8:	40dc                	lw	a5,4(s1)
    800039aa:	0047d79b          	srliw	a5,a5,0x4
    800039ae:	0001d597          	auipc	a1,0x1d
    800039b2:	9d25a583          	lw	a1,-1582(a1) # 80020380 <sb+0x18>
    800039b6:	9dbd                	addw	a1,a1,a5
    800039b8:	4088                	lw	a0,0(s1)
    800039ba:	fffff097          	auipc	ra,0xfffff
    800039be:	798080e7          	jalr	1944(ra) # 80003152 <bread>
    800039c2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039c4:	05850593          	addi	a1,a0,88
    800039c8:	40dc                	lw	a5,4(s1)
    800039ca:	8bbd                	andi	a5,a5,15
    800039cc:	079a                	slli	a5,a5,0x6
    800039ce:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039d0:	00059783          	lh	a5,0(a1)
    800039d4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039d8:	00259783          	lh	a5,2(a1)
    800039dc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039e0:	00459783          	lh	a5,4(a1)
    800039e4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039e8:	00659783          	lh	a5,6(a1)
    800039ec:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039f0:	459c                	lw	a5,8(a1)
    800039f2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039f4:	03400613          	li	a2,52
    800039f8:	05b1                	addi	a1,a1,12
    800039fa:	05048513          	addi	a0,s1,80
    800039fe:	ffffd097          	auipc	ra,0xffffd
    80003a02:	32a080e7          	jalr	810(ra) # 80000d28 <memmove>
    brelse(bp);
    80003a06:	854a                	mv	a0,s2
    80003a08:	00000097          	auipc	ra,0x0
    80003a0c:	87a080e7          	jalr	-1926(ra) # 80003282 <brelse>
    ip->valid = 1;
    80003a10:	4785                	li	a5,1
    80003a12:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003a14:	04449783          	lh	a5,68(s1)
    80003a18:	fbb5                	bnez	a5,8000398c <ilock+0x24>
      panic("ilock: no type");
    80003a1a:	00005517          	auipc	a0,0x5
    80003a1e:	bce50513          	addi	a0,a0,-1074 # 800085e8 <syscalls+0x1a0>
    80003a22:	ffffd097          	auipc	ra,0xffffd
    80003a26:	b16080e7          	jalr	-1258(ra) # 80000538 <panic>

0000000080003a2a <iunlock>:
{
    80003a2a:	1101                	addi	sp,sp,-32
    80003a2c:	ec06                	sd	ra,24(sp)
    80003a2e:	e822                	sd	s0,16(sp)
    80003a30:	e426                	sd	s1,8(sp)
    80003a32:	e04a                	sd	s2,0(sp)
    80003a34:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a36:	c905                	beqz	a0,80003a66 <iunlock+0x3c>
    80003a38:	84aa                	mv	s1,a0
    80003a3a:	01050913          	addi	s2,a0,16
    80003a3e:	854a                	mv	a0,s2
    80003a40:	00001097          	auipc	ra,0x1
    80003a44:	c8c080e7          	jalr	-884(ra) # 800046cc <holdingsleep>
    80003a48:	cd19                	beqz	a0,80003a66 <iunlock+0x3c>
    80003a4a:	449c                	lw	a5,8(s1)
    80003a4c:	00f05d63          	blez	a5,80003a66 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a50:	854a                	mv	a0,s2
    80003a52:	00001097          	auipc	ra,0x1
    80003a56:	c36080e7          	jalr	-970(ra) # 80004688 <releasesleep>
}
    80003a5a:	60e2                	ld	ra,24(sp)
    80003a5c:	6442                	ld	s0,16(sp)
    80003a5e:	64a2                	ld	s1,8(sp)
    80003a60:	6902                	ld	s2,0(sp)
    80003a62:	6105                	addi	sp,sp,32
    80003a64:	8082                	ret
    panic("iunlock");
    80003a66:	00005517          	auipc	a0,0x5
    80003a6a:	b9250513          	addi	a0,a0,-1134 # 800085f8 <syscalls+0x1b0>
    80003a6e:	ffffd097          	auipc	ra,0xffffd
    80003a72:	aca080e7          	jalr	-1334(ra) # 80000538 <panic>

0000000080003a76 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a76:	7179                	addi	sp,sp,-48
    80003a78:	f406                	sd	ra,40(sp)
    80003a7a:	f022                	sd	s0,32(sp)
    80003a7c:	ec26                	sd	s1,24(sp)
    80003a7e:	e84a                	sd	s2,16(sp)
    80003a80:	e44e                	sd	s3,8(sp)
    80003a82:	e052                	sd	s4,0(sp)
    80003a84:	1800                	addi	s0,sp,48
    80003a86:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a88:	05050493          	addi	s1,a0,80
    80003a8c:	08050913          	addi	s2,a0,128
    80003a90:	a021                	j	80003a98 <itrunc+0x22>
    80003a92:	0491                	addi	s1,s1,4
    80003a94:	01248d63          	beq	s1,s2,80003aae <itrunc+0x38>
    if(ip->addrs[i]){
    80003a98:	408c                	lw	a1,0(s1)
    80003a9a:	dde5                	beqz	a1,80003a92 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a9c:	0009a503          	lw	a0,0(s3)
    80003aa0:	00000097          	auipc	ra,0x0
    80003aa4:	8f8080e7          	jalr	-1800(ra) # 80003398 <bfree>
      ip->addrs[i] = 0;
    80003aa8:	0004a023          	sw	zero,0(s1)
    80003aac:	b7dd                	j	80003a92 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003aae:	0809a583          	lw	a1,128(s3)
    80003ab2:	e185                	bnez	a1,80003ad2 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003ab4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003ab8:	854e                	mv	a0,s3
    80003aba:	00000097          	auipc	ra,0x0
    80003abe:	de4080e7          	jalr	-540(ra) # 8000389e <iupdate>
}
    80003ac2:	70a2                	ld	ra,40(sp)
    80003ac4:	7402                	ld	s0,32(sp)
    80003ac6:	64e2                	ld	s1,24(sp)
    80003ac8:	6942                	ld	s2,16(sp)
    80003aca:	69a2                	ld	s3,8(sp)
    80003acc:	6a02                	ld	s4,0(sp)
    80003ace:	6145                	addi	sp,sp,48
    80003ad0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003ad2:	0009a503          	lw	a0,0(s3)
    80003ad6:	fffff097          	auipc	ra,0xfffff
    80003ada:	67c080e7          	jalr	1660(ra) # 80003152 <bread>
    80003ade:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003ae0:	05850493          	addi	s1,a0,88
    80003ae4:	45850913          	addi	s2,a0,1112
    80003ae8:	a021                	j	80003af0 <itrunc+0x7a>
    80003aea:	0491                	addi	s1,s1,4
    80003aec:	01248b63          	beq	s1,s2,80003b02 <itrunc+0x8c>
      if(a[j])
    80003af0:	408c                	lw	a1,0(s1)
    80003af2:	dde5                	beqz	a1,80003aea <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003af4:	0009a503          	lw	a0,0(s3)
    80003af8:	00000097          	auipc	ra,0x0
    80003afc:	8a0080e7          	jalr	-1888(ra) # 80003398 <bfree>
    80003b00:	b7ed                	j	80003aea <itrunc+0x74>
    brelse(bp);
    80003b02:	8552                	mv	a0,s4
    80003b04:	fffff097          	auipc	ra,0xfffff
    80003b08:	77e080e7          	jalr	1918(ra) # 80003282 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b0c:	0809a583          	lw	a1,128(s3)
    80003b10:	0009a503          	lw	a0,0(s3)
    80003b14:	00000097          	auipc	ra,0x0
    80003b18:	884080e7          	jalr	-1916(ra) # 80003398 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b1c:	0809a023          	sw	zero,128(s3)
    80003b20:	bf51                	j	80003ab4 <itrunc+0x3e>

0000000080003b22 <iput>:
{
    80003b22:	1101                	addi	sp,sp,-32
    80003b24:	ec06                	sd	ra,24(sp)
    80003b26:	e822                	sd	s0,16(sp)
    80003b28:	e426                	sd	s1,8(sp)
    80003b2a:	e04a                	sd	s2,0(sp)
    80003b2c:	1000                	addi	s0,sp,32
    80003b2e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b30:	0001d517          	auipc	a0,0x1d
    80003b34:	85850513          	addi	a0,a0,-1960 # 80020388 <itable>
    80003b38:	ffffd097          	auipc	ra,0xffffd
    80003b3c:	098080e7          	jalr	152(ra) # 80000bd0 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b40:	4498                	lw	a4,8(s1)
    80003b42:	4785                	li	a5,1
    80003b44:	02f70363          	beq	a4,a5,80003b6a <iput+0x48>
  ip->ref--;
    80003b48:	449c                	lw	a5,8(s1)
    80003b4a:	37fd                	addiw	a5,a5,-1
    80003b4c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b4e:	0001d517          	auipc	a0,0x1d
    80003b52:	83a50513          	addi	a0,a0,-1990 # 80020388 <itable>
    80003b56:	ffffd097          	auipc	ra,0xffffd
    80003b5a:	12e080e7          	jalr	302(ra) # 80000c84 <release>
}
    80003b5e:	60e2                	ld	ra,24(sp)
    80003b60:	6442                	ld	s0,16(sp)
    80003b62:	64a2                	ld	s1,8(sp)
    80003b64:	6902                	ld	s2,0(sp)
    80003b66:	6105                	addi	sp,sp,32
    80003b68:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b6a:	40bc                	lw	a5,64(s1)
    80003b6c:	dff1                	beqz	a5,80003b48 <iput+0x26>
    80003b6e:	04a49783          	lh	a5,74(s1)
    80003b72:	fbf9                	bnez	a5,80003b48 <iput+0x26>
    acquiresleep(&ip->lock);
    80003b74:	01048913          	addi	s2,s1,16
    80003b78:	854a                	mv	a0,s2
    80003b7a:	00001097          	auipc	ra,0x1
    80003b7e:	ab8080e7          	jalr	-1352(ra) # 80004632 <acquiresleep>
    release(&itable.lock);
    80003b82:	0001d517          	auipc	a0,0x1d
    80003b86:	80650513          	addi	a0,a0,-2042 # 80020388 <itable>
    80003b8a:	ffffd097          	auipc	ra,0xffffd
    80003b8e:	0fa080e7          	jalr	250(ra) # 80000c84 <release>
    itrunc(ip);
    80003b92:	8526                	mv	a0,s1
    80003b94:	00000097          	auipc	ra,0x0
    80003b98:	ee2080e7          	jalr	-286(ra) # 80003a76 <itrunc>
    ip->type = 0;
    80003b9c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003ba0:	8526                	mv	a0,s1
    80003ba2:	00000097          	auipc	ra,0x0
    80003ba6:	cfc080e7          	jalr	-772(ra) # 8000389e <iupdate>
    ip->valid = 0;
    80003baa:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003bae:	854a                	mv	a0,s2
    80003bb0:	00001097          	auipc	ra,0x1
    80003bb4:	ad8080e7          	jalr	-1320(ra) # 80004688 <releasesleep>
    acquire(&itable.lock);
    80003bb8:	0001c517          	auipc	a0,0x1c
    80003bbc:	7d050513          	addi	a0,a0,2000 # 80020388 <itable>
    80003bc0:	ffffd097          	auipc	ra,0xffffd
    80003bc4:	010080e7          	jalr	16(ra) # 80000bd0 <acquire>
    80003bc8:	b741                	j	80003b48 <iput+0x26>

0000000080003bca <iunlockput>:
{
    80003bca:	1101                	addi	sp,sp,-32
    80003bcc:	ec06                	sd	ra,24(sp)
    80003bce:	e822                	sd	s0,16(sp)
    80003bd0:	e426                	sd	s1,8(sp)
    80003bd2:	1000                	addi	s0,sp,32
    80003bd4:	84aa                	mv	s1,a0
  iunlock(ip);
    80003bd6:	00000097          	auipc	ra,0x0
    80003bda:	e54080e7          	jalr	-428(ra) # 80003a2a <iunlock>
  iput(ip);
    80003bde:	8526                	mv	a0,s1
    80003be0:	00000097          	auipc	ra,0x0
    80003be4:	f42080e7          	jalr	-190(ra) # 80003b22 <iput>
}
    80003be8:	60e2                	ld	ra,24(sp)
    80003bea:	6442                	ld	s0,16(sp)
    80003bec:	64a2                	ld	s1,8(sp)
    80003bee:	6105                	addi	sp,sp,32
    80003bf0:	8082                	ret

0000000080003bf2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003bf2:	1141                	addi	sp,sp,-16
    80003bf4:	e422                	sd	s0,8(sp)
    80003bf6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003bf8:	411c                	lw	a5,0(a0)
    80003bfa:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bfc:	415c                	lw	a5,4(a0)
    80003bfe:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003c00:	04451783          	lh	a5,68(a0)
    80003c04:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003c08:	04a51783          	lh	a5,74(a0)
    80003c0c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003c10:	04c56783          	lwu	a5,76(a0)
    80003c14:	e99c                	sd	a5,16(a1)
}
    80003c16:	6422                	ld	s0,8(sp)
    80003c18:	0141                	addi	sp,sp,16
    80003c1a:	8082                	ret

0000000080003c1c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c1c:	457c                	lw	a5,76(a0)
    80003c1e:	0ed7e963          	bltu	a5,a3,80003d10 <readi+0xf4>
{
    80003c22:	7159                	addi	sp,sp,-112
    80003c24:	f486                	sd	ra,104(sp)
    80003c26:	f0a2                	sd	s0,96(sp)
    80003c28:	eca6                	sd	s1,88(sp)
    80003c2a:	e8ca                	sd	s2,80(sp)
    80003c2c:	e4ce                	sd	s3,72(sp)
    80003c2e:	e0d2                	sd	s4,64(sp)
    80003c30:	fc56                	sd	s5,56(sp)
    80003c32:	f85a                	sd	s6,48(sp)
    80003c34:	f45e                	sd	s7,40(sp)
    80003c36:	f062                	sd	s8,32(sp)
    80003c38:	ec66                	sd	s9,24(sp)
    80003c3a:	e86a                	sd	s10,16(sp)
    80003c3c:	e46e                	sd	s11,8(sp)
    80003c3e:	1880                	addi	s0,sp,112
    80003c40:	8b2a                	mv	s6,a0
    80003c42:	8bae                	mv	s7,a1
    80003c44:	8a32                	mv	s4,a2
    80003c46:	84b6                	mv	s1,a3
    80003c48:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c4a:	9f35                	addw	a4,a4,a3
    return 0;
    80003c4c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c4e:	0ad76063          	bltu	a4,a3,80003cee <readi+0xd2>
  if(off + n > ip->size)
    80003c52:	00e7f463          	bgeu	a5,a4,80003c5a <readi+0x3e>
    n = ip->size - off;
    80003c56:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c5a:	0a0a8963          	beqz	s5,80003d0c <readi+0xf0>
    80003c5e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c60:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c64:	5c7d                	li	s8,-1
    80003c66:	a82d                	j	80003ca0 <readi+0x84>
    80003c68:	020d1d93          	slli	s11,s10,0x20
    80003c6c:	020ddd93          	srli	s11,s11,0x20
    80003c70:	05890793          	addi	a5,s2,88
    80003c74:	86ee                	mv	a3,s11
    80003c76:	963e                	add	a2,a2,a5
    80003c78:	85d2                	mv	a1,s4
    80003c7a:	855e                	mv	a0,s7
    80003c7c:	fffff097          	auipc	ra,0xfffff
    80003c80:	b08080e7          	jalr	-1272(ra) # 80002784 <either_copyout>
    80003c84:	05850d63          	beq	a0,s8,80003cde <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c88:	854a                	mv	a0,s2
    80003c8a:	fffff097          	auipc	ra,0xfffff
    80003c8e:	5f8080e7          	jalr	1528(ra) # 80003282 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c92:	013d09bb          	addw	s3,s10,s3
    80003c96:	009d04bb          	addw	s1,s10,s1
    80003c9a:	9a6e                	add	s4,s4,s11
    80003c9c:	0559f763          	bgeu	s3,s5,80003cea <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003ca0:	00a4d59b          	srliw	a1,s1,0xa
    80003ca4:	855a                	mv	a0,s6
    80003ca6:	00000097          	auipc	ra,0x0
    80003caa:	962080e7          	jalr	-1694(ra) # 80003608 <bmap>
    80003cae:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003cb2:	cd85                	beqz	a1,80003cea <readi+0xce>
    bp = bread(ip->dev, addr);
    80003cb4:	000b2503          	lw	a0,0(s6)
    80003cb8:	fffff097          	auipc	ra,0xfffff
    80003cbc:	49a080e7          	jalr	1178(ra) # 80003152 <bread>
    80003cc0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cc2:	3ff4f613          	andi	a2,s1,1023
    80003cc6:	40cc87bb          	subw	a5,s9,a2
    80003cca:	413a873b          	subw	a4,s5,s3
    80003cce:	8d3e                	mv	s10,a5
    80003cd0:	2781                	sext.w	a5,a5
    80003cd2:	0007069b          	sext.w	a3,a4
    80003cd6:	f8f6f9e3          	bgeu	a3,a5,80003c68 <readi+0x4c>
    80003cda:	8d3a                	mv	s10,a4
    80003cdc:	b771                	j	80003c68 <readi+0x4c>
      brelse(bp);
    80003cde:	854a                	mv	a0,s2
    80003ce0:	fffff097          	auipc	ra,0xfffff
    80003ce4:	5a2080e7          	jalr	1442(ra) # 80003282 <brelse>
      tot = -1;
    80003ce8:	59fd                	li	s3,-1
  }
  return tot;
    80003cea:	0009851b          	sext.w	a0,s3
}
    80003cee:	70a6                	ld	ra,104(sp)
    80003cf0:	7406                	ld	s0,96(sp)
    80003cf2:	64e6                	ld	s1,88(sp)
    80003cf4:	6946                	ld	s2,80(sp)
    80003cf6:	69a6                	ld	s3,72(sp)
    80003cf8:	6a06                	ld	s4,64(sp)
    80003cfa:	7ae2                	ld	s5,56(sp)
    80003cfc:	7b42                	ld	s6,48(sp)
    80003cfe:	7ba2                	ld	s7,40(sp)
    80003d00:	7c02                	ld	s8,32(sp)
    80003d02:	6ce2                	ld	s9,24(sp)
    80003d04:	6d42                	ld	s10,16(sp)
    80003d06:	6da2                	ld	s11,8(sp)
    80003d08:	6165                	addi	sp,sp,112
    80003d0a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d0c:	89d6                	mv	s3,s5
    80003d0e:	bff1                	j	80003cea <readi+0xce>
    return 0;
    80003d10:	4501                	li	a0,0
}
    80003d12:	8082                	ret

0000000080003d14 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d14:	457c                	lw	a5,76(a0)
    80003d16:	10d7e863          	bltu	a5,a3,80003e26 <writei+0x112>
{
    80003d1a:	7159                	addi	sp,sp,-112
    80003d1c:	f486                	sd	ra,104(sp)
    80003d1e:	f0a2                	sd	s0,96(sp)
    80003d20:	eca6                	sd	s1,88(sp)
    80003d22:	e8ca                	sd	s2,80(sp)
    80003d24:	e4ce                	sd	s3,72(sp)
    80003d26:	e0d2                	sd	s4,64(sp)
    80003d28:	fc56                	sd	s5,56(sp)
    80003d2a:	f85a                	sd	s6,48(sp)
    80003d2c:	f45e                	sd	s7,40(sp)
    80003d2e:	f062                	sd	s8,32(sp)
    80003d30:	ec66                	sd	s9,24(sp)
    80003d32:	e86a                	sd	s10,16(sp)
    80003d34:	e46e                	sd	s11,8(sp)
    80003d36:	1880                	addi	s0,sp,112
    80003d38:	8aaa                	mv	s5,a0
    80003d3a:	8bae                	mv	s7,a1
    80003d3c:	8a32                	mv	s4,a2
    80003d3e:	8936                	mv	s2,a3
    80003d40:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d42:	00e687bb          	addw	a5,a3,a4
    80003d46:	0ed7e263          	bltu	a5,a3,80003e2a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d4a:	00043737          	lui	a4,0x43
    80003d4e:	0ef76063          	bltu	a4,a5,80003e2e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d52:	0c0b0863          	beqz	s6,80003e22 <writei+0x10e>
    80003d56:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d58:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d5c:	5c7d                	li	s8,-1
    80003d5e:	a091                	j	80003da2 <writei+0x8e>
    80003d60:	020d1d93          	slli	s11,s10,0x20
    80003d64:	020ddd93          	srli	s11,s11,0x20
    80003d68:	05848793          	addi	a5,s1,88
    80003d6c:	86ee                	mv	a3,s11
    80003d6e:	8652                	mv	a2,s4
    80003d70:	85de                	mv	a1,s7
    80003d72:	953e                	add	a0,a0,a5
    80003d74:	fffff097          	auipc	ra,0xfffff
    80003d78:	a66080e7          	jalr	-1434(ra) # 800027da <either_copyin>
    80003d7c:	07850263          	beq	a0,s8,80003de0 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d80:	8526                	mv	a0,s1
    80003d82:	00000097          	auipc	ra,0x0
    80003d86:	790080e7          	jalr	1936(ra) # 80004512 <log_write>
    brelse(bp);
    80003d8a:	8526                	mv	a0,s1
    80003d8c:	fffff097          	auipc	ra,0xfffff
    80003d90:	4f6080e7          	jalr	1270(ra) # 80003282 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d94:	013d09bb          	addw	s3,s10,s3
    80003d98:	012d093b          	addw	s2,s10,s2
    80003d9c:	9a6e                	add	s4,s4,s11
    80003d9e:	0569f663          	bgeu	s3,s6,80003dea <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003da2:	00a9559b          	srliw	a1,s2,0xa
    80003da6:	8556                	mv	a0,s5
    80003da8:	00000097          	auipc	ra,0x0
    80003dac:	860080e7          	jalr	-1952(ra) # 80003608 <bmap>
    80003db0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003db4:	c99d                	beqz	a1,80003dea <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003db6:	000aa503          	lw	a0,0(s5)
    80003dba:	fffff097          	auipc	ra,0xfffff
    80003dbe:	398080e7          	jalr	920(ra) # 80003152 <bread>
    80003dc2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dc4:	3ff97513          	andi	a0,s2,1023
    80003dc8:	40ac87bb          	subw	a5,s9,a0
    80003dcc:	413b073b          	subw	a4,s6,s3
    80003dd0:	8d3e                	mv	s10,a5
    80003dd2:	2781                	sext.w	a5,a5
    80003dd4:	0007069b          	sext.w	a3,a4
    80003dd8:	f8f6f4e3          	bgeu	a3,a5,80003d60 <writei+0x4c>
    80003ddc:	8d3a                	mv	s10,a4
    80003dde:	b749                	j	80003d60 <writei+0x4c>
      brelse(bp);
    80003de0:	8526                	mv	a0,s1
    80003de2:	fffff097          	auipc	ra,0xfffff
    80003de6:	4a0080e7          	jalr	1184(ra) # 80003282 <brelse>
  }

  if(off > ip->size)
    80003dea:	04caa783          	lw	a5,76(s5)
    80003dee:	0127f463          	bgeu	a5,s2,80003df6 <writei+0xe2>
    ip->size = off;
    80003df2:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003df6:	8556                	mv	a0,s5
    80003df8:	00000097          	auipc	ra,0x0
    80003dfc:	aa6080e7          	jalr	-1370(ra) # 8000389e <iupdate>

  return tot;
    80003e00:	0009851b          	sext.w	a0,s3
}
    80003e04:	70a6                	ld	ra,104(sp)
    80003e06:	7406                	ld	s0,96(sp)
    80003e08:	64e6                	ld	s1,88(sp)
    80003e0a:	6946                	ld	s2,80(sp)
    80003e0c:	69a6                	ld	s3,72(sp)
    80003e0e:	6a06                	ld	s4,64(sp)
    80003e10:	7ae2                	ld	s5,56(sp)
    80003e12:	7b42                	ld	s6,48(sp)
    80003e14:	7ba2                	ld	s7,40(sp)
    80003e16:	7c02                	ld	s8,32(sp)
    80003e18:	6ce2                	ld	s9,24(sp)
    80003e1a:	6d42                	ld	s10,16(sp)
    80003e1c:	6da2                	ld	s11,8(sp)
    80003e1e:	6165                	addi	sp,sp,112
    80003e20:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e22:	89da                	mv	s3,s6
    80003e24:	bfc9                	j	80003df6 <writei+0xe2>
    return -1;
    80003e26:	557d                	li	a0,-1
}
    80003e28:	8082                	ret
    return -1;
    80003e2a:	557d                	li	a0,-1
    80003e2c:	bfe1                	j	80003e04 <writei+0xf0>
    return -1;
    80003e2e:	557d                	li	a0,-1
    80003e30:	bfd1                	j	80003e04 <writei+0xf0>

0000000080003e32 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003e32:	1141                	addi	sp,sp,-16
    80003e34:	e406                	sd	ra,8(sp)
    80003e36:	e022                	sd	s0,0(sp)
    80003e38:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003e3a:	4639                	li	a2,14
    80003e3c:	ffffd097          	auipc	ra,0xffffd
    80003e40:	f60080e7          	jalr	-160(ra) # 80000d9c <strncmp>
}
    80003e44:	60a2                	ld	ra,8(sp)
    80003e46:	6402                	ld	s0,0(sp)
    80003e48:	0141                	addi	sp,sp,16
    80003e4a:	8082                	ret

0000000080003e4c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e4c:	7139                	addi	sp,sp,-64
    80003e4e:	fc06                	sd	ra,56(sp)
    80003e50:	f822                	sd	s0,48(sp)
    80003e52:	f426                	sd	s1,40(sp)
    80003e54:	f04a                	sd	s2,32(sp)
    80003e56:	ec4e                	sd	s3,24(sp)
    80003e58:	e852                	sd	s4,16(sp)
    80003e5a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e5c:	04451703          	lh	a4,68(a0)
    80003e60:	4785                	li	a5,1
    80003e62:	00f71a63          	bne	a4,a5,80003e76 <dirlookup+0x2a>
    80003e66:	892a                	mv	s2,a0
    80003e68:	89ae                	mv	s3,a1
    80003e6a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e6c:	457c                	lw	a5,76(a0)
    80003e6e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e70:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e72:	e79d                	bnez	a5,80003ea0 <dirlookup+0x54>
    80003e74:	a8a5                	j	80003eec <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e76:	00004517          	auipc	a0,0x4
    80003e7a:	78a50513          	addi	a0,a0,1930 # 80008600 <syscalls+0x1b8>
    80003e7e:	ffffc097          	auipc	ra,0xffffc
    80003e82:	6ba080e7          	jalr	1722(ra) # 80000538 <panic>
      panic("dirlookup read");
    80003e86:	00004517          	auipc	a0,0x4
    80003e8a:	79250513          	addi	a0,a0,1938 # 80008618 <syscalls+0x1d0>
    80003e8e:	ffffc097          	auipc	ra,0xffffc
    80003e92:	6aa080e7          	jalr	1706(ra) # 80000538 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e96:	24c1                	addiw	s1,s1,16
    80003e98:	04c92783          	lw	a5,76(s2)
    80003e9c:	04f4f763          	bgeu	s1,a5,80003eea <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ea0:	4741                	li	a4,16
    80003ea2:	86a6                	mv	a3,s1
    80003ea4:	fc040613          	addi	a2,s0,-64
    80003ea8:	4581                	li	a1,0
    80003eaa:	854a                	mv	a0,s2
    80003eac:	00000097          	auipc	ra,0x0
    80003eb0:	d70080e7          	jalr	-656(ra) # 80003c1c <readi>
    80003eb4:	47c1                	li	a5,16
    80003eb6:	fcf518e3          	bne	a0,a5,80003e86 <dirlookup+0x3a>
    if(de.inum == 0)
    80003eba:	fc045783          	lhu	a5,-64(s0)
    80003ebe:	dfe1                	beqz	a5,80003e96 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003ec0:	fc240593          	addi	a1,s0,-62
    80003ec4:	854e                	mv	a0,s3
    80003ec6:	00000097          	auipc	ra,0x0
    80003eca:	f6c080e7          	jalr	-148(ra) # 80003e32 <namecmp>
    80003ece:	f561                	bnez	a0,80003e96 <dirlookup+0x4a>
      if(poff)
    80003ed0:	000a0463          	beqz	s4,80003ed8 <dirlookup+0x8c>
        *poff = off;
    80003ed4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003ed8:	fc045583          	lhu	a1,-64(s0)
    80003edc:	00092503          	lw	a0,0(s2)
    80003ee0:	fffff097          	auipc	ra,0xfffff
    80003ee4:	534080e7          	jalr	1332(ra) # 80003414 <iget>
    80003ee8:	a011                	j	80003eec <dirlookup+0xa0>
  return 0;
    80003eea:	4501                	li	a0,0
}
    80003eec:	70e2                	ld	ra,56(sp)
    80003eee:	7442                	ld	s0,48(sp)
    80003ef0:	74a2                	ld	s1,40(sp)
    80003ef2:	7902                	ld	s2,32(sp)
    80003ef4:	69e2                	ld	s3,24(sp)
    80003ef6:	6a42                	ld	s4,16(sp)
    80003ef8:	6121                	addi	sp,sp,64
    80003efa:	8082                	ret

0000000080003efc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003efc:	711d                	addi	sp,sp,-96
    80003efe:	ec86                	sd	ra,88(sp)
    80003f00:	e8a2                	sd	s0,80(sp)
    80003f02:	e4a6                	sd	s1,72(sp)
    80003f04:	e0ca                	sd	s2,64(sp)
    80003f06:	fc4e                	sd	s3,56(sp)
    80003f08:	f852                	sd	s4,48(sp)
    80003f0a:	f456                	sd	s5,40(sp)
    80003f0c:	f05a                	sd	s6,32(sp)
    80003f0e:	ec5e                	sd	s7,24(sp)
    80003f10:	e862                	sd	s8,16(sp)
    80003f12:	e466                	sd	s9,8(sp)
    80003f14:	1080                	addi	s0,sp,96
    80003f16:	84aa                	mv	s1,a0
    80003f18:	8aae                	mv	s5,a1
    80003f1a:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003f1c:	00054703          	lbu	a4,0(a0)
    80003f20:	02f00793          	li	a5,47
    80003f24:	02f70363          	beq	a4,a5,80003f4a <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003f28:	ffffe097          	auipc	ra,0xffffe
    80003f2c:	ada080e7          	jalr	-1318(ra) # 80001a02 <myproc>
    80003f30:	15053503          	ld	a0,336(a0)
    80003f34:	00000097          	auipc	ra,0x0
    80003f38:	9f6080e7          	jalr	-1546(ra) # 8000392a <idup>
    80003f3c:	89aa                	mv	s3,a0
  while(*path == '/')
    80003f3e:	02f00913          	li	s2,47
  len = path - s;
    80003f42:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003f44:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003f46:	4b85                	li	s7,1
    80003f48:	a865                	j	80004000 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003f4a:	4585                	li	a1,1
    80003f4c:	4505                	li	a0,1
    80003f4e:	fffff097          	auipc	ra,0xfffff
    80003f52:	4c6080e7          	jalr	1222(ra) # 80003414 <iget>
    80003f56:	89aa                	mv	s3,a0
    80003f58:	b7dd                	j	80003f3e <namex+0x42>
      iunlockput(ip);
    80003f5a:	854e                	mv	a0,s3
    80003f5c:	00000097          	auipc	ra,0x0
    80003f60:	c6e080e7          	jalr	-914(ra) # 80003bca <iunlockput>
      return 0;
    80003f64:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f66:	854e                	mv	a0,s3
    80003f68:	60e6                	ld	ra,88(sp)
    80003f6a:	6446                	ld	s0,80(sp)
    80003f6c:	64a6                	ld	s1,72(sp)
    80003f6e:	6906                	ld	s2,64(sp)
    80003f70:	79e2                	ld	s3,56(sp)
    80003f72:	7a42                	ld	s4,48(sp)
    80003f74:	7aa2                	ld	s5,40(sp)
    80003f76:	7b02                	ld	s6,32(sp)
    80003f78:	6be2                	ld	s7,24(sp)
    80003f7a:	6c42                	ld	s8,16(sp)
    80003f7c:	6ca2                	ld	s9,8(sp)
    80003f7e:	6125                	addi	sp,sp,96
    80003f80:	8082                	ret
      iunlock(ip);
    80003f82:	854e                	mv	a0,s3
    80003f84:	00000097          	auipc	ra,0x0
    80003f88:	aa6080e7          	jalr	-1370(ra) # 80003a2a <iunlock>
      return ip;
    80003f8c:	bfe9                	j	80003f66 <namex+0x6a>
      iunlockput(ip);
    80003f8e:	854e                	mv	a0,s3
    80003f90:	00000097          	auipc	ra,0x0
    80003f94:	c3a080e7          	jalr	-966(ra) # 80003bca <iunlockput>
      return 0;
    80003f98:	89e6                	mv	s3,s9
    80003f9a:	b7f1                	j	80003f66 <namex+0x6a>
  len = path - s;
    80003f9c:	40b48633          	sub	a2,s1,a1
    80003fa0:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003fa4:	099c5463          	bge	s8,s9,8000402c <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003fa8:	4639                	li	a2,14
    80003faa:	8552                	mv	a0,s4
    80003fac:	ffffd097          	auipc	ra,0xffffd
    80003fb0:	d7c080e7          	jalr	-644(ra) # 80000d28 <memmove>
  while(*path == '/')
    80003fb4:	0004c783          	lbu	a5,0(s1)
    80003fb8:	01279763          	bne	a5,s2,80003fc6 <namex+0xca>
    path++;
    80003fbc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fbe:	0004c783          	lbu	a5,0(s1)
    80003fc2:	ff278de3          	beq	a5,s2,80003fbc <namex+0xc0>
    ilock(ip);
    80003fc6:	854e                	mv	a0,s3
    80003fc8:	00000097          	auipc	ra,0x0
    80003fcc:	9a0080e7          	jalr	-1632(ra) # 80003968 <ilock>
    if(ip->type != T_DIR){
    80003fd0:	04499783          	lh	a5,68(s3)
    80003fd4:	f97793e3          	bne	a5,s7,80003f5a <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003fd8:	000a8563          	beqz	s5,80003fe2 <namex+0xe6>
    80003fdc:	0004c783          	lbu	a5,0(s1)
    80003fe0:	d3cd                	beqz	a5,80003f82 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003fe2:	865a                	mv	a2,s6
    80003fe4:	85d2                	mv	a1,s4
    80003fe6:	854e                	mv	a0,s3
    80003fe8:	00000097          	auipc	ra,0x0
    80003fec:	e64080e7          	jalr	-412(ra) # 80003e4c <dirlookup>
    80003ff0:	8caa                	mv	s9,a0
    80003ff2:	dd51                	beqz	a0,80003f8e <namex+0x92>
    iunlockput(ip);
    80003ff4:	854e                	mv	a0,s3
    80003ff6:	00000097          	auipc	ra,0x0
    80003ffa:	bd4080e7          	jalr	-1068(ra) # 80003bca <iunlockput>
    ip = next;
    80003ffe:	89e6                	mv	s3,s9
  while(*path == '/')
    80004000:	0004c783          	lbu	a5,0(s1)
    80004004:	05279763          	bne	a5,s2,80004052 <namex+0x156>
    path++;
    80004008:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000400a:	0004c783          	lbu	a5,0(s1)
    8000400e:	ff278de3          	beq	a5,s2,80004008 <namex+0x10c>
  if(*path == 0)
    80004012:	c79d                	beqz	a5,80004040 <namex+0x144>
    path++;
    80004014:	85a6                	mv	a1,s1
  len = path - s;
    80004016:	8cda                	mv	s9,s6
    80004018:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    8000401a:	01278963          	beq	a5,s2,8000402c <namex+0x130>
    8000401e:	dfbd                	beqz	a5,80003f9c <namex+0xa0>
    path++;
    80004020:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004022:	0004c783          	lbu	a5,0(s1)
    80004026:	ff279ce3          	bne	a5,s2,8000401e <namex+0x122>
    8000402a:	bf8d                	j	80003f9c <namex+0xa0>
    memmove(name, s, len);
    8000402c:	2601                	sext.w	a2,a2
    8000402e:	8552                	mv	a0,s4
    80004030:	ffffd097          	auipc	ra,0xffffd
    80004034:	cf8080e7          	jalr	-776(ra) # 80000d28 <memmove>
    name[len] = 0;
    80004038:	9cd2                	add	s9,s9,s4
    8000403a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000403e:	bf9d                	j	80003fb4 <namex+0xb8>
  if(nameiparent){
    80004040:	f20a83e3          	beqz	s5,80003f66 <namex+0x6a>
    iput(ip);
    80004044:	854e                	mv	a0,s3
    80004046:	00000097          	auipc	ra,0x0
    8000404a:	adc080e7          	jalr	-1316(ra) # 80003b22 <iput>
    return 0;
    8000404e:	4981                	li	s3,0
    80004050:	bf19                	j	80003f66 <namex+0x6a>
  if(*path == 0)
    80004052:	d7fd                	beqz	a5,80004040 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004054:	0004c783          	lbu	a5,0(s1)
    80004058:	85a6                	mv	a1,s1
    8000405a:	b7d1                	j	8000401e <namex+0x122>

000000008000405c <dirlink>:
{
    8000405c:	7139                	addi	sp,sp,-64
    8000405e:	fc06                	sd	ra,56(sp)
    80004060:	f822                	sd	s0,48(sp)
    80004062:	f426                	sd	s1,40(sp)
    80004064:	f04a                	sd	s2,32(sp)
    80004066:	ec4e                	sd	s3,24(sp)
    80004068:	e852                	sd	s4,16(sp)
    8000406a:	0080                	addi	s0,sp,64
    8000406c:	892a                	mv	s2,a0
    8000406e:	8a2e                	mv	s4,a1
    80004070:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004072:	4601                	li	a2,0
    80004074:	00000097          	auipc	ra,0x0
    80004078:	dd8080e7          	jalr	-552(ra) # 80003e4c <dirlookup>
    8000407c:	e93d                	bnez	a0,800040f2 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000407e:	04c92483          	lw	s1,76(s2)
    80004082:	c49d                	beqz	s1,800040b0 <dirlink+0x54>
    80004084:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004086:	4741                	li	a4,16
    80004088:	86a6                	mv	a3,s1
    8000408a:	fc040613          	addi	a2,s0,-64
    8000408e:	4581                	li	a1,0
    80004090:	854a                	mv	a0,s2
    80004092:	00000097          	auipc	ra,0x0
    80004096:	b8a080e7          	jalr	-1142(ra) # 80003c1c <readi>
    8000409a:	47c1                	li	a5,16
    8000409c:	06f51163          	bne	a0,a5,800040fe <dirlink+0xa2>
    if(de.inum == 0)
    800040a0:	fc045783          	lhu	a5,-64(s0)
    800040a4:	c791                	beqz	a5,800040b0 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040a6:	24c1                	addiw	s1,s1,16
    800040a8:	04c92783          	lw	a5,76(s2)
    800040ac:	fcf4ede3          	bltu	s1,a5,80004086 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800040b0:	4639                	li	a2,14
    800040b2:	85d2                	mv	a1,s4
    800040b4:	fc240513          	addi	a0,s0,-62
    800040b8:	ffffd097          	auipc	ra,0xffffd
    800040bc:	d20080e7          	jalr	-736(ra) # 80000dd8 <strncpy>
  de.inum = inum;
    800040c0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040c4:	4741                	li	a4,16
    800040c6:	86a6                	mv	a3,s1
    800040c8:	fc040613          	addi	a2,s0,-64
    800040cc:	4581                	li	a1,0
    800040ce:	854a                	mv	a0,s2
    800040d0:	00000097          	auipc	ra,0x0
    800040d4:	c44080e7          	jalr	-956(ra) # 80003d14 <writei>
    800040d8:	872a                	mv	a4,a0
    800040da:	47c1                	li	a5,16
  return 0;
    800040dc:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040de:	02f71863          	bne	a4,a5,8000410e <dirlink+0xb2>
}
    800040e2:	70e2                	ld	ra,56(sp)
    800040e4:	7442                	ld	s0,48(sp)
    800040e6:	74a2                	ld	s1,40(sp)
    800040e8:	7902                	ld	s2,32(sp)
    800040ea:	69e2                	ld	s3,24(sp)
    800040ec:	6a42                	ld	s4,16(sp)
    800040ee:	6121                	addi	sp,sp,64
    800040f0:	8082                	ret
    iput(ip);
    800040f2:	00000097          	auipc	ra,0x0
    800040f6:	a30080e7          	jalr	-1488(ra) # 80003b22 <iput>
    return -1;
    800040fa:	557d                	li	a0,-1
    800040fc:	b7dd                	j	800040e2 <dirlink+0x86>
      panic("dirlink read");
    800040fe:	00004517          	auipc	a0,0x4
    80004102:	52a50513          	addi	a0,a0,1322 # 80008628 <syscalls+0x1e0>
    80004106:	ffffc097          	auipc	ra,0xffffc
    8000410a:	432080e7          	jalr	1074(ra) # 80000538 <panic>
    panic("dirlink");
    8000410e:	00004517          	auipc	a0,0x4
    80004112:	62a50513          	addi	a0,a0,1578 # 80008738 <syscalls+0x2f0>
    80004116:	ffffc097          	auipc	ra,0xffffc
    8000411a:	422080e7          	jalr	1058(ra) # 80000538 <panic>

000000008000411e <namei>:

struct inode*
namei(char *path)
{
    8000411e:	1101                	addi	sp,sp,-32
    80004120:	ec06                	sd	ra,24(sp)
    80004122:	e822                	sd	s0,16(sp)
    80004124:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004126:	fe040613          	addi	a2,s0,-32
    8000412a:	4581                	li	a1,0
    8000412c:	00000097          	auipc	ra,0x0
    80004130:	dd0080e7          	jalr	-560(ra) # 80003efc <namex>
}
    80004134:	60e2                	ld	ra,24(sp)
    80004136:	6442                	ld	s0,16(sp)
    80004138:	6105                	addi	sp,sp,32
    8000413a:	8082                	ret

000000008000413c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000413c:	1141                	addi	sp,sp,-16
    8000413e:	e406                	sd	ra,8(sp)
    80004140:	e022                	sd	s0,0(sp)
    80004142:	0800                	addi	s0,sp,16
    80004144:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004146:	4585                	li	a1,1
    80004148:	00000097          	auipc	ra,0x0
    8000414c:	db4080e7          	jalr	-588(ra) # 80003efc <namex>
}
    80004150:	60a2                	ld	ra,8(sp)
    80004152:	6402                	ld	s0,0(sp)
    80004154:	0141                	addi	sp,sp,16
    80004156:	8082                	ret

0000000080004158 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004158:	1101                	addi	sp,sp,-32
    8000415a:	ec06                	sd	ra,24(sp)
    8000415c:	e822                	sd	s0,16(sp)
    8000415e:	e426                	sd	s1,8(sp)
    80004160:	e04a                	sd	s2,0(sp)
    80004162:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004164:	0001e917          	auipc	s2,0x1e
    80004168:	ccc90913          	addi	s2,s2,-820 # 80021e30 <log>
    8000416c:	01892583          	lw	a1,24(s2)
    80004170:	02892503          	lw	a0,40(s2)
    80004174:	fffff097          	auipc	ra,0xfffff
    80004178:	fde080e7          	jalr	-34(ra) # 80003152 <bread>
    8000417c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000417e:	02c92683          	lw	a3,44(s2)
    80004182:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004184:	02d05763          	blez	a3,800041b2 <write_head+0x5a>
    80004188:	0001e797          	auipc	a5,0x1e
    8000418c:	cd878793          	addi	a5,a5,-808 # 80021e60 <log+0x30>
    80004190:	05c50713          	addi	a4,a0,92
    80004194:	36fd                	addiw	a3,a3,-1
    80004196:	1682                	slli	a3,a3,0x20
    80004198:	9281                	srli	a3,a3,0x20
    8000419a:	068a                	slli	a3,a3,0x2
    8000419c:	0001e617          	auipc	a2,0x1e
    800041a0:	cc860613          	addi	a2,a2,-824 # 80021e64 <log+0x34>
    800041a4:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800041a6:	4390                	lw	a2,0(a5)
    800041a8:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041aa:	0791                	addi	a5,a5,4
    800041ac:	0711                	addi	a4,a4,4
    800041ae:	fed79ce3          	bne	a5,a3,800041a6 <write_head+0x4e>
  }
  bwrite(buf);
    800041b2:	8526                	mv	a0,s1
    800041b4:	fffff097          	auipc	ra,0xfffff
    800041b8:	090080e7          	jalr	144(ra) # 80003244 <bwrite>
  brelse(buf);
    800041bc:	8526                	mv	a0,s1
    800041be:	fffff097          	auipc	ra,0xfffff
    800041c2:	0c4080e7          	jalr	196(ra) # 80003282 <brelse>
}
    800041c6:	60e2                	ld	ra,24(sp)
    800041c8:	6442                	ld	s0,16(sp)
    800041ca:	64a2                	ld	s1,8(sp)
    800041cc:	6902                	ld	s2,0(sp)
    800041ce:	6105                	addi	sp,sp,32
    800041d0:	8082                	ret

00000000800041d2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800041d2:	0001e797          	auipc	a5,0x1e
    800041d6:	c8a7a783          	lw	a5,-886(a5) # 80021e5c <log+0x2c>
    800041da:	0af05d63          	blez	a5,80004294 <install_trans+0xc2>
{
    800041de:	7139                	addi	sp,sp,-64
    800041e0:	fc06                	sd	ra,56(sp)
    800041e2:	f822                	sd	s0,48(sp)
    800041e4:	f426                	sd	s1,40(sp)
    800041e6:	f04a                	sd	s2,32(sp)
    800041e8:	ec4e                	sd	s3,24(sp)
    800041ea:	e852                	sd	s4,16(sp)
    800041ec:	e456                	sd	s5,8(sp)
    800041ee:	e05a                	sd	s6,0(sp)
    800041f0:	0080                	addi	s0,sp,64
    800041f2:	8b2a                	mv	s6,a0
    800041f4:	0001ea97          	auipc	s5,0x1e
    800041f8:	c6ca8a93          	addi	s5,s5,-916 # 80021e60 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041fc:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041fe:	0001e997          	auipc	s3,0x1e
    80004202:	c3298993          	addi	s3,s3,-974 # 80021e30 <log>
    80004206:	a00d                	j	80004228 <install_trans+0x56>
    brelse(lbuf);
    80004208:	854a                	mv	a0,s2
    8000420a:	fffff097          	auipc	ra,0xfffff
    8000420e:	078080e7          	jalr	120(ra) # 80003282 <brelse>
    brelse(dbuf);
    80004212:	8526                	mv	a0,s1
    80004214:	fffff097          	auipc	ra,0xfffff
    80004218:	06e080e7          	jalr	110(ra) # 80003282 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000421c:	2a05                	addiw	s4,s4,1
    8000421e:	0a91                	addi	s5,s5,4
    80004220:	02c9a783          	lw	a5,44(s3)
    80004224:	04fa5e63          	bge	s4,a5,80004280 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004228:	0189a583          	lw	a1,24(s3)
    8000422c:	014585bb          	addw	a1,a1,s4
    80004230:	2585                	addiw	a1,a1,1
    80004232:	0289a503          	lw	a0,40(s3)
    80004236:	fffff097          	auipc	ra,0xfffff
    8000423a:	f1c080e7          	jalr	-228(ra) # 80003152 <bread>
    8000423e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004240:	000aa583          	lw	a1,0(s5)
    80004244:	0289a503          	lw	a0,40(s3)
    80004248:	fffff097          	auipc	ra,0xfffff
    8000424c:	f0a080e7          	jalr	-246(ra) # 80003152 <bread>
    80004250:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004252:	40000613          	li	a2,1024
    80004256:	05890593          	addi	a1,s2,88
    8000425a:	05850513          	addi	a0,a0,88
    8000425e:	ffffd097          	auipc	ra,0xffffd
    80004262:	aca080e7          	jalr	-1334(ra) # 80000d28 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004266:	8526                	mv	a0,s1
    80004268:	fffff097          	auipc	ra,0xfffff
    8000426c:	fdc080e7          	jalr	-36(ra) # 80003244 <bwrite>
    if(recovering == 0)
    80004270:	f80b1ce3          	bnez	s6,80004208 <install_trans+0x36>
      bunpin(dbuf);
    80004274:	8526                	mv	a0,s1
    80004276:	fffff097          	auipc	ra,0xfffff
    8000427a:	0e6080e7          	jalr	230(ra) # 8000335c <bunpin>
    8000427e:	b769                	j	80004208 <install_trans+0x36>
}
    80004280:	70e2                	ld	ra,56(sp)
    80004282:	7442                	ld	s0,48(sp)
    80004284:	74a2                	ld	s1,40(sp)
    80004286:	7902                	ld	s2,32(sp)
    80004288:	69e2                	ld	s3,24(sp)
    8000428a:	6a42                	ld	s4,16(sp)
    8000428c:	6aa2                	ld	s5,8(sp)
    8000428e:	6b02                	ld	s6,0(sp)
    80004290:	6121                	addi	sp,sp,64
    80004292:	8082                	ret
    80004294:	8082                	ret

0000000080004296 <initlog>:
{
    80004296:	7179                	addi	sp,sp,-48
    80004298:	f406                	sd	ra,40(sp)
    8000429a:	f022                	sd	s0,32(sp)
    8000429c:	ec26                	sd	s1,24(sp)
    8000429e:	e84a                	sd	s2,16(sp)
    800042a0:	e44e                	sd	s3,8(sp)
    800042a2:	1800                	addi	s0,sp,48
    800042a4:	892a                	mv	s2,a0
    800042a6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800042a8:	0001e497          	auipc	s1,0x1e
    800042ac:	b8848493          	addi	s1,s1,-1144 # 80021e30 <log>
    800042b0:	00004597          	auipc	a1,0x4
    800042b4:	38858593          	addi	a1,a1,904 # 80008638 <syscalls+0x1f0>
    800042b8:	8526                	mv	a0,s1
    800042ba:	ffffd097          	auipc	ra,0xffffd
    800042be:	886080e7          	jalr	-1914(ra) # 80000b40 <initlock>
  log.start = sb->logstart;
    800042c2:	0149a583          	lw	a1,20(s3)
    800042c6:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800042c8:	0109a783          	lw	a5,16(s3)
    800042cc:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800042ce:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800042d2:	854a                	mv	a0,s2
    800042d4:	fffff097          	auipc	ra,0xfffff
    800042d8:	e7e080e7          	jalr	-386(ra) # 80003152 <bread>
  log.lh.n = lh->n;
    800042dc:	4d34                	lw	a3,88(a0)
    800042de:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800042e0:	02d05563          	blez	a3,8000430a <initlog+0x74>
    800042e4:	05c50793          	addi	a5,a0,92
    800042e8:	0001e717          	auipc	a4,0x1e
    800042ec:	b7870713          	addi	a4,a4,-1160 # 80021e60 <log+0x30>
    800042f0:	36fd                	addiw	a3,a3,-1
    800042f2:	1682                	slli	a3,a3,0x20
    800042f4:	9281                	srli	a3,a3,0x20
    800042f6:	068a                	slli	a3,a3,0x2
    800042f8:	06050613          	addi	a2,a0,96
    800042fc:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800042fe:	4390                	lw	a2,0(a5)
    80004300:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004302:	0791                	addi	a5,a5,4
    80004304:	0711                	addi	a4,a4,4
    80004306:	fed79ce3          	bne	a5,a3,800042fe <initlog+0x68>
  brelse(buf);
    8000430a:	fffff097          	auipc	ra,0xfffff
    8000430e:	f78080e7          	jalr	-136(ra) # 80003282 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004312:	4505                	li	a0,1
    80004314:	00000097          	auipc	ra,0x0
    80004318:	ebe080e7          	jalr	-322(ra) # 800041d2 <install_trans>
  log.lh.n = 0;
    8000431c:	0001e797          	auipc	a5,0x1e
    80004320:	b407a023          	sw	zero,-1216(a5) # 80021e5c <log+0x2c>
  write_head(); // clear the log
    80004324:	00000097          	auipc	ra,0x0
    80004328:	e34080e7          	jalr	-460(ra) # 80004158 <write_head>
}
    8000432c:	70a2                	ld	ra,40(sp)
    8000432e:	7402                	ld	s0,32(sp)
    80004330:	64e2                	ld	s1,24(sp)
    80004332:	6942                	ld	s2,16(sp)
    80004334:	69a2                	ld	s3,8(sp)
    80004336:	6145                	addi	sp,sp,48
    80004338:	8082                	ret

000000008000433a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000433a:	1101                	addi	sp,sp,-32
    8000433c:	ec06                	sd	ra,24(sp)
    8000433e:	e822                	sd	s0,16(sp)
    80004340:	e426                	sd	s1,8(sp)
    80004342:	e04a                	sd	s2,0(sp)
    80004344:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004346:	0001e517          	auipc	a0,0x1e
    8000434a:	aea50513          	addi	a0,a0,-1302 # 80021e30 <log>
    8000434e:	ffffd097          	auipc	ra,0xffffd
    80004352:	882080e7          	jalr	-1918(ra) # 80000bd0 <acquire>
  while(1){
    if(log.committing){
    80004356:	0001e497          	auipc	s1,0x1e
    8000435a:	ada48493          	addi	s1,s1,-1318 # 80021e30 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000435e:	4979                	li	s2,30
    80004360:	a039                	j	8000436e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004362:	85a6                	mv	a1,s1
    80004364:	8526                	mv	a0,s1
    80004366:	ffffe097          	auipc	ra,0xffffe
    8000436a:	074080e7          	jalr	116(ra) # 800023da <sleep>
    if(log.committing){
    8000436e:	50dc                	lw	a5,36(s1)
    80004370:	fbed                	bnez	a5,80004362 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004372:	509c                	lw	a5,32(s1)
    80004374:	0017871b          	addiw	a4,a5,1
    80004378:	0007069b          	sext.w	a3,a4
    8000437c:	0027179b          	slliw	a5,a4,0x2
    80004380:	9fb9                	addw	a5,a5,a4
    80004382:	0017979b          	slliw	a5,a5,0x1
    80004386:	54d8                	lw	a4,44(s1)
    80004388:	9fb9                	addw	a5,a5,a4
    8000438a:	00f95963          	bge	s2,a5,8000439c <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000438e:	85a6                	mv	a1,s1
    80004390:	8526                	mv	a0,s1
    80004392:	ffffe097          	auipc	ra,0xffffe
    80004396:	048080e7          	jalr	72(ra) # 800023da <sleep>
    8000439a:	bfd1                	j	8000436e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000439c:	0001e517          	auipc	a0,0x1e
    800043a0:	a9450513          	addi	a0,a0,-1388 # 80021e30 <log>
    800043a4:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800043a6:	ffffd097          	auipc	ra,0xffffd
    800043aa:	8de080e7          	jalr	-1826(ra) # 80000c84 <release>
      break;
    }
  }
}
    800043ae:	60e2                	ld	ra,24(sp)
    800043b0:	6442                	ld	s0,16(sp)
    800043b2:	64a2                	ld	s1,8(sp)
    800043b4:	6902                	ld	s2,0(sp)
    800043b6:	6105                	addi	sp,sp,32
    800043b8:	8082                	ret

00000000800043ba <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800043ba:	7139                	addi	sp,sp,-64
    800043bc:	fc06                	sd	ra,56(sp)
    800043be:	f822                	sd	s0,48(sp)
    800043c0:	f426                	sd	s1,40(sp)
    800043c2:	f04a                	sd	s2,32(sp)
    800043c4:	ec4e                	sd	s3,24(sp)
    800043c6:	e852                	sd	s4,16(sp)
    800043c8:	e456                	sd	s5,8(sp)
    800043ca:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800043cc:	0001e497          	auipc	s1,0x1e
    800043d0:	a6448493          	addi	s1,s1,-1436 # 80021e30 <log>
    800043d4:	8526                	mv	a0,s1
    800043d6:	ffffc097          	auipc	ra,0xffffc
    800043da:	7fa080e7          	jalr	2042(ra) # 80000bd0 <acquire>
  log.outstanding -= 1;
    800043de:	509c                	lw	a5,32(s1)
    800043e0:	37fd                	addiw	a5,a5,-1
    800043e2:	0007891b          	sext.w	s2,a5
    800043e6:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800043e8:	50dc                	lw	a5,36(s1)
    800043ea:	e7b9                	bnez	a5,80004438 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800043ec:	04091e63          	bnez	s2,80004448 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800043f0:	0001e497          	auipc	s1,0x1e
    800043f4:	a4048493          	addi	s1,s1,-1472 # 80021e30 <log>
    800043f8:	4785                	li	a5,1
    800043fa:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043fc:	8526                	mv	a0,s1
    800043fe:	ffffd097          	auipc	ra,0xffffd
    80004402:	886080e7          	jalr	-1914(ra) # 80000c84 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004406:	54dc                	lw	a5,44(s1)
    80004408:	06f04763          	bgtz	a5,80004476 <end_op+0xbc>
    acquire(&log.lock);
    8000440c:	0001e497          	auipc	s1,0x1e
    80004410:	a2448493          	addi	s1,s1,-1500 # 80021e30 <log>
    80004414:	8526                	mv	a0,s1
    80004416:	ffffc097          	auipc	ra,0xffffc
    8000441a:	7ba080e7          	jalr	1978(ra) # 80000bd0 <acquire>
    log.committing = 0;
    8000441e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004422:	8526                	mv	a0,s1
    80004424:	ffffe097          	auipc	ra,0xffffe
    80004428:	142080e7          	jalr	322(ra) # 80002566 <wakeup>
    release(&log.lock);
    8000442c:	8526                	mv	a0,s1
    8000442e:	ffffd097          	auipc	ra,0xffffd
    80004432:	856080e7          	jalr	-1962(ra) # 80000c84 <release>
}
    80004436:	a03d                	j	80004464 <end_op+0xaa>
    panic("log.committing");
    80004438:	00004517          	auipc	a0,0x4
    8000443c:	20850513          	addi	a0,a0,520 # 80008640 <syscalls+0x1f8>
    80004440:	ffffc097          	auipc	ra,0xffffc
    80004444:	0f8080e7          	jalr	248(ra) # 80000538 <panic>
    wakeup(&log);
    80004448:	0001e497          	auipc	s1,0x1e
    8000444c:	9e848493          	addi	s1,s1,-1560 # 80021e30 <log>
    80004450:	8526                	mv	a0,s1
    80004452:	ffffe097          	auipc	ra,0xffffe
    80004456:	114080e7          	jalr	276(ra) # 80002566 <wakeup>
  release(&log.lock);
    8000445a:	8526                	mv	a0,s1
    8000445c:	ffffd097          	auipc	ra,0xffffd
    80004460:	828080e7          	jalr	-2008(ra) # 80000c84 <release>
}
    80004464:	70e2                	ld	ra,56(sp)
    80004466:	7442                	ld	s0,48(sp)
    80004468:	74a2                	ld	s1,40(sp)
    8000446a:	7902                	ld	s2,32(sp)
    8000446c:	69e2                	ld	s3,24(sp)
    8000446e:	6a42                	ld	s4,16(sp)
    80004470:	6aa2                	ld	s5,8(sp)
    80004472:	6121                	addi	sp,sp,64
    80004474:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004476:	0001ea97          	auipc	s5,0x1e
    8000447a:	9eaa8a93          	addi	s5,s5,-1558 # 80021e60 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000447e:	0001ea17          	auipc	s4,0x1e
    80004482:	9b2a0a13          	addi	s4,s4,-1614 # 80021e30 <log>
    80004486:	018a2583          	lw	a1,24(s4)
    8000448a:	012585bb          	addw	a1,a1,s2
    8000448e:	2585                	addiw	a1,a1,1
    80004490:	028a2503          	lw	a0,40(s4)
    80004494:	fffff097          	auipc	ra,0xfffff
    80004498:	cbe080e7          	jalr	-834(ra) # 80003152 <bread>
    8000449c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000449e:	000aa583          	lw	a1,0(s5)
    800044a2:	028a2503          	lw	a0,40(s4)
    800044a6:	fffff097          	auipc	ra,0xfffff
    800044aa:	cac080e7          	jalr	-852(ra) # 80003152 <bread>
    800044ae:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800044b0:	40000613          	li	a2,1024
    800044b4:	05850593          	addi	a1,a0,88
    800044b8:	05848513          	addi	a0,s1,88
    800044bc:	ffffd097          	auipc	ra,0xffffd
    800044c0:	86c080e7          	jalr	-1940(ra) # 80000d28 <memmove>
    bwrite(to);  // write the log
    800044c4:	8526                	mv	a0,s1
    800044c6:	fffff097          	auipc	ra,0xfffff
    800044ca:	d7e080e7          	jalr	-642(ra) # 80003244 <bwrite>
    brelse(from);
    800044ce:	854e                	mv	a0,s3
    800044d0:	fffff097          	auipc	ra,0xfffff
    800044d4:	db2080e7          	jalr	-590(ra) # 80003282 <brelse>
    brelse(to);
    800044d8:	8526                	mv	a0,s1
    800044da:	fffff097          	auipc	ra,0xfffff
    800044de:	da8080e7          	jalr	-600(ra) # 80003282 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800044e2:	2905                	addiw	s2,s2,1
    800044e4:	0a91                	addi	s5,s5,4
    800044e6:	02ca2783          	lw	a5,44(s4)
    800044ea:	f8f94ee3          	blt	s2,a5,80004486 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800044ee:	00000097          	auipc	ra,0x0
    800044f2:	c6a080e7          	jalr	-918(ra) # 80004158 <write_head>
    install_trans(0); // Now install writes to home locations
    800044f6:	4501                	li	a0,0
    800044f8:	00000097          	auipc	ra,0x0
    800044fc:	cda080e7          	jalr	-806(ra) # 800041d2 <install_trans>
    log.lh.n = 0;
    80004500:	0001e797          	auipc	a5,0x1e
    80004504:	9407ae23          	sw	zero,-1700(a5) # 80021e5c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004508:	00000097          	auipc	ra,0x0
    8000450c:	c50080e7          	jalr	-944(ra) # 80004158 <write_head>
    80004510:	bdf5                	j	8000440c <end_op+0x52>

0000000080004512 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004512:	1101                	addi	sp,sp,-32
    80004514:	ec06                	sd	ra,24(sp)
    80004516:	e822                	sd	s0,16(sp)
    80004518:	e426                	sd	s1,8(sp)
    8000451a:	e04a                	sd	s2,0(sp)
    8000451c:	1000                	addi	s0,sp,32
    8000451e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004520:	0001e917          	auipc	s2,0x1e
    80004524:	91090913          	addi	s2,s2,-1776 # 80021e30 <log>
    80004528:	854a                	mv	a0,s2
    8000452a:	ffffc097          	auipc	ra,0xffffc
    8000452e:	6a6080e7          	jalr	1702(ra) # 80000bd0 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004532:	02c92603          	lw	a2,44(s2)
    80004536:	47f5                	li	a5,29
    80004538:	06c7c563          	blt	a5,a2,800045a2 <log_write+0x90>
    8000453c:	0001e797          	auipc	a5,0x1e
    80004540:	9107a783          	lw	a5,-1776(a5) # 80021e4c <log+0x1c>
    80004544:	37fd                	addiw	a5,a5,-1
    80004546:	04f65e63          	bge	a2,a5,800045a2 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000454a:	0001e797          	auipc	a5,0x1e
    8000454e:	9067a783          	lw	a5,-1786(a5) # 80021e50 <log+0x20>
    80004552:	06f05063          	blez	a5,800045b2 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004556:	4781                	li	a5,0
    80004558:	06c05563          	blez	a2,800045c2 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000455c:	44cc                	lw	a1,12(s1)
    8000455e:	0001e717          	auipc	a4,0x1e
    80004562:	90270713          	addi	a4,a4,-1790 # 80021e60 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004566:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004568:	4314                	lw	a3,0(a4)
    8000456a:	04b68c63          	beq	a3,a1,800045c2 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000456e:	2785                	addiw	a5,a5,1
    80004570:	0711                	addi	a4,a4,4
    80004572:	fef61be3          	bne	a2,a5,80004568 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004576:	0621                	addi	a2,a2,8
    80004578:	060a                	slli	a2,a2,0x2
    8000457a:	0001e797          	auipc	a5,0x1e
    8000457e:	8b678793          	addi	a5,a5,-1866 # 80021e30 <log>
    80004582:	963e                	add	a2,a2,a5
    80004584:	44dc                	lw	a5,12(s1)
    80004586:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004588:	8526                	mv	a0,s1
    8000458a:	fffff097          	auipc	ra,0xfffff
    8000458e:	d96080e7          	jalr	-618(ra) # 80003320 <bpin>
    log.lh.n++;
    80004592:	0001e717          	auipc	a4,0x1e
    80004596:	89e70713          	addi	a4,a4,-1890 # 80021e30 <log>
    8000459a:	575c                	lw	a5,44(a4)
    8000459c:	2785                	addiw	a5,a5,1
    8000459e:	d75c                	sw	a5,44(a4)
    800045a0:	a835                	j	800045dc <log_write+0xca>
    panic("too big a transaction");
    800045a2:	00004517          	auipc	a0,0x4
    800045a6:	0ae50513          	addi	a0,a0,174 # 80008650 <syscalls+0x208>
    800045aa:	ffffc097          	auipc	ra,0xffffc
    800045ae:	f8e080e7          	jalr	-114(ra) # 80000538 <panic>
    panic("log_write outside of trans");
    800045b2:	00004517          	auipc	a0,0x4
    800045b6:	0b650513          	addi	a0,a0,182 # 80008668 <syscalls+0x220>
    800045ba:	ffffc097          	auipc	ra,0xffffc
    800045be:	f7e080e7          	jalr	-130(ra) # 80000538 <panic>
  log.lh.block[i] = b->blockno;
    800045c2:	00878713          	addi	a4,a5,8
    800045c6:	00271693          	slli	a3,a4,0x2
    800045ca:	0001e717          	auipc	a4,0x1e
    800045ce:	86670713          	addi	a4,a4,-1946 # 80021e30 <log>
    800045d2:	9736                	add	a4,a4,a3
    800045d4:	44d4                	lw	a3,12(s1)
    800045d6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800045d8:	faf608e3          	beq	a2,a5,80004588 <log_write+0x76>
  }
  release(&log.lock);
    800045dc:	0001e517          	auipc	a0,0x1e
    800045e0:	85450513          	addi	a0,a0,-1964 # 80021e30 <log>
    800045e4:	ffffc097          	auipc	ra,0xffffc
    800045e8:	6a0080e7          	jalr	1696(ra) # 80000c84 <release>
}
    800045ec:	60e2                	ld	ra,24(sp)
    800045ee:	6442                	ld	s0,16(sp)
    800045f0:	64a2                	ld	s1,8(sp)
    800045f2:	6902                	ld	s2,0(sp)
    800045f4:	6105                	addi	sp,sp,32
    800045f6:	8082                	ret

00000000800045f8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045f8:	1101                	addi	sp,sp,-32
    800045fa:	ec06                	sd	ra,24(sp)
    800045fc:	e822                	sd	s0,16(sp)
    800045fe:	e426                	sd	s1,8(sp)
    80004600:	e04a                	sd	s2,0(sp)
    80004602:	1000                	addi	s0,sp,32
    80004604:	84aa                	mv	s1,a0
    80004606:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004608:	00004597          	auipc	a1,0x4
    8000460c:	08058593          	addi	a1,a1,128 # 80008688 <syscalls+0x240>
    80004610:	0521                	addi	a0,a0,8
    80004612:	ffffc097          	auipc	ra,0xffffc
    80004616:	52e080e7          	jalr	1326(ra) # 80000b40 <initlock>
  lk->name = name;
    8000461a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000461e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004622:	0204a423          	sw	zero,40(s1)
}
    80004626:	60e2                	ld	ra,24(sp)
    80004628:	6442                	ld	s0,16(sp)
    8000462a:	64a2                	ld	s1,8(sp)
    8000462c:	6902                	ld	s2,0(sp)
    8000462e:	6105                	addi	sp,sp,32
    80004630:	8082                	ret

0000000080004632 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004632:	1101                	addi	sp,sp,-32
    80004634:	ec06                	sd	ra,24(sp)
    80004636:	e822                	sd	s0,16(sp)
    80004638:	e426                	sd	s1,8(sp)
    8000463a:	e04a                	sd	s2,0(sp)
    8000463c:	1000                	addi	s0,sp,32
    8000463e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004640:	00850913          	addi	s2,a0,8
    80004644:	854a                	mv	a0,s2
    80004646:	ffffc097          	auipc	ra,0xffffc
    8000464a:	58a080e7          	jalr	1418(ra) # 80000bd0 <acquire>
  while (lk->locked) {
    8000464e:	409c                	lw	a5,0(s1)
    80004650:	cb89                	beqz	a5,80004662 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004652:	85ca                	mv	a1,s2
    80004654:	8526                	mv	a0,s1
    80004656:	ffffe097          	auipc	ra,0xffffe
    8000465a:	d84080e7          	jalr	-636(ra) # 800023da <sleep>
  while (lk->locked) {
    8000465e:	409c                	lw	a5,0(s1)
    80004660:	fbed                	bnez	a5,80004652 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004662:	4785                	li	a5,1
    80004664:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004666:	ffffd097          	auipc	ra,0xffffd
    8000466a:	39c080e7          	jalr	924(ra) # 80001a02 <myproc>
    8000466e:	591c                	lw	a5,48(a0)
    80004670:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004672:	854a                	mv	a0,s2
    80004674:	ffffc097          	auipc	ra,0xffffc
    80004678:	610080e7          	jalr	1552(ra) # 80000c84 <release>
}
    8000467c:	60e2                	ld	ra,24(sp)
    8000467e:	6442                	ld	s0,16(sp)
    80004680:	64a2                	ld	s1,8(sp)
    80004682:	6902                	ld	s2,0(sp)
    80004684:	6105                	addi	sp,sp,32
    80004686:	8082                	ret

0000000080004688 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004688:	1101                	addi	sp,sp,-32
    8000468a:	ec06                	sd	ra,24(sp)
    8000468c:	e822                	sd	s0,16(sp)
    8000468e:	e426                	sd	s1,8(sp)
    80004690:	e04a                	sd	s2,0(sp)
    80004692:	1000                	addi	s0,sp,32
    80004694:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004696:	00850913          	addi	s2,a0,8
    8000469a:	854a                	mv	a0,s2
    8000469c:	ffffc097          	auipc	ra,0xffffc
    800046a0:	534080e7          	jalr	1332(ra) # 80000bd0 <acquire>
  lk->locked = 0;
    800046a4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046a8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800046ac:	8526                	mv	a0,s1
    800046ae:	ffffe097          	auipc	ra,0xffffe
    800046b2:	eb8080e7          	jalr	-328(ra) # 80002566 <wakeup>
  release(&lk->lk);
    800046b6:	854a                	mv	a0,s2
    800046b8:	ffffc097          	auipc	ra,0xffffc
    800046bc:	5cc080e7          	jalr	1484(ra) # 80000c84 <release>
}
    800046c0:	60e2                	ld	ra,24(sp)
    800046c2:	6442                	ld	s0,16(sp)
    800046c4:	64a2                	ld	s1,8(sp)
    800046c6:	6902                	ld	s2,0(sp)
    800046c8:	6105                	addi	sp,sp,32
    800046ca:	8082                	ret

00000000800046cc <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800046cc:	7179                	addi	sp,sp,-48
    800046ce:	f406                	sd	ra,40(sp)
    800046d0:	f022                	sd	s0,32(sp)
    800046d2:	ec26                	sd	s1,24(sp)
    800046d4:	e84a                	sd	s2,16(sp)
    800046d6:	e44e                	sd	s3,8(sp)
    800046d8:	1800                	addi	s0,sp,48
    800046da:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800046dc:	00850913          	addi	s2,a0,8
    800046e0:	854a                	mv	a0,s2
    800046e2:	ffffc097          	auipc	ra,0xffffc
    800046e6:	4ee080e7          	jalr	1262(ra) # 80000bd0 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800046ea:	409c                	lw	a5,0(s1)
    800046ec:	ef99                	bnez	a5,8000470a <holdingsleep+0x3e>
    800046ee:	4481                	li	s1,0
  release(&lk->lk);
    800046f0:	854a                	mv	a0,s2
    800046f2:	ffffc097          	auipc	ra,0xffffc
    800046f6:	592080e7          	jalr	1426(ra) # 80000c84 <release>
  return r;
}
    800046fa:	8526                	mv	a0,s1
    800046fc:	70a2                	ld	ra,40(sp)
    800046fe:	7402                	ld	s0,32(sp)
    80004700:	64e2                	ld	s1,24(sp)
    80004702:	6942                	ld	s2,16(sp)
    80004704:	69a2                	ld	s3,8(sp)
    80004706:	6145                	addi	sp,sp,48
    80004708:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000470a:	0284a983          	lw	s3,40(s1)
    8000470e:	ffffd097          	auipc	ra,0xffffd
    80004712:	2f4080e7          	jalr	756(ra) # 80001a02 <myproc>
    80004716:	5904                	lw	s1,48(a0)
    80004718:	413484b3          	sub	s1,s1,s3
    8000471c:	0014b493          	seqz	s1,s1
    80004720:	bfc1                	j	800046f0 <holdingsleep+0x24>

0000000080004722 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004722:	1141                	addi	sp,sp,-16
    80004724:	e406                	sd	ra,8(sp)
    80004726:	e022                	sd	s0,0(sp)
    80004728:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000472a:	00004597          	auipc	a1,0x4
    8000472e:	f6e58593          	addi	a1,a1,-146 # 80008698 <syscalls+0x250>
    80004732:	0001e517          	auipc	a0,0x1e
    80004736:	84650513          	addi	a0,a0,-1978 # 80021f78 <ftable>
    8000473a:	ffffc097          	auipc	ra,0xffffc
    8000473e:	406080e7          	jalr	1030(ra) # 80000b40 <initlock>
}
    80004742:	60a2                	ld	ra,8(sp)
    80004744:	6402                	ld	s0,0(sp)
    80004746:	0141                	addi	sp,sp,16
    80004748:	8082                	ret

000000008000474a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000474a:	1101                	addi	sp,sp,-32
    8000474c:	ec06                	sd	ra,24(sp)
    8000474e:	e822                	sd	s0,16(sp)
    80004750:	e426                	sd	s1,8(sp)
    80004752:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004754:	0001e517          	auipc	a0,0x1e
    80004758:	82450513          	addi	a0,a0,-2012 # 80021f78 <ftable>
    8000475c:	ffffc097          	auipc	ra,0xffffc
    80004760:	474080e7          	jalr	1140(ra) # 80000bd0 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004764:	0001e497          	auipc	s1,0x1e
    80004768:	82c48493          	addi	s1,s1,-2004 # 80021f90 <ftable+0x18>
    8000476c:	0001e717          	auipc	a4,0x1e
    80004770:	7c470713          	addi	a4,a4,1988 # 80022f30 <disk>
    if(f->ref == 0){
    80004774:	40dc                	lw	a5,4(s1)
    80004776:	cf99                	beqz	a5,80004794 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004778:	02848493          	addi	s1,s1,40
    8000477c:	fee49ce3          	bne	s1,a4,80004774 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004780:	0001d517          	auipc	a0,0x1d
    80004784:	7f850513          	addi	a0,a0,2040 # 80021f78 <ftable>
    80004788:	ffffc097          	auipc	ra,0xffffc
    8000478c:	4fc080e7          	jalr	1276(ra) # 80000c84 <release>
  return 0;
    80004790:	4481                	li	s1,0
    80004792:	a819                	j	800047a8 <filealloc+0x5e>
      f->ref = 1;
    80004794:	4785                	li	a5,1
    80004796:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004798:	0001d517          	auipc	a0,0x1d
    8000479c:	7e050513          	addi	a0,a0,2016 # 80021f78 <ftable>
    800047a0:	ffffc097          	auipc	ra,0xffffc
    800047a4:	4e4080e7          	jalr	1252(ra) # 80000c84 <release>
}
    800047a8:	8526                	mv	a0,s1
    800047aa:	60e2                	ld	ra,24(sp)
    800047ac:	6442                	ld	s0,16(sp)
    800047ae:	64a2                	ld	s1,8(sp)
    800047b0:	6105                	addi	sp,sp,32
    800047b2:	8082                	ret

00000000800047b4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800047b4:	1101                	addi	sp,sp,-32
    800047b6:	ec06                	sd	ra,24(sp)
    800047b8:	e822                	sd	s0,16(sp)
    800047ba:	e426                	sd	s1,8(sp)
    800047bc:	1000                	addi	s0,sp,32
    800047be:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800047c0:	0001d517          	auipc	a0,0x1d
    800047c4:	7b850513          	addi	a0,a0,1976 # 80021f78 <ftable>
    800047c8:	ffffc097          	auipc	ra,0xffffc
    800047cc:	408080e7          	jalr	1032(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    800047d0:	40dc                	lw	a5,4(s1)
    800047d2:	02f05263          	blez	a5,800047f6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800047d6:	2785                	addiw	a5,a5,1
    800047d8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800047da:	0001d517          	auipc	a0,0x1d
    800047de:	79e50513          	addi	a0,a0,1950 # 80021f78 <ftable>
    800047e2:	ffffc097          	auipc	ra,0xffffc
    800047e6:	4a2080e7          	jalr	1186(ra) # 80000c84 <release>
  return f;
}
    800047ea:	8526                	mv	a0,s1
    800047ec:	60e2                	ld	ra,24(sp)
    800047ee:	6442                	ld	s0,16(sp)
    800047f0:	64a2                	ld	s1,8(sp)
    800047f2:	6105                	addi	sp,sp,32
    800047f4:	8082                	ret
    panic("filedup");
    800047f6:	00004517          	auipc	a0,0x4
    800047fa:	eaa50513          	addi	a0,a0,-342 # 800086a0 <syscalls+0x258>
    800047fe:	ffffc097          	auipc	ra,0xffffc
    80004802:	d3a080e7          	jalr	-710(ra) # 80000538 <panic>

0000000080004806 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004806:	7139                	addi	sp,sp,-64
    80004808:	fc06                	sd	ra,56(sp)
    8000480a:	f822                	sd	s0,48(sp)
    8000480c:	f426                	sd	s1,40(sp)
    8000480e:	f04a                	sd	s2,32(sp)
    80004810:	ec4e                	sd	s3,24(sp)
    80004812:	e852                	sd	s4,16(sp)
    80004814:	e456                	sd	s5,8(sp)
    80004816:	0080                	addi	s0,sp,64
    80004818:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000481a:	0001d517          	auipc	a0,0x1d
    8000481e:	75e50513          	addi	a0,a0,1886 # 80021f78 <ftable>
    80004822:	ffffc097          	auipc	ra,0xffffc
    80004826:	3ae080e7          	jalr	942(ra) # 80000bd0 <acquire>
  if(f->ref < 1)
    8000482a:	40dc                	lw	a5,4(s1)
    8000482c:	06f05163          	blez	a5,8000488e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004830:	37fd                	addiw	a5,a5,-1
    80004832:	0007871b          	sext.w	a4,a5
    80004836:	c0dc                	sw	a5,4(s1)
    80004838:	06e04363          	bgtz	a4,8000489e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000483c:	0004a903          	lw	s2,0(s1)
    80004840:	0094ca83          	lbu	s5,9(s1)
    80004844:	0104ba03          	ld	s4,16(s1)
    80004848:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000484c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004850:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004854:	0001d517          	auipc	a0,0x1d
    80004858:	72450513          	addi	a0,a0,1828 # 80021f78 <ftable>
    8000485c:	ffffc097          	auipc	ra,0xffffc
    80004860:	428080e7          	jalr	1064(ra) # 80000c84 <release>

  if(ff.type == FD_PIPE){
    80004864:	4785                	li	a5,1
    80004866:	04f90d63          	beq	s2,a5,800048c0 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000486a:	3979                	addiw	s2,s2,-2
    8000486c:	4785                	li	a5,1
    8000486e:	0527e063          	bltu	a5,s2,800048ae <fileclose+0xa8>
    begin_op();
    80004872:	00000097          	auipc	ra,0x0
    80004876:	ac8080e7          	jalr	-1336(ra) # 8000433a <begin_op>
    iput(ff.ip);
    8000487a:	854e                	mv	a0,s3
    8000487c:	fffff097          	auipc	ra,0xfffff
    80004880:	2a6080e7          	jalr	678(ra) # 80003b22 <iput>
    end_op();
    80004884:	00000097          	auipc	ra,0x0
    80004888:	b36080e7          	jalr	-1226(ra) # 800043ba <end_op>
    8000488c:	a00d                	j	800048ae <fileclose+0xa8>
    panic("fileclose");
    8000488e:	00004517          	auipc	a0,0x4
    80004892:	e1a50513          	addi	a0,a0,-486 # 800086a8 <syscalls+0x260>
    80004896:	ffffc097          	auipc	ra,0xffffc
    8000489a:	ca2080e7          	jalr	-862(ra) # 80000538 <panic>
    release(&ftable.lock);
    8000489e:	0001d517          	auipc	a0,0x1d
    800048a2:	6da50513          	addi	a0,a0,1754 # 80021f78 <ftable>
    800048a6:	ffffc097          	auipc	ra,0xffffc
    800048aa:	3de080e7          	jalr	990(ra) # 80000c84 <release>
  }
}
    800048ae:	70e2                	ld	ra,56(sp)
    800048b0:	7442                	ld	s0,48(sp)
    800048b2:	74a2                	ld	s1,40(sp)
    800048b4:	7902                	ld	s2,32(sp)
    800048b6:	69e2                	ld	s3,24(sp)
    800048b8:	6a42                	ld	s4,16(sp)
    800048ba:	6aa2                	ld	s5,8(sp)
    800048bc:	6121                	addi	sp,sp,64
    800048be:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048c0:	85d6                	mv	a1,s5
    800048c2:	8552                	mv	a0,s4
    800048c4:	00000097          	auipc	ra,0x0
    800048c8:	34c080e7          	jalr	844(ra) # 80004c10 <pipeclose>
    800048cc:	b7cd                	j	800048ae <fileclose+0xa8>

00000000800048ce <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800048ce:	715d                	addi	sp,sp,-80
    800048d0:	e486                	sd	ra,72(sp)
    800048d2:	e0a2                	sd	s0,64(sp)
    800048d4:	fc26                	sd	s1,56(sp)
    800048d6:	f84a                	sd	s2,48(sp)
    800048d8:	f44e                	sd	s3,40(sp)
    800048da:	0880                	addi	s0,sp,80
    800048dc:	84aa                	mv	s1,a0
    800048de:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800048e0:	ffffd097          	auipc	ra,0xffffd
    800048e4:	122080e7          	jalr	290(ra) # 80001a02 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800048e8:	409c                	lw	a5,0(s1)
    800048ea:	37f9                	addiw	a5,a5,-2
    800048ec:	4705                	li	a4,1
    800048ee:	04f76763          	bltu	a4,a5,8000493c <filestat+0x6e>
    800048f2:	892a                	mv	s2,a0
    ilock(f->ip);
    800048f4:	6c88                	ld	a0,24(s1)
    800048f6:	fffff097          	auipc	ra,0xfffff
    800048fa:	072080e7          	jalr	114(ra) # 80003968 <ilock>
    stati(f->ip, &st);
    800048fe:	fb840593          	addi	a1,s0,-72
    80004902:	6c88                	ld	a0,24(s1)
    80004904:	fffff097          	auipc	ra,0xfffff
    80004908:	2ee080e7          	jalr	750(ra) # 80003bf2 <stati>
    iunlock(f->ip);
    8000490c:	6c88                	ld	a0,24(s1)
    8000490e:	fffff097          	auipc	ra,0xfffff
    80004912:	11c080e7          	jalr	284(ra) # 80003a2a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004916:	46e1                	li	a3,24
    80004918:	fb840613          	addi	a2,s0,-72
    8000491c:	85ce                	mv	a1,s3
    8000491e:	05093503          	ld	a0,80(s2)
    80004922:	ffffd097          	auipc	ra,0xffffd
    80004926:	d34080e7          	jalr	-716(ra) # 80001656 <copyout>
    8000492a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000492e:	60a6                	ld	ra,72(sp)
    80004930:	6406                	ld	s0,64(sp)
    80004932:	74e2                	ld	s1,56(sp)
    80004934:	7942                	ld	s2,48(sp)
    80004936:	79a2                	ld	s3,40(sp)
    80004938:	6161                	addi	sp,sp,80
    8000493a:	8082                	ret
  return -1;
    8000493c:	557d                	li	a0,-1
    8000493e:	bfc5                	j	8000492e <filestat+0x60>

0000000080004940 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004940:	7179                	addi	sp,sp,-48
    80004942:	f406                	sd	ra,40(sp)
    80004944:	f022                	sd	s0,32(sp)
    80004946:	ec26                	sd	s1,24(sp)
    80004948:	e84a                	sd	s2,16(sp)
    8000494a:	e44e                	sd	s3,8(sp)
    8000494c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000494e:	00854783          	lbu	a5,8(a0)
    80004952:	c3d5                	beqz	a5,800049f6 <fileread+0xb6>
    80004954:	84aa                	mv	s1,a0
    80004956:	89ae                	mv	s3,a1
    80004958:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000495a:	411c                	lw	a5,0(a0)
    8000495c:	4705                	li	a4,1
    8000495e:	04e78963          	beq	a5,a4,800049b0 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004962:	470d                	li	a4,3
    80004964:	04e78d63          	beq	a5,a4,800049be <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004968:	4709                	li	a4,2
    8000496a:	06e79e63          	bne	a5,a4,800049e6 <fileread+0xa6>
    ilock(f->ip);
    8000496e:	6d08                	ld	a0,24(a0)
    80004970:	fffff097          	auipc	ra,0xfffff
    80004974:	ff8080e7          	jalr	-8(ra) # 80003968 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004978:	874a                	mv	a4,s2
    8000497a:	5094                	lw	a3,32(s1)
    8000497c:	864e                	mv	a2,s3
    8000497e:	4585                	li	a1,1
    80004980:	6c88                	ld	a0,24(s1)
    80004982:	fffff097          	auipc	ra,0xfffff
    80004986:	29a080e7          	jalr	666(ra) # 80003c1c <readi>
    8000498a:	892a                	mv	s2,a0
    8000498c:	00a05563          	blez	a0,80004996 <fileread+0x56>
      f->off += r;
    80004990:	509c                	lw	a5,32(s1)
    80004992:	9fa9                	addw	a5,a5,a0
    80004994:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004996:	6c88                	ld	a0,24(s1)
    80004998:	fffff097          	auipc	ra,0xfffff
    8000499c:	092080e7          	jalr	146(ra) # 80003a2a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800049a0:	854a                	mv	a0,s2
    800049a2:	70a2                	ld	ra,40(sp)
    800049a4:	7402                	ld	s0,32(sp)
    800049a6:	64e2                	ld	s1,24(sp)
    800049a8:	6942                	ld	s2,16(sp)
    800049aa:	69a2                	ld	s3,8(sp)
    800049ac:	6145                	addi	sp,sp,48
    800049ae:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049b0:	6908                	ld	a0,16(a0)
    800049b2:	00000097          	auipc	ra,0x0
    800049b6:	3c0080e7          	jalr	960(ra) # 80004d72 <piperead>
    800049ba:	892a                	mv	s2,a0
    800049bc:	b7d5                	j	800049a0 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049be:	02451783          	lh	a5,36(a0)
    800049c2:	03079693          	slli	a3,a5,0x30
    800049c6:	92c1                	srli	a3,a3,0x30
    800049c8:	4725                	li	a4,9
    800049ca:	02d76863          	bltu	a4,a3,800049fa <fileread+0xba>
    800049ce:	0792                	slli	a5,a5,0x4
    800049d0:	0001d717          	auipc	a4,0x1d
    800049d4:	50870713          	addi	a4,a4,1288 # 80021ed8 <devsw>
    800049d8:	97ba                	add	a5,a5,a4
    800049da:	639c                	ld	a5,0(a5)
    800049dc:	c38d                	beqz	a5,800049fe <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800049de:	4505                	li	a0,1
    800049e0:	9782                	jalr	a5
    800049e2:	892a                	mv	s2,a0
    800049e4:	bf75                	j	800049a0 <fileread+0x60>
    panic("fileread");
    800049e6:	00004517          	auipc	a0,0x4
    800049ea:	cd250513          	addi	a0,a0,-814 # 800086b8 <syscalls+0x270>
    800049ee:	ffffc097          	auipc	ra,0xffffc
    800049f2:	b4a080e7          	jalr	-1206(ra) # 80000538 <panic>
    return -1;
    800049f6:	597d                	li	s2,-1
    800049f8:	b765                	j	800049a0 <fileread+0x60>
      return -1;
    800049fa:	597d                	li	s2,-1
    800049fc:	b755                	j	800049a0 <fileread+0x60>
    800049fe:	597d                	li	s2,-1
    80004a00:	b745                	j	800049a0 <fileread+0x60>

0000000080004a02 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004a02:	715d                	addi	sp,sp,-80
    80004a04:	e486                	sd	ra,72(sp)
    80004a06:	e0a2                	sd	s0,64(sp)
    80004a08:	fc26                	sd	s1,56(sp)
    80004a0a:	f84a                	sd	s2,48(sp)
    80004a0c:	f44e                	sd	s3,40(sp)
    80004a0e:	f052                	sd	s4,32(sp)
    80004a10:	ec56                	sd	s5,24(sp)
    80004a12:	e85a                	sd	s6,16(sp)
    80004a14:	e45e                	sd	s7,8(sp)
    80004a16:	e062                	sd	s8,0(sp)
    80004a18:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004a1a:	00954783          	lbu	a5,9(a0)
    80004a1e:	10078663          	beqz	a5,80004b2a <filewrite+0x128>
    80004a22:	892a                	mv	s2,a0
    80004a24:	8aae                	mv	s5,a1
    80004a26:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a28:	411c                	lw	a5,0(a0)
    80004a2a:	4705                	li	a4,1
    80004a2c:	02e78263          	beq	a5,a4,80004a50 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a30:	470d                	li	a4,3
    80004a32:	02e78663          	beq	a5,a4,80004a5e <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a36:	4709                	li	a4,2
    80004a38:	0ee79163          	bne	a5,a4,80004b1a <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a3c:	0ac05d63          	blez	a2,80004af6 <filewrite+0xf4>
    int i = 0;
    80004a40:	4981                	li	s3,0
    80004a42:	6b05                	lui	s6,0x1
    80004a44:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004a48:	6b85                	lui	s7,0x1
    80004a4a:	c00b8b9b          	addiw	s7,s7,-1024
    80004a4e:	a861                	j	80004ae6 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004a50:	6908                	ld	a0,16(a0)
    80004a52:	00000097          	auipc	ra,0x0
    80004a56:	22e080e7          	jalr	558(ra) # 80004c80 <pipewrite>
    80004a5a:	8a2a                	mv	s4,a0
    80004a5c:	a045                	j	80004afc <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a5e:	02451783          	lh	a5,36(a0)
    80004a62:	03079693          	slli	a3,a5,0x30
    80004a66:	92c1                	srli	a3,a3,0x30
    80004a68:	4725                	li	a4,9
    80004a6a:	0cd76263          	bltu	a4,a3,80004b2e <filewrite+0x12c>
    80004a6e:	0792                	slli	a5,a5,0x4
    80004a70:	0001d717          	auipc	a4,0x1d
    80004a74:	46870713          	addi	a4,a4,1128 # 80021ed8 <devsw>
    80004a78:	97ba                	add	a5,a5,a4
    80004a7a:	679c                	ld	a5,8(a5)
    80004a7c:	cbdd                	beqz	a5,80004b32 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004a7e:	4505                	li	a0,1
    80004a80:	9782                	jalr	a5
    80004a82:	8a2a                	mv	s4,a0
    80004a84:	a8a5                	j	80004afc <filewrite+0xfa>
    80004a86:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a8a:	00000097          	auipc	ra,0x0
    80004a8e:	8b0080e7          	jalr	-1872(ra) # 8000433a <begin_op>
      ilock(f->ip);
    80004a92:	01893503          	ld	a0,24(s2)
    80004a96:	fffff097          	auipc	ra,0xfffff
    80004a9a:	ed2080e7          	jalr	-302(ra) # 80003968 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a9e:	8762                	mv	a4,s8
    80004aa0:	02092683          	lw	a3,32(s2)
    80004aa4:	01598633          	add	a2,s3,s5
    80004aa8:	4585                	li	a1,1
    80004aaa:	01893503          	ld	a0,24(s2)
    80004aae:	fffff097          	auipc	ra,0xfffff
    80004ab2:	266080e7          	jalr	614(ra) # 80003d14 <writei>
    80004ab6:	84aa                	mv	s1,a0
    80004ab8:	00a05763          	blez	a0,80004ac6 <filewrite+0xc4>
        f->off += r;
    80004abc:	02092783          	lw	a5,32(s2)
    80004ac0:	9fa9                	addw	a5,a5,a0
    80004ac2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ac6:	01893503          	ld	a0,24(s2)
    80004aca:	fffff097          	auipc	ra,0xfffff
    80004ace:	f60080e7          	jalr	-160(ra) # 80003a2a <iunlock>
      end_op();
    80004ad2:	00000097          	auipc	ra,0x0
    80004ad6:	8e8080e7          	jalr	-1816(ra) # 800043ba <end_op>

      if(r != n1){
    80004ada:	009c1f63          	bne	s8,s1,80004af8 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004ade:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ae2:	0149db63          	bge	s3,s4,80004af8 <filewrite+0xf6>
      int n1 = n - i;
    80004ae6:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004aea:	84be                	mv	s1,a5
    80004aec:	2781                	sext.w	a5,a5
    80004aee:	f8fb5ce3          	bge	s6,a5,80004a86 <filewrite+0x84>
    80004af2:	84de                	mv	s1,s7
    80004af4:	bf49                	j	80004a86 <filewrite+0x84>
    int i = 0;
    80004af6:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004af8:	013a1f63          	bne	s4,s3,80004b16 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004afc:	8552                	mv	a0,s4
    80004afe:	60a6                	ld	ra,72(sp)
    80004b00:	6406                	ld	s0,64(sp)
    80004b02:	74e2                	ld	s1,56(sp)
    80004b04:	7942                	ld	s2,48(sp)
    80004b06:	79a2                	ld	s3,40(sp)
    80004b08:	7a02                	ld	s4,32(sp)
    80004b0a:	6ae2                	ld	s5,24(sp)
    80004b0c:	6b42                	ld	s6,16(sp)
    80004b0e:	6ba2                	ld	s7,8(sp)
    80004b10:	6c02                	ld	s8,0(sp)
    80004b12:	6161                	addi	sp,sp,80
    80004b14:	8082                	ret
    ret = (i == n ? n : -1);
    80004b16:	5a7d                	li	s4,-1
    80004b18:	b7d5                	j	80004afc <filewrite+0xfa>
    panic("filewrite");
    80004b1a:	00004517          	auipc	a0,0x4
    80004b1e:	bae50513          	addi	a0,a0,-1106 # 800086c8 <syscalls+0x280>
    80004b22:	ffffc097          	auipc	ra,0xffffc
    80004b26:	a16080e7          	jalr	-1514(ra) # 80000538 <panic>
    return -1;
    80004b2a:	5a7d                	li	s4,-1
    80004b2c:	bfc1                	j	80004afc <filewrite+0xfa>
      return -1;
    80004b2e:	5a7d                	li	s4,-1
    80004b30:	b7f1                	j	80004afc <filewrite+0xfa>
    80004b32:	5a7d                	li	s4,-1
    80004b34:	b7e1                	j	80004afc <filewrite+0xfa>

0000000080004b36 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b36:	7179                	addi	sp,sp,-48
    80004b38:	f406                	sd	ra,40(sp)
    80004b3a:	f022                	sd	s0,32(sp)
    80004b3c:	ec26                	sd	s1,24(sp)
    80004b3e:	e84a                	sd	s2,16(sp)
    80004b40:	e44e                	sd	s3,8(sp)
    80004b42:	e052                	sd	s4,0(sp)
    80004b44:	1800                	addi	s0,sp,48
    80004b46:	84aa                	mv	s1,a0
    80004b48:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b4a:	0005b023          	sd	zero,0(a1)
    80004b4e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b52:	00000097          	auipc	ra,0x0
    80004b56:	bf8080e7          	jalr	-1032(ra) # 8000474a <filealloc>
    80004b5a:	e088                	sd	a0,0(s1)
    80004b5c:	c551                	beqz	a0,80004be8 <pipealloc+0xb2>
    80004b5e:	00000097          	auipc	ra,0x0
    80004b62:	bec080e7          	jalr	-1044(ra) # 8000474a <filealloc>
    80004b66:	00aa3023          	sd	a0,0(s4)
    80004b6a:	c92d                	beqz	a0,80004bdc <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b6c:	ffffc097          	auipc	ra,0xffffc
    80004b70:	f74080e7          	jalr	-140(ra) # 80000ae0 <kalloc>
    80004b74:	892a                	mv	s2,a0
    80004b76:	c125                	beqz	a0,80004bd6 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b78:	4985                	li	s3,1
    80004b7a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b7e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b82:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b86:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b8a:	00004597          	auipc	a1,0x4
    80004b8e:	b4e58593          	addi	a1,a1,-1202 # 800086d8 <syscalls+0x290>
    80004b92:	ffffc097          	auipc	ra,0xffffc
    80004b96:	fae080e7          	jalr	-82(ra) # 80000b40 <initlock>
  (*f0)->type = FD_PIPE;
    80004b9a:	609c                	ld	a5,0(s1)
    80004b9c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ba0:	609c                	ld	a5,0(s1)
    80004ba2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004ba6:	609c                	ld	a5,0(s1)
    80004ba8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004bac:	609c                	ld	a5,0(s1)
    80004bae:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004bb2:	000a3783          	ld	a5,0(s4)
    80004bb6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004bba:	000a3783          	ld	a5,0(s4)
    80004bbe:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004bc2:	000a3783          	ld	a5,0(s4)
    80004bc6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004bca:	000a3783          	ld	a5,0(s4)
    80004bce:	0127b823          	sd	s2,16(a5)
  return 0;
    80004bd2:	4501                	li	a0,0
    80004bd4:	a025                	j	80004bfc <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004bd6:	6088                	ld	a0,0(s1)
    80004bd8:	e501                	bnez	a0,80004be0 <pipealloc+0xaa>
    80004bda:	a039                	j	80004be8 <pipealloc+0xb2>
    80004bdc:	6088                	ld	a0,0(s1)
    80004bde:	c51d                	beqz	a0,80004c0c <pipealloc+0xd6>
    fileclose(*f0);
    80004be0:	00000097          	auipc	ra,0x0
    80004be4:	c26080e7          	jalr	-986(ra) # 80004806 <fileclose>
  if(*f1)
    80004be8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004bec:	557d                	li	a0,-1
  if(*f1)
    80004bee:	c799                	beqz	a5,80004bfc <pipealloc+0xc6>
    fileclose(*f1);
    80004bf0:	853e                	mv	a0,a5
    80004bf2:	00000097          	auipc	ra,0x0
    80004bf6:	c14080e7          	jalr	-1004(ra) # 80004806 <fileclose>
  return -1;
    80004bfa:	557d                	li	a0,-1
}
    80004bfc:	70a2                	ld	ra,40(sp)
    80004bfe:	7402                	ld	s0,32(sp)
    80004c00:	64e2                	ld	s1,24(sp)
    80004c02:	6942                	ld	s2,16(sp)
    80004c04:	69a2                	ld	s3,8(sp)
    80004c06:	6a02                	ld	s4,0(sp)
    80004c08:	6145                	addi	sp,sp,48
    80004c0a:	8082                	ret
  return -1;
    80004c0c:	557d                	li	a0,-1
    80004c0e:	b7fd                	j	80004bfc <pipealloc+0xc6>

0000000080004c10 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c10:	1101                	addi	sp,sp,-32
    80004c12:	ec06                	sd	ra,24(sp)
    80004c14:	e822                	sd	s0,16(sp)
    80004c16:	e426                	sd	s1,8(sp)
    80004c18:	e04a                	sd	s2,0(sp)
    80004c1a:	1000                	addi	s0,sp,32
    80004c1c:	84aa                	mv	s1,a0
    80004c1e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c20:	ffffc097          	auipc	ra,0xffffc
    80004c24:	fb0080e7          	jalr	-80(ra) # 80000bd0 <acquire>
  if(writable){
    80004c28:	02090d63          	beqz	s2,80004c62 <pipeclose+0x52>
    pi->writeopen = 0;
    80004c2c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c30:	21848513          	addi	a0,s1,536
    80004c34:	ffffe097          	auipc	ra,0xffffe
    80004c38:	932080e7          	jalr	-1742(ra) # 80002566 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c3c:	2204b783          	ld	a5,544(s1)
    80004c40:	eb95                	bnez	a5,80004c74 <pipeclose+0x64>
    release(&pi->lock);
    80004c42:	8526                	mv	a0,s1
    80004c44:	ffffc097          	auipc	ra,0xffffc
    80004c48:	040080e7          	jalr	64(ra) # 80000c84 <release>
    kfree((char*)pi);
    80004c4c:	8526                	mv	a0,s1
    80004c4e:	ffffc097          	auipc	ra,0xffffc
    80004c52:	d96080e7          	jalr	-618(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004c56:	60e2                	ld	ra,24(sp)
    80004c58:	6442                	ld	s0,16(sp)
    80004c5a:	64a2                	ld	s1,8(sp)
    80004c5c:	6902                	ld	s2,0(sp)
    80004c5e:	6105                	addi	sp,sp,32
    80004c60:	8082                	ret
    pi->readopen = 0;
    80004c62:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c66:	21c48513          	addi	a0,s1,540
    80004c6a:	ffffe097          	auipc	ra,0xffffe
    80004c6e:	8fc080e7          	jalr	-1796(ra) # 80002566 <wakeup>
    80004c72:	b7e9                	j	80004c3c <pipeclose+0x2c>
    release(&pi->lock);
    80004c74:	8526                	mv	a0,s1
    80004c76:	ffffc097          	auipc	ra,0xffffc
    80004c7a:	00e080e7          	jalr	14(ra) # 80000c84 <release>
}
    80004c7e:	bfe1                	j	80004c56 <pipeclose+0x46>

0000000080004c80 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c80:	711d                	addi	sp,sp,-96
    80004c82:	ec86                	sd	ra,88(sp)
    80004c84:	e8a2                	sd	s0,80(sp)
    80004c86:	e4a6                	sd	s1,72(sp)
    80004c88:	e0ca                	sd	s2,64(sp)
    80004c8a:	fc4e                	sd	s3,56(sp)
    80004c8c:	f852                	sd	s4,48(sp)
    80004c8e:	f456                	sd	s5,40(sp)
    80004c90:	f05a                	sd	s6,32(sp)
    80004c92:	ec5e                	sd	s7,24(sp)
    80004c94:	e862                	sd	s8,16(sp)
    80004c96:	1080                	addi	s0,sp,96
    80004c98:	84aa                	mv	s1,a0
    80004c9a:	8aae                	mv	s5,a1
    80004c9c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c9e:	ffffd097          	auipc	ra,0xffffd
    80004ca2:	d64080e7          	jalr	-668(ra) # 80001a02 <myproc>
    80004ca6:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004ca8:	8526                	mv	a0,s1
    80004caa:	ffffc097          	auipc	ra,0xffffc
    80004cae:	f26080e7          	jalr	-218(ra) # 80000bd0 <acquire>
  while(i < n){
    80004cb2:	0b405363          	blez	s4,80004d58 <pipewrite+0xd8>
  int i = 0;
    80004cb6:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cb8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004cba:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004cbe:	21c48b93          	addi	s7,s1,540
    80004cc2:	a089                	j	80004d04 <pipewrite+0x84>
      release(&pi->lock);
    80004cc4:	8526                	mv	a0,s1
    80004cc6:	ffffc097          	auipc	ra,0xffffc
    80004cca:	fbe080e7          	jalr	-66(ra) # 80000c84 <release>
      return -1;
    80004cce:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004cd0:	854a                	mv	a0,s2
    80004cd2:	60e6                	ld	ra,88(sp)
    80004cd4:	6446                	ld	s0,80(sp)
    80004cd6:	64a6                	ld	s1,72(sp)
    80004cd8:	6906                	ld	s2,64(sp)
    80004cda:	79e2                	ld	s3,56(sp)
    80004cdc:	7a42                	ld	s4,48(sp)
    80004cde:	7aa2                	ld	s5,40(sp)
    80004ce0:	7b02                	ld	s6,32(sp)
    80004ce2:	6be2                	ld	s7,24(sp)
    80004ce4:	6c42                	ld	s8,16(sp)
    80004ce6:	6125                	addi	sp,sp,96
    80004ce8:	8082                	ret
      wakeup(&pi->nread);
    80004cea:	8562                	mv	a0,s8
    80004cec:	ffffe097          	auipc	ra,0xffffe
    80004cf0:	87a080e7          	jalr	-1926(ra) # 80002566 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cf4:	85a6                	mv	a1,s1
    80004cf6:	855e                	mv	a0,s7
    80004cf8:	ffffd097          	auipc	ra,0xffffd
    80004cfc:	6e2080e7          	jalr	1762(ra) # 800023da <sleep>
  while(i < n){
    80004d00:	05495d63          	bge	s2,s4,80004d5a <pipewrite+0xda>
    if(pi->readopen == 0 || pr->killed){
    80004d04:	2204a783          	lw	a5,544(s1)
    80004d08:	dfd5                	beqz	a5,80004cc4 <pipewrite+0x44>
    80004d0a:	0289a783          	lw	a5,40(s3)
    80004d0e:	fbdd                	bnez	a5,80004cc4 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004d10:	2184a783          	lw	a5,536(s1)
    80004d14:	21c4a703          	lw	a4,540(s1)
    80004d18:	2007879b          	addiw	a5,a5,512
    80004d1c:	fcf707e3          	beq	a4,a5,80004cea <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d20:	4685                	li	a3,1
    80004d22:	01590633          	add	a2,s2,s5
    80004d26:	faf40593          	addi	a1,s0,-81
    80004d2a:	0509b503          	ld	a0,80(s3)
    80004d2e:	ffffd097          	auipc	ra,0xffffd
    80004d32:	9b4080e7          	jalr	-1612(ra) # 800016e2 <copyin>
    80004d36:	03650263          	beq	a0,s6,80004d5a <pipewrite+0xda>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d3a:	21c4a783          	lw	a5,540(s1)
    80004d3e:	0017871b          	addiw	a4,a5,1
    80004d42:	20e4ae23          	sw	a4,540(s1)
    80004d46:	1ff7f793          	andi	a5,a5,511
    80004d4a:	97a6                	add	a5,a5,s1
    80004d4c:	faf44703          	lbu	a4,-81(s0)
    80004d50:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d54:	2905                	addiw	s2,s2,1
    80004d56:	b76d                	j	80004d00 <pipewrite+0x80>
  int i = 0;
    80004d58:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d5a:	21848513          	addi	a0,s1,536
    80004d5e:	ffffe097          	auipc	ra,0xffffe
    80004d62:	808080e7          	jalr	-2040(ra) # 80002566 <wakeup>
  release(&pi->lock);
    80004d66:	8526                	mv	a0,s1
    80004d68:	ffffc097          	auipc	ra,0xffffc
    80004d6c:	f1c080e7          	jalr	-228(ra) # 80000c84 <release>
  return i;
    80004d70:	b785                	j	80004cd0 <pipewrite+0x50>

0000000080004d72 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d72:	715d                	addi	sp,sp,-80
    80004d74:	e486                	sd	ra,72(sp)
    80004d76:	e0a2                	sd	s0,64(sp)
    80004d78:	fc26                	sd	s1,56(sp)
    80004d7a:	f84a                	sd	s2,48(sp)
    80004d7c:	f44e                	sd	s3,40(sp)
    80004d7e:	f052                	sd	s4,32(sp)
    80004d80:	ec56                	sd	s5,24(sp)
    80004d82:	e85a                	sd	s6,16(sp)
    80004d84:	0880                	addi	s0,sp,80
    80004d86:	84aa                	mv	s1,a0
    80004d88:	892e                	mv	s2,a1
    80004d8a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d8c:	ffffd097          	auipc	ra,0xffffd
    80004d90:	c76080e7          	jalr	-906(ra) # 80001a02 <myproc>
    80004d94:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d96:	8526                	mv	a0,s1
    80004d98:	ffffc097          	auipc	ra,0xffffc
    80004d9c:	e38080e7          	jalr	-456(ra) # 80000bd0 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004da0:	2184a703          	lw	a4,536(s1)
    80004da4:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004da8:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dac:	02f71463          	bne	a4,a5,80004dd4 <piperead+0x62>
    80004db0:	2244a783          	lw	a5,548(s1)
    80004db4:	c385                	beqz	a5,80004dd4 <piperead+0x62>
    if(pr->killed){
    80004db6:	028a2783          	lw	a5,40(s4)
    80004dba:	ebc1                	bnez	a5,80004e4a <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004dbc:	85a6                	mv	a1,s1
    80004dbe:	854e                	mv	a0,s3
    80004dc0:	ffffd097          	auipc	ra,0xffffd
    80004dc4:	61a080e7          	jalr	1562(ra) # 800023da <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004dc8:	2184a703          	lw	a4,536(s1)
    80004dcc:	21c4a783          	lw	a5,540(s1)
    80004dd0:	fef700e3          	beq	a4,a5,80004db0 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dd4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dd6:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dd8:	05505363          	blez	s5,80004e1e <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004ddc:	2184a783          	lw	a5,536(s1)
    80004de0:	21c4a703          	lw	a4,540(s1)
    80004de4:	02f70d63          	beq	a4,a5,80004e1e <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004de8:	0017871b          	addiw	a4,a5,1
    80004dec:	20e4ac23          	sw	a4,536(s1)
    80004df0:	1ff7f793          	andi	a5,a5,511
    80004df4:	97a6                	add	a5,a5,s1
    80004df6:	0187c783          	lbu	a5,24(a5)
    80004dfa:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dfe:	4685                	li	a3,1
    80004e00:	fbf40613          	addi	a2,s0,-65
    80004e04:	85ca                	mv	a1,s2
    80004e06:	050a3503          	ld	a0,80(s4)
    80004e0a:	ffffd097          	auipc	ra,0xffffd
    80004e0e:	84c080e7          	jalr	-1972(ra) # 80001656 <copyout>
    80004e12:	01650663          	beq	a0,s6,80004e1e <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e16:	2985                	addiw	s3,s3,1
    80004e18:	0905                	addi	s2,s2,1
    80004e1a:	fd3a91e3          	bne	s5,s3,80004ddc <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e1e:	21c48513          	addi	a0,s1,540
    80004e22:	ffffd097          	auipc	ra,0xffffd
    80004e26:	744080e7          	jalr	1860(ra) # 80002566 <wakeup>
  release(&pi->lock);
    80004e2a:	8526                	mv	a0,s1
    80004e2c:	ffffc097          	auipc	ra,0xffffc
    80004e30:	e58080e7          	jalr	-424(ra) # 80000c84 <release>
  return i;
}
    80004e34:	854e                	mv	a0,s3
    80004e36:	60a6                	ld	ra,72(sp)
    80004e38:	6406                	ld	s0,64(sp)
    80004e3a:	74e2                	ld	s1,56(sp)
    80004e3c:	7942                	ld	s2,48(sp)
    80004e3e:	79a2                	ld	s3,40(sp)
    80004e40:	7a02                	ld	s4,32(sp)
    80004e42:	6ae2                	ld	s5,24(sp)
    80004e44:	6b42                	ld	s6,16(sp)
    80004e46:	6161                	addi	sp,sp,80
    80004e48:	8082                	ret
      release(&pi->lock);
    80004e4a:	8526                	mv	a0,s1
    80004e4c:	ffffc097          	auipc	ra,0xffffc
    80004e50:	e38080e7          	jalr	-456(ra) # 80000c84 <release>
      return -1;
    80004e54:	59fd                	li	s3,-1
    80004e56:	bff9                	j	80004e34 <piperead+0xc2>

0000000080004e58 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e58:	de010113          	addi	sp,sp,-544
    80004e5c:	20113c23          	sd	ra,536(sp)
    80004e60:	20813823          	sd	s0,528(sp)
    80004e64:	20913423          	sd	s1,520(sp)
    80004e68:	21213023          	sd	s2,512(sp)
    80004e6c:	ffce                	sd	s3,504(sp)
    80004e6e:	fbd2                	sd	s4,496(sp)
    80004e70:	f7d6                	sd	s5,488(sp)
    80004e72:	f3da                	sd	s6,480(sp)
    80004e74:	efde                	sd	s7,472(sp)
    80004e76:	ebe2                	sd	s8,464(sp)
    80004e78:	e7e6                	sd	s9,456(sp)
    80004e7a:	e3ea                	sd	s10,448(sp)
    80004e7c:	ff6e                	sd	s11,440(sp)
    80004e7e:	1400                	addi	s0,sp,544
    80004e80:	892a                	mv	s2,a0
    80004e82:	dea43423          	sd	a0,-536(s0)
    80004e86:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e8a:	ffffd097          	auipc	ra,0xffffd
    80004e8e:	b78080e7          	jalr	-1160(ra) # 80001a02 <myproc>
    80004e92:	84aa                	mv	s1,a0

  begin_op();
    80004e94:	fffff097          	auipc	ra,0xfffff
    80004e98:	4a6080e7          	jalr	1190(ra) # 8000433a <begin_op>

  if((ip = namei(path)) == 0){
    80004e9c:	854a                	mv	a0,s2
    80004e9e:	fffff097          	auipc	ra,0xfffff
    80004ea2:	280080e7          	jalr	640(ra) # 8000411e <namei>
    80004ea6:	c93d                	beqz	a0,80004f1c <exec+0xc4>
    80004ea8:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004eaa:	fffff097          	auipc	ra,0xfffff
    80004eae:	abe080e7          	jalr	-1346(ra) # 80003968 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004eb2:	04000713          	li	a4,64
    80004eb6:	4681                	li	a3,0
    80004eb8:	e5040613          	addi	a2,s0,-432
    80004ebc:	4581                	li	a1,0
    80004ebe:	8556                	mv	a0,s5
    80004ec0:	fffff097          	auipc	ra,0xfffff
    80004ec4:	d5c080e7          	jalr	-676(ra) # 80003c1c <readi>
    80004ec8:	04000793          	li	a5,64
    80004ecc:	00f51a63          	bne	a0,a5,80004ee0 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004ed0:	e5042703          	lw	a4,-432(s0)
    80004ed4:	464c47b7          	lui	a5,0x464c4
    80004ed8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004edc:	04f70663          	beq	a4,a5,80004f28 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ee0:	8556                	mv	a0,s5
    80004ee2:	fffff097          	auipc	ra,0xfffff
    80004ee6:	ce8080e7          	jalr	-792(ra) # 80003bca <iunlockput>
    end_op();
    80004eea:	fffff097          	auipc	ra,0xfffff
    80004eee:	4d0080e7          	jalr	1232(ra) # 800043ba <end_op>
  }
  return -1;
    80004ef2:	557d                	li	a0,-1
}
    80004ef4:	21813083          	ld	ra,536(sp)
    80004ef8:	21013403          	ld	s0,528(sp)
    80004efc:	20813483          	ld	s1,520(sp)
    80004f00:	20013903          	ld	s2,512(sp)
    80004f04:	79fe                	ld	s3,504(sp)
    80004f06:	7a5e                	ld	s4,496(sp)
    80004f08:	7abe                	ld	s5,488(sp)
    80004f0a:	7b1e                	ld	s6,480(sp)
    80004f0c:	6bfe                	ld	s7,472(sp)
    80004f0e:	6c5e                	ld	s8,464(sp)
    80004f10:	6cbe                	ld	s9,456(sp)
    80004f12:	6d1e                	ld	s10,448(sp)
    80004f14:	7dfa                	ld	s11,440(sp)
    80004f16:	22010113          	addi	sp,sp,544
    80004f1a:	8082                	ret
    end_op();
    80004f1c:	fffff097          	auipc	ra,0xfffff
    80004f20:	49e080e7          	jalr	1182(ra) # 800043ba <end_op>
    return -1;
    80004f24:	557d                	li	a0,-1
    80004f26:	b7f9                	j	80004ef4 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004f28:	8526                	mv	a0,s1
    80004f2a:	ffffd097          	auipc	ra,0xffffd
    80004f2e:	bf6080e7          	jalr	-1034(ra) # 80001b20 <proc_pagetable>
    80004f32:	8b2a                	mv	s6,a0
    80004f34:	d555                	beqz	a0,80004ee0 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f36:	e7042783          	lw	a5,-400(s0)
    80004f3a:	e8845703          	lhu	a4,-376(s0)
    80004f3e:	c735                	beqz	a4,80004faa <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f40:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f42:	e0043423          	sd	zero,-504(s0)
    if((ph.vaddr % PGSIZE) != 0)
    80004f46:	6a05                	lui	s4,0x1
    80004f48:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f4c:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004f50:	6d85                	lui	s11,0x1
    80004f52:	7d7d                	lui	s10,0xfffff
    80004f54:	ac1d                	j	8000518a <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f56:	00003517          	auipc	a0,0x3
    80004f5a:	78a50513          	addi	a0,a0,1930 # 800086e0 <syscalls+0x298>
    80004f5e:	ffffb097          	auipc	ra,0xffffb
    80004f62:	5da080e7          	jalr	1498(ra) # 80000538 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f66:	874a                	mv	a4,s2
    80004f68:	009c86bb          	addw	a3,s9,s1
    80004f6c:	4581                	li	a1,0
    80004f6e:	8556                	mv	a0,s5
    80004f70:	fffff097          	auipc	ra,0xfffff
    80004f74:	cac080e7          	jalr	-852(ra) # 80003c1c <readi>
    80004f78:	2501                	sext.w	a0,a0
    80004f7a:	1aa91863          	bne	s2,a0,8000512a <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004f7e:	009d84bb          	addw	s1,s11,s1
    80004f82:	013d09bb          	addw	s3,s10,s3
    80004f86:	1f74f263          	bgeu	s1,s7,8000516a <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004f8a:	02049593          	slli	a1,s1,0x20
    80004f8e:	9181                	srli	a1,a1,0x20
    80004f90:	95e2                	add	a1,a1,s8
    80004f92:	855a                	mv	a0,s6
    80004f94:	ffffc097          	auipc	ra,0xffffc
    80004f98:	0be080e7          	jalr	190(ra) # 80001052 <walkaddr>
    80004f9c:	862a                	mv	a2,a0
    if(pa == 0)
    80004f9e:	dd45                	beqz	a0,80004f56 <exec+0xfe>
      n = PGSIZE;
    80004fa0:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004fa2:	fd49f2e3          	bgeu	s3,s4,80004f66 <exec+0x10e>
      n = sz - i;
    80004fa6:	894e                	mv	s2,s3
    80004fa8:	bf7d                	j	80004f66 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004faa:	4481                	li	s1,0
  iunlockput(ip);
    80004fac:	8556                	mv	a0,s5
    80004fae:	fffff097          	auipc	ra,0xfffff
    80004fb2:	c1c080e7          	jalr	-996(ra) # 80003bca <iunlockput>
  end_op();
    80004fb6:	fffff097          	auipc	ra,0xfffff
    80004fba:	404080e7          	jalr	1028(ra) # 800043ba <end_op>
  p = myproc();
    80004fbe:	ffffd097          	auipc	ra,0xffffd
    80004fc2:	a44080e7          	jalr	-1468(ra) # 80001a02 <myproc>
    80004fc6:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004fc8:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004fcc:	6785                	lui	a5,0x1
    80004fce:	17fd                	addi	a5,a5,-1
    80004fd0:	94be                	add	s1,s1,a5
    80004fd2:	77fd                	lui	a5,0xfffff
    80004fd4:	8fe5                	and	a5,a5,s1
    80004fd6:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fda:	6609                	lui	a2,0x2
    80004fdc:	963e                	add	a2,a2,a5
    80004fde:	85be                	mv	a1,a5
    80004fe0:	855a                	mv	a0,s6
    80004fe2:	ffffc097          	auipc	ra,0xffffc
    80004fe6:	424080e7          	jalr	1060(ra) # 80001406 <uvmalloc>
    80004fea:	8c2a                	mv	s8,a0
  ip = 0;
    80004fec:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fee:	12050e63          	beqz	a0,8000512a <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004ff2:	75f9                	lui	a1,0xffffe
    80004ff4:	95aa                	add	a1,a1,a0
    80004ff6:	855a                	mv	a0,s6
    80004ff8:	ffffc097          	auipc	ra,0xffffc
    80004ffc:	62c080e7          	jalr	1580(ra) # 80001624 <uvmclear>
  stackbase = sp - PGSIZE;
    80005000:	7afd                	lui	s5,0xfffff
    80005002:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005004:	df043783          	ld	a5,-528(s0)
    80005008:	6388                	ld	a0,0(a5)
    8000500a:	c925                	beqz	a0,8000507a <exec+0x222>
    8000500c:	e9040993          	addi	s3,s0,-368
    80005010:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005014:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005016:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005018:	ffffc097          	auipc	ra,0xffffc
    8000501c:	e30080e7          	jalr	-464(ra) # 80000e48 <strlen>
    80005020:	0015079b          	addiw	a5,a0,1
    80005024:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005028:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000502c:	13596363          	bltu	s2,s5,80005152 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005030:	df043d83          	ld	s11,-528(s0)
    80005034:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005038:	8552                	mv	a0,s4
    8000503a:	ffffc097          	auipc	ra,0xffffc
    8000503e:	e0e080e7          	jalr	-498(ra) # 80000e48 <strlen>
    80005042:	0015069b          	addiw	a3,a0,1
    80005046:	8652                	mv	a2,s4
    80005048:	85ca                	mv	a1,s2
    8000504a:	855a                	mv	a0,s6
    8000504c:	ffffc097          	auipc	ra,0xffffc
    80005050:	60a080e7          	jalr	1546(ra) # 80001656 <copyout>
    80005054:	10054363          	bltz	a0,8000515a <exec+0x302>
    ustack[argc] = sp;
    80005058:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000505c:	0485                	addi	s1,s1,1
    8000505e:	008d8793          	addi	a5,s11,8
    80005062:	def43823          	sd	a5,-528(s0)
    80005066:	008db503          	ld	a0,8(s11)
    8000506a:	c911                	beqz	a0,8000507e <exec+0x226>
    if(argc >= MAXARG)
    8000506c:	09a1                	addi	s3,s3,8
    8000506e:	fb3c95e3          	bne	s9,s3,80005018 <exec+0x1c0>
  sz = sz1;
    80005072:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005076:	4a81                	li	s5,0
    80005078:	a84d                	j	8000512a <exec+0x2d2>
  sp = sz;
    8000507a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000507c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000507e:	00349793          	slli	a5,s1,0x3
    80005082:	f9040713          	addi	a4,s0,-112
    80005086:	97ba                	add	a5,a5,a4
    80005088:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdbe90>
  sp -= (argc+1) * sizeof(uint64);
    8000508c:	00148693          	addi	a3,s1,1
    80005090:	068e                	slli	a3,a3,0x3
    80005092:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005096:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000509a:	01597663          	bgeu	s2,s5,800050a6 <exec+0x24e>
  sz = sz1;
    8000509e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050a2:	4a81                	li	s5,0
    800050a4:	a059                	j	8000512a <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050a6:	e9040613          	addi	a2,s0,-368
    800050aa:	85ca                	mv	a1,s2
    800050ac:	855a                	mv	a0,s6
    800050ae:	ffffc097          	auipc	ra,0xffffc
    800050b2:	5a8080e7          	jalr	1448(ra) # 80001656 <copyout>
    800050b6:	0a054663          	bltz	a0,80005162 <exec+0x30a>
  p->trapframe->a1 = sp;
    800050ba:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    800050be:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050c2:	de843783          	ld	a5,-536(s0)
    800050c6:	0007c703          	lbu	a4,0(a5)
    800050ca:	cf11                	beqz	a4,800050e6 <exec+0x28e>
    800050cc:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050ce:	02f00693          	li	a3,47
    800050d2:	a039                	j	800050e0 <exec+0x288>
      last = s+1;
    800050d4:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800050d8:	0785                	addi	a5,a5,1
    800050da:	fff7c703          	lbu	a4,-1(a5)
    800050de:	c701                	beqz	a4,800050e6 <exec+0x28e>
    if(*s == '/')
    800050e0:	fed71ce3          	bne	a4,a3,800050d8 <exec+0x280>
    800050e4:	bfc5                	j	800050d4 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    800050e6:	4641                	li	a2,16
    800050e8:	de843583          	ld	a1,-536(s0)
    800050ec:	158b8513          	addi	a0,s7,344
    800050f0:	ffffc097          	auipc	ra,0xffffc
    800050f4:	d26080e7          	jalr	-730(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    800050f8:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800050fc:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005100:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005104:	058bb783          	ld	a5,88(s7)
    80005108:	e6843703          	ld	a4,-408(s0)
    8000510c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000510e:	058bb783          	ld	a5,88(s7)
    80005112:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005116:	85ea                	mv	a1,s10
    80005118:	ffffd097          	auipc	ra,0xffffd
    8000511c:	aa4080e7          	jalr	-1372(ra) # 80001bbc <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005120:	0004851b          	sext.w	a0,s1
    80005124:	bbc1                	j	80004ef4 <exec+0x9c>
    80005126:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000512a:	df843583          	ld	a1,-520(s0)
    8000512e:	855a                	mv	a0,s6
    80005130:	ffffd097          	auipc	ra,0xffffd
    80005134:	a8c080e7          	jalr	-1396(ra) # 80001bbc <proc_freepagetable>
  if(ip){
    80005138:	da0a94e3          	bnez	s5,80004ee0 <exec+0x88>
  return -1;
    8000513c:	557d                	li	a0,-1
    8000513e:	bb5d                	j	80004ef4 <exec+0x9c>
    80005140:	de943c23          	sd	s1,-520(s0)
    80005144:	b7dd                	j	8000512a <exec+0x2d2>
    80005146:	de943c23          	sd	s1,-520(s0)
    8000514a:	b7c5                	j	8000512a <exec+0x2d2>
    8000514c:	de943c23          	sd	s1,-520(s0)
    80005150:	bfe9                	j	8000512a <exec+0x2d2>
  sz = sz1;
    80005152:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005156:	4a81                	li	s5,0
    80005158:	bfc9                	j	8000512a <exec+0x2d2>
  sz = sz1;
    8000515a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000515e:	4a81                	li	s5,0
    80005160:	b7e9                	j	8000512a <exec+0x2d2>
  sz = sz1;
    80005162:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005166:	4a81                	li	s5,0
    80005168:	b7c9                	j	8000512a <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000516a:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000516e:	e0843783          	ld	a5,-504(s0)
    80005172:	0017869b          	addiw	a3,a5,1
    80005176:	e0d43423          	sd	a3,-504(s0)
    8000517a:	e0043783          	ld	a5,-512(s0)
    8000517e:	0387879b          	addiw	a5,a5,56
    80005182:	e8845703          	lhu	a4,-376(s0)
    80005186:	e2e6d3e3          	bge	a3,a4,80004fac <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000518a:	2781                	sext.w	a5,a5
    8000518c:	e0f43023          	sd	a5,-512(s0)
    80005190:	03800713          	li	a4,56
    80005194:	86be                	mv	a3,a5
    80005196:	e1840613          	addi	a2,s0,-488
    8000519a:	4581                	li	a1,0
    8000519c:	8556                	mv	a0,s5
    8000519e:	fffff097          	auipc	ra,0xfffff
    800051a2:	a7e080e7          	jalr	-1410(ra) # 80003c1c <readi>
    800051a6:	03800793          	li	a5,56
    800051aa:	f6f51ee3          	bne	a0,a5,80005126 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    800051ae:	e1842783          	lw	a5,-488(s0)
    800051b2:	4705                	li	a4,1
    800051b4:	fae79de3          	bne	a5,a4,8000516e <exec+0x316>
    if(ph.memsz < ph.filesz)
    800051b8:	e4043603          	ld	a2,-448(s0)
    800051bc:	e3843783          	ld	a5,-456(s0)
    800051c0:	f8f660e3          	bltu	a2,a5,80005140 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800051c4:	e2843783          	ld	a5,-472(s0)
    800051c8:	963e                	add	a2,a2,a5
    800051ca:	f6f66ee3          	bltu	a2,a5,80005146 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800051ce:	85a6                	mv	a1,s1
    800051d0:	855a                	mv	a0,s6
    800051d2:	ffffc097          	auipc	ra,0xffffc
    800051d6:	234080e7          	jalr	564(ra) # 80001406 <uvmalloc>
    800051da:	dea43c23          	sd	a0,-520(s0)
    800051de:	d53d                	beqz	a0,8000514c <exec+0x2f4>
    if((ph.vaddr % PGSIZE) != 0)
    800051e0:	e2843c03          	ld	s8,-472(s0)
    800051e4:	de043783          	ld	a5,-544(s0)
    800051e8:	00fc77b3          	and	a5,s8,a5
    800051ec:	ff9d                	bnez	a5,8000512a <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800051ee:	e2042c83          	lw	s9,-480(s0)
    800051f2:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800051f6:	f60b8ae3          	beqz	s7,8000516a <exec+0x312>
    800051fa:	89de                	mv	s3,s7
    800051fc:	4481                	li	s1,0
    800051fe:	b371                	j	80004f8a <exec+0x132>

0000000080005200 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005200:	7179                	addi	sp,sp,-48
    80005202:	f406                	sd	ra,40(sp)
    80005204:	f022                	sd	s0,32(sp)
    80005206:	ec26                	sd	s1,24(sp)
    80005208:	e84a                	sd	s2,16(sp)
    8000520a:	1800                	addi	s0,sp,48
    8000520c:	892e                	mv	s2,a1
    8000520e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005210:	fdc40593          	addi	a1,s0,-36
    80005214:	ffffe097          	auipc	ra,0xffffe
    80005218:	bd0080e7          	jalr	-1072(ra) # 80002de4 <argint>
    8000521c:	04054063          	bltz	a0,8000525c <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005220:	fdc42703          	lw	a4,-36(s0)
    80005224:	47bd                	li	a5,15
    80005226:	02e7ed63          	bltu	a5,a4,80005260 <argfd+0x60>
    8000522a:	ffffc097          	auipc	ra,0xffffc
    8000522e:	7d8080e7          	jalr	2008(ra) # 80001a02 <myproc>
    80005232:	fdc42703          	lw	a4,-36(s0)
    80005236:	01a70793          	addi	a5,a4,26
    8000523a:	078e                	slli	a5,a5,0x3
    8000523c:	953e                	add	a0,a0,a5
    8000523e:	611c                	ld	a5,0(a0)
    80005240:	c395                	beqz	a5,80005264 <argfd+0x64>
    return -1;
  if(pfd)
    80005242:	00090463          	beqz	s2,8000524a <argfd+0x4a>
    *pfd = fd;
    80005246:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000524a:	4501                	li	a0,0
  if(pf)
    8000524c:	c091                	beqz	s1,80005250 <argfd+0x50>
    *pf = f;
    8000524e:	e09c                	sd	a5,0(s1)
}
    80005250:	70a2                	ld	ra,40(sp)
    80005252:	7402                	ld	s0,32(sp)
    80005254:	64e2                	ld	s1,24(sp)
    80005256:	6942                	ld	s2,16(sp)
    80005258:	6145                	addi	sp,sp,48
    8000525a:	8082                	ret
    return -1;
    8000525c:	557d                	li	a0,-1
    8000525e:	bfcd                	j	80005250 <argfd+0x50>
    return -1;
    80005260:	557d                	li	a0,-1
    80005262:	b7fd                	j	80005250 <argfd+0x50>
    80005264:	557d                	li	a0,-1
    80005266:	b7ed                	j	80005250 <argfd+0x50>

0000000080005268 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005268:	1101                	addi	sp,sp,-32
    8000526a:	ec06                	sd	ra,24(sp)
    8000526c:	e822                	sd	s0,16(sp)
    8000526e:	e426                	sd	s1,8(sp)
    80005270:	1000                	addi	s0,sp,32
    80005272:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005274:	ffffc097          	auipc	ra,0xffffc
    80005278:	78e080e7          	jalr	1934(ra) # 80001a02 <myproc>
    8000527c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000527e:	0d050793          	addi	a5,a0,208
    80005282:	4501                	li	a0,0
    80005284:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005286:	6398                	ld	a4,0(a5)
    80005288:	cb19                	beqz	a4,8000529e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000528a:	2505                	addiw	a0,a0,1
    8000528c:	07a1                	addi	a5,a5,8
    8000528e:	fed51ce3          	bne	a0,a3,80005286 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005292:	557d                	li	a0,-1
}
    80005294:	60e2                	ld	ra,24(sp)
    80005296:	6442                	ld	s0,16(sp)
    80005298:	64a2                	ld	s1,8(sp)
    8000529a:	6105                	addi	sp,sp,32
    8000529c:	8082                	ret
      p->ofile[fd] = f;
    8000529e:	01a50793          	addi	a5,a0,26
    800052a2:	078e                	slli	a5,a5,0x3
    800052a4:	963e                	add	a2,a2,a5
    800052a6:	e204                	sd	s1,0(a2)
      return fd;
    800052a8:	b7f5                	j	80005294 <fdalloc+0x2c>

00000000800052aa <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052aa:	715d                	addi	sp,sp,-80
    800052ac:	e486                	sd	ra,72(sp)
    800052ae:	e0a2                	sd	s0,64(sp)
    800052b0:	fc26                	sd	s1,56(sp)
    800052b2:	f84a                	sd	s2,48(sp)
    800052b4:	f44e                	sd	s3,40(sp)
    800052b6:	f052                	sd	s4,32(sp)
    800052b8:	ec56                	sd	s5,24(sp)
    800052ba:	0880                	addi	s0,sp,80
    800052bc:	89ae                	mv	s3,a1
    800052be:	8ab2                	mv	s5,a2
    800052c0:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052c2:	fb040593          	addi	a1,s0,-80
    800052c6:	fffff097          	auipc	ra,0xfffff
    800052ca:	e76080e7          	jalr	-394(ra) # 8000413c <nameiparent>
    800052ce:	892a                	mv	s2,a0
    800052d0:	12050e63          	beqz	a0,8000540c <create+0x162>
    return 0;

  ilock(dp);
    800052d4:	ffffe097          	auipc	ra,0xffffe
    800052d8:	694080e7          	jalr	1684(ra) # 80003968 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052dc:	4601                	li	a2,0
    800052de:	fb040593          	addi	a1,s0,-80
    800052e2:	854a                	mv	a0,s2
    800052e4:	fffff097          	auipc	ra,0xfffff
    800052e8:	b68080e7          	jalr	-1176(ra) # 80003e4c <dirlookup>
    800052ec:	84aa                	mv	s1,a0
    800052ee:	c921                	beqz	a0,8000533e <create+0x94>
    iunlockput(dp);
    800052f0:	854a                	mv	a0,s2
    800052f2:	fffff097          	auipc	ra,0xfffff
    800052f6:	8d8080e7          	jalr	-1832(ra) # 80003bca <iunlockput>
    ilock(ip);
    800052fa:	8526                	mv	a0,s1
    800052fc:	ffffe097          	auipc	ra,0xffffe
    80005300:	66c080e7          	jalr	1644(ra) # 80003968 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005304:	2981                	sext.w	s3,s3
    80005306:	4789                	li	a5,2
    80005308:	02f99463          	bne	s3,a5,80005330 <create+0x86>
    8000530c:	0444d783          	lhu	a5,68(s1)
    80005310:	37f9                	addiw	a5,a5,-2
    80005312:	17c2                	slli	a5,a5,0x30
    80005314:	93c1                	srli	a5,a5,0x30
    80005316:	4705                	li	a4,1
    80005318:	00f76c63          	bltu	a4,a5,80005330 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000531c:	8526                	mv	a0,s1
    8000531e:	60a6                	ld	ra,72(sp)
    80005320:	6406                	ld	s0,64(sp)
    80005322:	74e2                	ld	s1,56(sp)
    80005324:	7942                	ld	s2,48(sp)
    80005326:	79a2                	ld	s3,40(sp)
    80005328:	7a02                	ld	s4,32(sp)
    8000532a:	6ae2                	ld	s5,24(sp)
    8000532c:	6161                	addi	sp,sp,80
    8000532e:	8082                	ret
    iunlockput(ip);
    80005330:	8526                	mv	a0,s1
    80005332:	fffff097          	auipc	ra,0xfffff
    80005336:	898080e7          	jalr	-1896(ra) # 80003bca <iunlockput>
    return 0;
    8000533a:	4481                	li	s1,0
    8000533c:	b7c5                	j	8000531c <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000533e:	85ce                	mv	a1,s3
    80005340:	00092503          	lw	a0,0(s2)
    80005344:	ffffe097          	auipc	ra,0xffffe
    80005348:	48c080e7          	jalr	1164(ra) # 800037d0 <ialloc>
    8000534c:	84aa                	mv	s1,a0
    8000534e:	c521                	beqz	a0,80005396 <create+0xec>
  ilock(ip);
    80005350:	ffffe097          	auipc	ra,0xffffe
    80005354:	618080e7          	jalr	1560(ra) # 80003968 <ilock>
  ip->major = major;
    80005358:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    8000535c:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005360:	4a05                	li	s4,1
    80005362:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005366:	8526                	mv	a0,s1
    80005368:	ffffe097          	auipc	ra,0xffffe
    8000536c:	536080e7          	jalr	1334(ra) # 8000389e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005370:	2981                	sext.w	s3,s3
    80005372:	03498a63          	beq	s3,s4,800053a6 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005376:	40d0                	lw	a2,4(s1)
    80005378:	fb040593          	addi	a1,s0,-80
    8000537c:	854a                	mv	a0,s2
    8000537e:	fffff097          	auipc	ra,0xfffff
    80005382:	cde080e7          	jalr	-802(ra) # 8000405c <dirlink>
    80005386:	06054b63          	bltz	a0,800053fc <create+0x152>
  iunlockput(dp);
    8000538a:	854a                	mv	a0,s2
    8000538c:	fffff097          	auipc	ra,0xfffff
    80005390:	83e080e7          	jalr	-1986(ra) # 80003bca <iunlockput>
  return ip;
    80005394:	b761                	j	8000531c <create+0x72>
    panic("create: ialloc");
    80005396:	00003517          	auipc	a0,0x3
    8000539a:	36a50513          	addi	a0,a0,874 # 80008700 <syscalls+0x2b8>
    8000539e:	ffffb097          	auipc	ra,0xffffb
    800053a2:	19a080e7          	jalr	410(ra) # 80000538 <panic>
    dp->nlink++;  // for ".."
    800053a6:	04a95783          	lhu	a5,74(s2)
    800053aa:	2785                	addiw	a5,a5,1
    800053ac:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800053b0:	854a                	mv	a0,s2
    800053b2:	ffffe097          	auipc	ra,0xffffe
    800053b6:	4ec080e7          	jalr	1260(ra) # 8000389e <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053ba:	40d0                	lw	a2,4(s1)
    800053bc:	00003597          	auipc	a1,0x3
    800053c0:	35458593          	addi	a1,a1,852 # 80008710 <syscalls+0x2c8>
    800053c4:	8526                	mv	a0,s1
    800053c6:	fffff097          	auipc	ra,0xfffff
    800053ca:	c96080e7          	jalr	-874(ra) # 8000405c <dirlink>
    800053ce:	00054f63          	bltz	a0,800053ec <create+0x142>
    800053d2:	00492603          	lw	a2,4(s2)
    800053d6:	00003597          	auipc	a1,0x3
    800053da:	34258593          	addi	a1,a1,834 # 80008718 <syscalls+0x2d0>
    800053de:	8526                	mv	a0,s1
    800053e0:	fffff097          	auipc	ra,0xfffff
    800053e4:	c7c080e7          	jalr	-900(ra) # 8000405c <dirlink>
    800053e8:	f80557e3          	bgez	a0,80005376 <create+0xcc>
      panic("create dots");
    800053ec:	00003517          	auipc	a0,0x3
    800053f0:	33450513          	addi	a0,a0,820 # 80008720 <syscalls+0x2d8>
    800053f4:	ffffb097          	auipc	ra,0xffffb
    800053f8:	144080e7          	jalr	324(ra) # 80000538 <panic>
    panic("create: dirlink");
    800053fc:	00003517          	auipc	a0,0x3
    80005400:	33450513          	addi	a0,a0,820 # 80008730 <syscalls+0x2e8>
    80005404:	ffffb097          	auipc	ra,0xffffb
    80005408:	134080e7          	jalr	308(ra) # 80000538 <panic>
    return 0;
    8000540c:	84aa                	mv	s1,a0
    8000540e:	b739                	j	8000531c <create+0x72>

0000000080005410 <sys_dup>:
{
    80005410:	7179                	addi	sp,sp,-48
    80005412:	f406                	sd	ra,40(sp)
    80005414:	f022                	sd	s0,32(sp)
    80005416:	ec26                	sd	s1,24(sp)
    80005418:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000541a:	fd840613          	addi	a2,s0,-40
    8000541e:	4581                	li	a1,0
    80005420:	4501                	li	a0,0
    80005422:	00000097          	auipc	ra,0x0
    80005426:	dde080e7          	jalr	-546(ra) # 80005200 <argfd>
    return -1;
    8000542a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000542c:	02054363          	bltz	a0,80005452 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005430:	fd843503          	ld	a0,-40(s0)
    80005434:	00000097          	auipc	ra,0x0
    80005438:	e34080e7          	jalr	-460(ra) # 80005268 <fdalloc>
    8000543c:	84aa                	mv	s1,a0
    return -1;
    8000543e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005440:	00054963          	bltz	a0,80005452 <sys_dup+0x42>
  filedup(f);
    80005444:	fd843503          	ld	a0,-40(s0)
    80005448:	fffff097          	auipc	ra,0xfffff
    8000544c:	36c080e7          	jalr	876(ra) # 800047b4 <filedup>
  return fd;
    80005450:	87a6                	mv	a5,s1
}
    80005452:	853e                	mv	a0,a5
    80005454:	70a2                	ld	ra,40(sp)
    80005456:	7402                	ld	s0,32(sp)
    80005458:	64e2                	ld	s1,24(sp)
    8000545a:	6145                	addi	sp,sp,48
    8000545c:	8082                	ret

000000008000545e <sys_read>:
{
    8000545e:	7179                	addi	sp,sp,-48
    80005460:	f406                	sd	ra,40(sp)
    80005462:	f022                	sd	s0,32(sp)
    80005464:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005466:	fe840613          	addi	a2,s0,-24
    8000546a:	4581                	li	a1,0
    8000546c:	4501                	li	a0,0
    8000546e:	00000097          	auipc	ra,0x0
    80005472:	d92080e7          	jalr	-622(ra) # 80005200 <argfd>
    return -1;
    80005476:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005478:	04054163          	bltz	a0,800054ba <sys_read+0x5c>
    8000547c:	fe440593          	addi	a1,s0,-28
    80005480:	4509                	li	a0,2
    80005482:	ffffe097          	auipc	ra,0xffffe
    80005486:	962080e7          	jalr	-1694(ra) # 80002de4 <argint>
    return -1;
    8000548a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000548c:	02054763          	bltz	a0,800054ba <sys_read+0x5c>
    80005490:	fd840593          	addi	a1,s0,-40
    80005494:	4505                	li	a0,1
    80005496:	ffffe097          	auipc	ra,0xffffe
    8000549a:	970080e7          	jalr	-1680(ra) # 80002e06 <argaddr>
    return -1;
    8000549e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054a0:	00054d63          	bltz	a0,800054ba <sys_read+0x5c>
  return fileread(f, p, n);
    800054a4:	fe442603          	lw	a2,-28(s0)
    800054a8:	fd843583          	ld	a1,-40(s0)
    800054ac:	fe843503          	ld	a0,-24(s0)
    800054b0:	fffff097          	auipc	ra,0xfffff
    800054b4:	490080e7          	jalr	1168(ra) # 80004940 <fileread>
    800054b8:	87aa                	mv	a5,a0
}
    800054ba:	853e                	mv	a0,a5
    800054bc:	70a2                	ld	ra,40(sp)
    800054be:	7402                	ld	s0,32(sp)
    800054c0:	6145                	addi	sp,sp,48
    800054c2:	8082                	ret

00000000800054c4 <sys_write>:
{
    800054c4:	7179                	addi	sp,sp,-48
    800054c6:	f406                	sd	ra,40(sp)
    800054c8:	f022                	sd	s0,32(sp)
    800054ca:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054cc:	fe840613          	addi	a2,s0,-24
    800054d0:	4581                	li	a1,0
    800054d2:	4501                	li	a0,0
    800054d4:	00000097          	auipc	ra,0x0
    800054d8:	d2c080e7          	jalr	-724(ra) # 80005200 <argfd>
    return -1;
    800054dc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054de:	04054163          	bltz	a0,80005520 <sys_write+0x5c>
    800054e2:	fe440593          	addi	a1,s0,-28
    800054e6:	4509                	li	a0,2
    800054e8:	ffffe097          	auipc	ra,0xffffe
    800054ec:	8fc080e7          	jalr	-1796(ra) # 80002de4 <argint>
    return -1;
    800054f0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054f2:	02054763          	bltz	a0,80005520 <sys_write+0x5c>
    800054f6:	fd840593          	addi	a1,s0,-40
    800054fa:	4505                	li	a0,1
    800054fc:	ffffe097          	auipc	ra,0xffffe
    80005500:	90a080e7          	jalr	-1782(ra) # 80002e06 <argaddr>
    return -1;
    80005504:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005506:	00054d63          	bltz	a0,80005520 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000550a:	fe442603          	lw	a2,-28(s0)
    8000550e:	fd843583          	ld	a1,-40(s0)
    80005512:	fe843503          	ld	a0,-24(s0)
    80005516:	fffff097          	auipc	ra,0xfffff
    8000551a:	4ec080e7          	jalr	1260(ra) # 80004a02 <filewrite>
    8000551e:	87aa                	mv	a5,a0
}
    80005520:	853e                	mv	a0,a5
    80005522:	70a2                	ld	ra,40(sp)
    80005524:	7402                	ld	s0,32(sp)
    80005526:	6145                	addi	sp,sp,48
    80005528:	8082                	ret

000000008000552a <sys_close>:
{
    8000552a:	1101                	addi	sp,sp,-32
    8000552c:	ec06                	sd	ra,24(sp)
    8000552e:	e822                	sd	s0,16(sp)
    80005530:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005532:	fe040613          	addi	a2,s0,-32
    80005536:	fec40593          	addi	a1,s0,-20
    8000553a:	4501                	li	a0,0
    8000553c:	00000097          	auipc	ra,0x0
    80005540:	cc4080e7          	jalr	-828(ra) # 80005200 <argfd>
    return -1;
    80005544:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005546:	02054463          	bltz	a0,8000556e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000554a:	ffffc097          	auipc	ra,0xffffc
    8000554e:	4b8080e7          	jalr	1208(ra) # 80001a02 <myproc>
    80005552:	fec42783          	lw	a5,-20(s0)
    80005556:	07e9                	addi	a5,a5,26
    80005558:	078e                	slli	a5,a5,0x3
    8000555a:	97aa                	add	a5,a5,a0
    8000555c:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005560:	fe043503          	ld	a0,-32(s0)
    80005564:	fffff097          	auipc	ra,0xfffff
    80005568:	2a2080e7          	jalr	674(ra) # 80004806 <fileclose>
  return 0;
    8000556c:	4781                	li	a5,0
}
    8000556e:	853e                	mv	a0,a5
    80005570:	60e2                	ld	ra,24(sp)
    80005572:	6442                	ld	s0,16(sp)
    80005574:	6105                	addi	sp,sp,32
    80005576:	8082                	ret

0000000080005578 <sys_fstat>:
{
    80005578:	1101                	addi	sp,sp,-32
    8000557a:	ec06                	sd	ra,24(sp)
    8000557c:	e822                	sd	s0,16(sp)
    8000557e:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005580:	fe840613          	addi	a2,s0,-24
    80005584:	4581                	li	a1,0
    80005586:	4501                	li	a0,0
    80005588:	00000097          	auipc	ra,0x0
    8000558c:	c78080e7          	jalr	-904(ra) # 80005200 <argfd>
    return -1;
    80005590:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005592:	02054563          	bltz	a0,800055bc <sys_fstat+0x44>
    80005596:	fe040593          	addi	a1,s0,-32
    8000559a:	4505                	li	a0,1
    8000559c:	ffffe097          	auipc	ra,0xffffe
    800055a0:	86a080e7          	jalr	-1942(ra) # 80002e06 <argaddr>
    return -1;
    800055a4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055a6:	00054b63          	bltz	a0,800055bc <sys_fstat+0x44>
  return filestat(f, st);
    800055aa:	fe043583          	ld	a1,-32(s0)
    800055ae:	fe843503          	ld	a0,-24(s0)
    800055b2:	fffff097          	auipc	ra,0xfffff
    800055b6:	31c080e7          	jalr	796(ra) # 800048ce <filestat>
    800055ba:	87aa                	mv	a5,a0
}
    800055bc:	853e                	mv	a0,a5
    800055be:	60e2                	ld	ra,24(sp)
    800055c0:	6442                	ld	s0,16(sp)
    800055c2:	6105                	addi	sp,sp,32
    800055c4:	8082                	ret

00000000800055c6 <sys_link>:
{
    800055c6:	7169                	addi	sp,sp,-304
    800055c8:	f606                	sd	ra,296(sp)
    800055ca:	f222                	sd	s0,288(sp)
    800055cc:	ee26                	sd	s1,280(sp)
    800055ce:	ea4a                	sd	s2,272(sp)
    800055d0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055d2:	08000613          	li	a2,128
    800055d6:	ed040593          	addi	a1,s0,-304
    800055da:	4501                	li	a0,0
    800055dc:	ffffe097          	auipc	ra,0xffffe
    800055e0:	84c080e7          	jalr	-1972(ra) # 80002e28 <argstr>
    return -1;
    800055e4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055e6:	10054e63          	bltz	a0,80005702 <sys_link+0x13c>
    800055ea:	08000613          	li	a2,128
    800055ee:	f5040593          	addi	a1,s0,-176
    800055f2:	4505                	li	a0,1
    800055f4:	ffffe097          	auipc	ra,0xffffe
    800055f8:	834080e7          	jalr	-1996(ra) # 80002e28 <argstr>
    return -1;
    800055fc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055fe:	10054263          	bltz	a0,80005702 <sys_link+0x13c>
  begin_op();
    80005602:	fffff097          	auipc	ra,0xfffff
    80005606:	d38080e7          	jalr	-712(ra) # 8000433a <begin_op>
  if((ip = namei(old)) == 0){
    8000560a:	ed040513          	addi	a0,s0,-304
    8000560e:	fffff097          	auipc	ra,0xfffff
    80005612:	b10080e7          	jalr	-1264(ra) # 8000411e <namei>
    80005616:	84aa                	mv	s1,a0
    80005618:	c551                	beqz	a0,800056a4 <sys_link+0xde>
  ilock(ip);
    8000561a:	ffffe097          	auipc	ra,0xffffe
    8000561e:	34e080e7          	jalr	846(ra) # 80003968 <ilock>
  if(ip->type == T_DIR){
    80005622:	04449703          	lh	a4,68(s1)
    80005626:	4785                	li	a5,1
    80005628:	08f70463          	beq	a4,a5,800056b0 <sys_link+0xea>
  ip->nlink++;
    8000562c:	04a4d783          	lhu	a5,74(s1)
    80005630:	2785                	addiw	a5,a5,1
    80005632:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005636:	8526                	mv	a0,s1
    80005638:	ffffe097          	auipc	ra,0xffffe
    8000563c:	266080e7          	jalr	614(ra) # 8000389e <iupdate>
  iunlock(ip);
    80005640:	8526                	mv	a0,s1
    80005642:	ffffe097          	auipc	ra,0xffffe
    80005646:	3e8080e7          	jalr	1000(ra) # 80003a2a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000564a:	fd040593          	addi	a1,s0,-48
    8000564e:	f5040513          	addi	a0,s0,-176
    80005652:	fffff097          	auipc	ra,0xfffff
    80005656:	aea080e7          	jalr	-1302(ra) # 8000413c <nameiparent>
    8000565a:	892a                	mv	s2,a0
    8000565c:	c935                	beqz	a0,800056d0 <sys_link+0x10a>
  ilock(dp);
    8000565e:	ffffe097          	auipc	ra,0xffffe
    80005662:	30a080e7          	jalr	778(ra) # 80003968 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005666:	00092703          	lw	a4,0(s2)
    8000566a:	409c                	lw	a5,0(s1)
    8000566c:	04f71d63          	bne	a4,a5,800056c6 <sys_link+0x100>
    80005670:	40d0                	lw	a2,4(s1)
    80005672:	fd040593          	addi	a1,s0,-48
    80005676:	854a                	mv	a0,s2
    80005678:	fffff097          	auipc	ra,0xfffff
    8000567c:	9e4080e7          	jalr	-1564(ra) # 8000405c <dirlink>
    80005680:	04054363          	bltz	a0,800056c6 <sys_link+0x100>
  iunlockput(dp);
    80005684:	854a                	mv	a0,s2
    80005686:	ffffe097          	auipc	ra,0xffffe
    8000568a:	544080e7          	jalr	1348(ra) # 80003bca <iunlockput>
  iput(ip);
    8000568e:	8526                	mv	a0,s1
    80005690:	ffffe097          	auipc	ra,0xffffe
    80005694:	492080e7          	jalr	1170(ra) # 80003b22 <iput>
  end_op();
    80005698:	fffff097          	auipc	ra,0xfffff
    8000569c:	d22080e7          	jalr	-734(ra) # 800043ba <end_op>
  return 0;
    800056a0:	4781                	li	a5,0
    800056a2:	a085                	j	80005702 <sys_link+0x13c>
    end_op();
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	d16080e7          	jalr	-746(ra) # 800043ba <end_op>
    return -1;
    800056ac:	57fd                	li	a5,-1
    800056ae:	a891                	j	80005702 <sys_link+0x13c>
    iunlockput(ip);
    800056b0:	8526                	mv	a0,s1
    800056b2:	ffffe097          	auipc	ra,0xffffe
    800056b6:	518080e7          	jalr	1304(ra) # 80003bca <iunlockput>
    end_op();
    800056ba:	fffff097          	auipc	ra,0xfffff
    800056be:	d00080e7          	jalr	-768(ra) # 800043ba <end_op>
    return -1;
    800056c2:	57fd                	li	a5,-1
    800056c4:	a83d                	j	80005702 <sys_link+0x13c>
    iunlockput(dp);
    800056c6:	854a                	mv	a0,s2
    800056c8:	ffffe097          	auipc	ra,0xffffe
    800056cc:	502080e7          	jalr	1282(ra) # 80003bca <iunlockput>
  ilock(ip);
    800056d0:	8526                	mv	a0,s1
    800056d2:	ffffe097          	auipc	ra,0xffffe
    800056d6:	296080e7          	jalr	662(ra) # 80003968 <ilock>
  ip->nlink--;
    800056da:	04a4d783          	lhu	a5,74(s1)
    800056de:	37fd                	addiw	a5,a5,-1
    800056e0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056e4:	8526                	mv	a0,s1
    800056e6:	ffffe097          	auipc	ra,0xffffe
    800056ea:	1b8080e7          	jalr	440(ra) # 8000389e <iupdate>
  iunlockput(ip);
    800056ee:	8526                	mv	a0,s1
    800056f0:	ffffe097          	auipc	ra,0xffffe
    800056f4:	4da080e7          	jalr	1242(ra) # 80003bca <iunlockput>
  end_op();
    800056f8:	fffff097          	auipc	ra,0xfffff
    800056fc:	cc2080e7          	jalr	-830(ra) # 800043ba <end_op>
  return -1;
    80005700:	57fd                	li	a5,-1
}
    80005702:	853e                	mv	a0,a5
    80005704:	70b2                	ld	ra,296(sp)
    80005706:	7412                	ld	s0,288(sp)
    80005708:	64f2                	ld	s1,280(sp)
    8000570a:	6952                	ld	s2,272(sp)
    8000570c:	6155                	addi	sp,sp,304
    8000570e:	8082                	ret

0000000080005710 <sys_unlink>:
{
    80005710:	7151                	addi	sp,sp,-240
    80005712:	f586                	sd	ra,232(sp)
    80005714:	f1a2                	sd	s0,224(sp)
    80005716:	eda6                	sd	s1,216(sp)
    80005718:	e9ca                	sd	s2,208(sp)
    8000571a:	e5ce                	sd	s3,200(sp)
    8000571c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000571e:	08000613          	li	a2,128
    80005722:	f3040593          	addi	a1,s0,-208
    80005726:	4501                	li	a0,0
    80005728:	ffffd097          	auipc	ra,0xffffd
    8000572c:	700080e7          	jalr	1792(ra) # 80002e28 <argstr>
    80005730:	18054163          	bltz	a0,800058b2 <sys_unlink+0x1a2>
  begin_op();
    80005734:	fffff097          	auipc	ra,0xfffff
    80005738:	c06080e7          	jalr	-1018(ra) # 8000433a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000573c:	fb040593          	addi	a1,s0,-80
    80005740:	f3040513          	addi	a0,s0,-208
    80005744:	fffff097          	auipc	ra,0xfffff
    80005748:	9f8080e7          	jalr	-1544(ra) # 8000413c <nameiparent>
    8000574c:	84aa                	mv	s1,a0
    8000574e:	c979                	beqz	a0,80005824 <sys_unlink+0x114>
  ilock(dp);
    80005750:	ffffe097          	auipc	ra,0xffffe
    80005754:	218080e7          	jalr	536(ra) # 80003968 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005758:	00003597          	auipc	a1,0x3
    8000575c:	fb858593          	addi	a1,a1,-72 # 80008710 <syscalls+0x2c8>
    80005760:	fb040513          	addi	a0,s0,-80
    80005764:	ffffe097          	auipc	ra,0xffffe
    80005768:	6ce080e7          	jalr	1742(ra) # 80003e32 <namecmp>
    8000576c:	14050a63          	beqz	a0,800058c0 <sys_unlink+0x1b0>
    80005770:	00003597          	auipc	a1,0x3
    80005774:	fa858593          	addi	a1,a1,-88 # 80008718 <syscalls+0x2d0>
    80005778:	fb040513          	addi	a0,s0,-80
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	6b6080e7          	jalr	1718(ra) # 80003e32 <namecmp>
    80005784:	12050e63          	beqz	a0,800058c0 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005788:	f2c40613          	addi	a2,s0,-212
    8000578c:	fb040593          	addi	a1,s0,-80
    80005790:	8526                	mv	a0,s1
    80005792:	ffffe097          	auipc	ra,0xffffe
    80005796:	6ba080e7          	jalr	1722(ra) # 80003e4c <dirlookup>
    8000579a:	892a                	mv	s2,a0
    8000579c:	12050263          	beqz	a0,800058c0 <sys_unlink+0x1b0>
  ilock(ip);
    800057a0:	ffffe097          	auipc	ra,0xffffe
    800057a4:	1c8080e7          	jalr	456(ra) # 80003968 <ilock>
  if(ip->nlink < 1)
    800057a8:	04a91783          	lh	a5,74(s2)
    800057ac:	08f05263          	blez	a5,80005830 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057b0:	04491703          	lh	a4,68(s2)
    800057b4:	4785                	li	a5,1
    800057b6:	08f70563          	beq	a4,a5,80005840 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800057ba:	4641                	li	a2,16
    800057bc:	4581                	li	a1,0
    800057be:	fc040513          	addi	a0,s0,-64
    800057c2:	ffffb097          	auipc	ra,0xffffb
    800057c6:	50a080e7          	jalr	1290(ra) # 80000ccc <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057ca:	4741                	li	a4,16
    800057cc:	f2c42683          	lw	a3,-212(s0)
    800057d0:	fc040613          	addi	a2,s0,-64
    800057d4:	4581                	li	a1,0
    800057d6:	8526                	mv	a0,s1
    800057d8:	ffffe097          	auipc	ra,0xffffe
    800057dc:	53c080e7          	jalr	1340(ra) # 80003d14 <writei>
    800057e0:	47c1                	li	a5,16
    800057e2:	0af51563          	bne	a0,a5,8000588c <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800057e6:	04491703          	lh	a4,68(s2)
    800057ea:	4785                	li	a5,1
    800057ec:	0af70863          	beq	a4,a5,8000589c <sys_unlink+0x18c>
  iunlockput(dp);
    800057f0:	8526                	mv	a0,s1
    800057f2:	ffffe097          	auipc	ra,0xffffe
    800057f6:	3d8080e7          	jalr	984(ra) # 80003bca <iunlockput>
  ip->nlink--;
    800057fa:	04a95783          	lhu	a5,74(s2)
    800057fe:	37fd                	addiw	a5,a5,-1
    80005800:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005804:	854a                	mv	a0,s2
    80005806:	ffffe097          	auipc	ra,0xffffe
    8000580a:	098080e7          	jalr	152(ra) # 8000389e <iupdate>
  iunlockput(ip);
    8000580e:	854a                	mv	a0,s2
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	3ba080e7          	jalr	954(ra) # 80003bca <iunlockput>
  end_op();
    80005818:	fffff097          	auipc	ra,0xfffff
    8000581c:	ba2080e7          	jalr	-1118(ra) # 800043ba <end_op>
  return 0;
    80005820:	4501                	li	a0,0
    80005822:	a84d                	j	800058d4 <sys_unlink+0x1c4>
    end_op();
    80005824:	fffff097          	auipc	ra,0xfffff
    80005828:	b96080e7          	jalr	-1130(ra) # 800043ba <end_op>
    return -1;
    8000582c:	557d                	li	a0,-1
    8000582e:	a05d                	j	800058d4 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005830:	00003517          	auipc	a0,0x3
    80005834:	f1050513          	addi	a0,a0,-240 # 80008740 <syscalls+0x2f8>
    80005838:	ffffb097          	auipc	ra,0xffffb
    8000583c:	d00080e7          	jalr	-768(ra) # 80000538 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005840:	04c92703          	lw	a4,76(s2)
    80005844:	02000793          	li	a5,32
    80005848:	f6e7f9e3          	bgeu	a5,a4,800057ba <sys_unlink+0xaa>
    8000584c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005850:	4741                	li	a4,16
    80005852:	86ce                	mv	a3,s3
    80005854:	f1840613          	addi	a2,s0,-232
    80005858:	4581                	li	a1,0
    8000585a:	854a                	mv	a0,s2
    8000585c:	ffffe097          	auipc	ra,0xffffe
    80005860:	3c0080e7          	jalr	960(ra) # 80003c1c <readi>
    80005864:	47c1                	li	a5,16
    80005866:	00f51b63          	bne	a0,a5,8000587c <sys_unlink+0x16c>
    if(de.inum != 0)
    8000586a:	f1845783          	lhu	a5,-232(s0)
    8000586e:	e7a1                	bnez	a5,800058b6 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005870:	29c1                	addiw	s3,s3,16
    80005872:	04c92783          	lw	a5,76(s2)
    80005876:	fcf9ede3          	bltu	s3,a5,80005850 <sys_unlink+0x140>
    8000587a:	b781                	j	800057ba <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000587c:	00003517          	auipc	a0,0x3
    80005880:	edc50513          	addi	a0,a0,-292 # 80008758 <syscalls+0x310>
    80005884:	ffffb097          	auipc	ra,0xffffb
    80005888:	cb4080e7          	jalr	-844(ra) # 80000538 <panic>
    panic("unlink: writei");
    8000588c:	00003517          	auipc	a0,0x3
    80005890:	ee450513          	addi	a0,a0,-284 # 80008770 <syscalls+0x328>
    80005894:	ffffb097          	auipc	ra,0xffffb
    80005898:	ca4080e7          	jalr	-860(ra) # 80000538 <panic>
    dp->nlink--;
    8000589c:	04a4d783          	lhu	a5,74(s1)
    800058a0:	37fd                	addiw	a5,a5,-1
    800058a2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058a6:	8526                	mv	a0,s1
    800058a8:	ffffe097          	auipc	ra,0xffffe
    800058ac:	ff6080e7          	jalr	-10(ra) # 8000389e <iupdate>
    800058b0:	b781                	j	800057f0 <sys_unlink+0xe0>
    return -1;
    800058b2:	557d                	li	a0,-1
    800058b4:	a005                	j	800058d4 <sys_unlink+0x1c4>
    iunlockput(ip);
    800058b6:	854a                	mv	a0,s2
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	312080e7          	jalr	786(ra) # 80003bca <iunlockput>
  iunlockput(dp);
    800058c0:	8526                	mv	a0,s1
    800058c2:	ffffe097          	auipc	ra,0xffffe
    800058c6:	308080e7          	jalr	776(ra) # 80003bca <iunlockput>
  end_op();
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	af0080e7          	jalr	-1296(ra) # 800043ba <end_op>
  return -1;
    800058d2:	557d                	li	a0,-1
}
    800058d4:	70ae                	ld	ra,232(sp)
    800058d6:	740e                	ld	s0,224(sp)
    800058d8:	64ee                	ld	s1,216(sp)
    800058da:	694e                	ld	s2,208(sp)
    800058dc:	69ae                	ld	s3,200(sp)
    800058de:	616d                	addi	sp,sp,240
    800058e0:	8082                	ret

00000000800058e2 <sys_open>:

uint64
sys_open(void)
{
    800058e2:	7131                	addi	sp,sp,-192
    800058e4:	fd06                	sd	ra,184(sp)
    800058e6:	f922                	sd	s0,176(sp)
    800058e8:	f526                	sd	s1,168(sp)
    800058ea:	f14a                	sd	s2,160(sp)
    800058ec:	ed4e                	sd	s3,152(sp)
    800058ee:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058f0:	08000613          	li	a2,128
    800058f4:	f5040593          	addi	a1,s0,-176
    800058f8:	4501                	li	a0,0
    800058fa:	ffffd097          	auipc	ra,0xffffd
    800058fe:	52e080e7          	jalr	1326(ra) # 80002e28 <argstr>
    return -1;
    80005902:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005904:	0c054163          	bltz	a0,800059c6 <sys_open+0xe4>
    80005908:	f4c40593          	addi	a1,s0,-180
    8000590c:	4505                	li	a0,1
    8000590e:	ffffd097          	auipc	ra,0xffffd
    80005912:	4d6080e7          	jalr	1238(ra) # 80002de4 <argint>
    80005916:	0a054863          	bltz	a0,800059c6 <sys_open+0xe4>

  begin_op();
    8000591a:	fffff097          	auipc	ra,0xfffff
    8000591e:	a20080e7          	jalr	-1504(ra) # 8000433a <begin_op>

  if(omode & O_CREATE){
    80005922:	f4c42783          	lw	a5,-180(s0)
    80005926:	2007f793          	andi	a5,a5,512
    8000592a:	cbdd                	beqz	a5,800059e0 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000592c:	4681                	li	a3,0
    8000592e:	4601                	li	a2,0
    80005930:	4589                	li	a1,2
    80005932:	f5040513          	addi	a0,s0,-176
    80005936:	00000097          	auipc	ra,0x0
    8000593a:	974080e7          	jalr	-1676(ra) # 800052aa <create>
    8000593e:	892a                	mv	s2,a0
    if(ip == 0){
    80005940:	c959                	beqz	a0,800059d6 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005942:	04491703          	lh	a4,68(s2)
    80005946:	478d                	li	a5,3
    80005948:	00f71763          	bne	a4,a5,80005956 <sys_open+0x74>
    8000594c:	04695703          	lhu	a4,70(s2)
    80005950:	47a5                	li	a5,9
    80005952:	0ce7ec63          	bltu	a5,a4,80005a2a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005956:	fffff097          	auipc	ra,0xfffff
    8000595a:	df4080e7          	jalr	-524(ra) # 8000474a <filealloc>
    8000595e:	89aa                	mv	s3,a0
    80005960:	10050263          	beqz	a0,80005a64 <sys_open+0x182>
    80005964:	00000097          	auipc	ra,0x0
    80005968:	904080e7          	jalr	-1788(ra) # 80005268 <fdalloc>
    8000596c:	84aa                	mv	s1,a0
    8000596e:	0e054663          	bltz	a0,80005a5a <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005972:	04491703          	lh	a4,68(s2)
    80005976:	478d                	li	a5,3
    80005978:	0cf70463          	beq	a4,a5,80005a40 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000597c:	4789                	li	a5,2
    8000597e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005982:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005986:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000598a:	f4c42783          	lw	a5,-180(s0)
    8000598e:	0017c713          	xori	a4,a5,1
    80005992:	8b05                	andi	a4,a4,1
    80005994:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005998:	0037f713          	andi	a4,a5,3
    8000599c:	00e03733          	snez	a4,a4
    800059a0:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059a4:	4007f793          	andi	a5,a5,1024
    800059a8:	c791                	beqz	a5,800059b4 <sys_open+0xd2>
    800059aa:	04491703          	lh	a4,68(s2)
    800059ae:	4789                	li	a5,2
    800059b0:	08f70f63          	beq	a4,a5,80005a4e <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800059b4:	854a                	mv	a0,s2
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	074080e7          	jalr	116(ra) # 80003a2a <iunlock>
  end_op();
    800059be:	fffff097          	auipc	ra,0xfffff
    800059c2:	9fc080e7          	jalr	-1540(ra) # 800043ba <end_op>

  return fd;
}
    800059c6:	8526                	mv	a0,s1
    800059c8:	70ea                	ld	ra,184(sp)
    800059ca:	744a                	ld	s0,176(sp)
    800059cc:	74aa                	ld	s1,168(sp)
    800059ce:	790a                	ld	s2,160(sp)
    800059d0:	69ea                	ld	s3,152(sp)
    800059d2:	6129                	addi	sp,sp,192
    800059d4:	8082                	ret
      end_op();
    800059d6:	fffff097          	auipc	ra,0xfffff
    800059da:	9e4080e7          	jalr	-1564(ra) # 800043ba <end_op>
      return -1;
    800059de:	b7e5                	j	800059c6 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800059e0:	f5040513          	addi	a0,s0,-176
    800059e4:	ffffe097          	auipc	ra,0xffffe
    800059e8:	73a080e7          	jalr	1850(ra) # 8000411e <namei>
    800059ec:	892a                	mv	s2,a0
    800059ee:	c905                	beqz	a0,80005a1e <sys_open+0x13c>
    ilock(ip);
    800059f0:	ffffe097          	auipc	ra,0xffffe
    800059f4:	f78080e7          	jalr	-136(ra) # 80003968 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059f8:	04491703          	lh	a4,68(s2)
    800059fc:	4785                	li	a5,1
    800059fe:	f4f712e3          	bne	a4,a5,80005942 <sys_open+0x60>
    80005a02:	f4c42783          	lw	a5,-180(s0)
    80005a06:	dba1                	beqz	a5,80005956 <sys_open+0x74>
      iunlockput(ip);
    80005a08:	854a                	mv	a0,s2
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	1c0080e7          	jalr	448(ra) # 80003bca <iunlockput>
      end_op();
    80005a12:	fffff097          	auipc	ra,0xfffff
    80005a16:	9a8080e7          	jalr	-1624(ra) # 800043ba <end_op>
      return -1;
    80005a1a:	54fd                	li	s1,-1
    80005a1c:	b76d                	j	800059c6 <sys_open+0xe4>
      end_op();
    80005a1e:	fffff097          	auipc	ra,0xfffff
    80005a22:	99c080e7          	jalr	-1636(ra) # 800043ba <end_op>
      return -1;
    80005a26:	54fd                	li	s1,-1
    80005a28:	bf79                	j	800059c6 <sys_open+0xe4>
    iunlockput(ip);
    80005a2a:	854a                	mv	a0,s2
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	19e080e7          	jalr	414(ra) # 80003bca <iunlockput>
    end_op();
    80005a34:	fffff097          	auipc	ra,0xfffff
    80005a38:	986080e7          	jalr	-1658(ra) # 800043ba <end_op>
    return -1;
    80005a3c:	54fd                	li	s1,-1
    80005a3e:	b761                	j	800059c6 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a40:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a44:	04691783          	lh	a5,70(s2)
    80005a48:	02f99223          	sh	a5,36(s3)
    80005a4c:	bf2d                	j	80005986 <sys_open+0xa4>
    itrunc(ip);
    80005a4e:	854a                	mv	a0,s2
    80005a50:	ffffe097          	auipc	ra,0xffffe
    80005a54:	026080e7          	jalr	38(ra) # 80003a76 <itrunc>
    80005a58:	bfb1                	j	800059b4 <sys_open+0xd2>
      fileclose(f);
    80005a5a:	854e                	mv	a0,s3
    80005a5c:	fffff097          	auipc	ra,0xfffff
    80005a60:	daa080e7          	jalr	-598(ra) # 80004806 <fileclose>
    iunlockput(ip);
    80005a64:	854a                	mv	a0,s2
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	164080e7          	jalr	356(ra) # 80003bca <iunlockput>
    end_op();
    80005a6e:	fffff097          	auipc	ra,0xfffff
    80005a72:	94c080e7          	jalr	-1716(ra) # 800043ba <end_op>
    return -1;
    80005a76:	54fd                	li	s1,-1
    80005a78:	b7b9                	j	800059c6 <sys_open+0xe4>

0000000080005a7a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a7a:	7175                	addi	sp,sp,-144
    80005a7c:	e506                	sd	ra,136(sp)
    80005a7e:	e122                	sd	s0,128(sp)
    80005a80:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a82:	fffff097          	auipc	ra,0xfffff
    80005a86:	8b8080e7          	jalr	-1864(ra) # 8000433a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a8a:	08000613          	li	a2,128
    80005a8e:	f7040593          	addi	a1,s0,-144
    80005a92:	4501                	li	a0,0
    80005a94:	ffffd097          	auipc	ra,0xffffd
    80005a98:	394080e7          	jalr	916(ra) # 80002e28 <argstr>
    80005a9c:	02054963          	bltz	a0,80005ace <sys_mkdir+0x54>
    80005aa0:	4681                	li	a3,0
    80005aa2:	4601                	li	a2,0
    80005aa4:	4585                	li	a1,1
    80005aa6:	f7040513          	addi	a0,s0,-144
    80005aaa:	00000097          	auipc	ra,0x0
    80005aae:	800080e7          	jalr	-2048(ra) # 800052aa <create>
    80005ab2:	cd11                	beqz	a0,80005ace <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ab4:	ffffe097          	auipc	ra,0xffffe
    80005ab8:	116080e7          	jalr	278(ra) # 80003bca <iunlockput>
  end_op();
    80005abc:	fffff097          	auipc	ra,0xfffff
    80005ac0:	8fe080e7          	jalr	-1794(ra) # 800043ba <end_op>
  return 0;
    80005ac4:	4501                	li	a0,0
}
    80005ac6:	60aa                	ld	ra,136(sp)
    80005ac8:	640a                	ld	s0,128(sp)
    80005aca:	6149                	addi	sp,sp,144
    80005acc:	8082                	ret
    end_op();
    80005ace:	fffff097          	auipc	ra,0xfffff
    80005ad2:	8ec080e7          	jalr	-1812(ra) # 800043ba <end_op>
    return -1;
    80005ad6:	557d                	li	a0,-1
    80005ad8:	b7fd                	j	80005ac6 <sys_mkdir+0x4c>

0000000080005ada <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ada:	7135                	addi	sp,sp,-160
    80005adc:	ed06                	sd	ra,152(sp)
    80005ade:	e922                	sd	s0,144(sp)
    80005ae0:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ae2:	fffff097          	auipc	ra,0xfffff
    80005ae6:	858080e7          	jalr	-1960(ra) # 8000433a <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005aea:	08000613          	li	a2,128
    80005aee:	f7040593          	addi	a1,s0,-144
    80005af2:	4501                	li	a0,0
    80005af4:	ffffd097          	auipc	ra,0xffffd
    80005af8:	334080e7          	jalr	820(ra) # 80002e28 <argstr>
    80005afc:	04054a63          	bltz	a0,80005b50 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005b00:	f6c40593          	addi	a1,s0,-148
    80005b04:	4505                	li	a0,1
    80005b06:	ffffd097          	auipc	ra,0xffffd
    80005b0a:	2de080e7          	jalr	734(ra) # 80002de4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b0e:	04054163          	bltz	a0,80005b50 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005b12:	f6840593          	addi	a1,s0,-152
    80005b16:	4509                	li	a0,2
    80005b18:	ffffd097          	auipc	ra,0xffffd
    80005b1c:	2cc080e7          	jalr	716(ra) # 80002de4 <argint>
     argint(1, &major) < 0 ||
    80005b20:	02054863          	bltz	a0,80005b50 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b24:	f6841683          	lh	a3,-152(s0)
    80005b28:	f6c41603          	lh	a2,-148(s0)
    80005b2c:	458d                	li	a1,3
    80005b2e:	f7040513          	addi	a0,s0,-144
    80005b32:	fffff097          	auipc	ra,0xfffff
    80005b36:	778080e7          	jalr	1912(ra) # 800052aa <create>
     argint(2, &minor) < 0 ||
    80005b3a:	c919                	beqz	a0,80005b50 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b3c:	ffffe097          	auipc	ra,0xffffe
    80005b40:	08e080e7          	jalr	142(ra) # 80003bca <iunlockput>
  end_op();
    80005b44:	fffff097          	auipc	ra,0xfffff
    80005b48:	876080e7          	jalr	-1930(ra) # 800043ba <end_op>
  return 0;
    80005b4c:	4501                	li	a0,0
    80005b4e:	a031                	j	80005b5a <sys_mknod+0x80>
    end_op();
    80005b50:	fffff097          	auipc	ra,0xfffff
    80005b54:	86a080e7          	jalr	-1942(ra) # 800043ba <end_op>
    return -1;
    80005b58:	557d                	li	a0,-1
}
    80005b5a:	60ea                	ld	ra,152(sp)
    80005b5c:	644a                	ld	s0,144(sp)
    80005b5e:	610d                	addi	sp,sp,160
    80005b60:	8082                	ret

0000000080005b62 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b62:	7135                	addi	sp,sp,-160
    80005b64:	ed06                	sd	ra,152(sp)
    80005b66:	e922                	sd	s0,144(sp)
    80005b68:	e526                	sd	s1,136(sp)
    80005b6a:	e14a                	sd	s2,128(sp)
    80005b6c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b6e:	ffffc097          	auipc	ra,0xffffc
    80005b72:	e94080e7          	jalr	-364(ra) # 80001a02 <myproc>
    80005b76:	892a                	mv	s2,a0
  
  begin_op();
    80005b78:	ffffe097          	auipc	ra,0xffffe
    80005b7c:	7c2080e7          	jalr	1986(ra) # 8000433a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b80:	08000613          	li	a2,128
    80005b84:	f6040593          	addi	a1,s0,-160
    80005b88:	4501                	li	a0,0
    80005b8a:	ffffd097          	auipc	ra,0xffffd
    80005b8e:	29e080e7          	jalr	670(ra) # 80002e28 <argstr>
    80005b92:	04054b63          	bltz	a0,80005be8 <sys_chdir+0x86>
    80005b96:	f6040513          	addi	a0,s0,-160
    80005b9a:	ffffe097          	auipc	ra,0xffffe
    80005b9e:	584080e7          	jalr	1412(ra) # 8000411e <namei>
    80005ba2:	84aa                	mv	s1,a0
    80005ba4:	c131                	beqz	a0,80005be8 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ba6:	ffffe097          	auipc	ra,0xffffe
    80005baa:	dc2080e7          	jalr	-574(ra) # 80003968 <ilock>
  if(ip->type != T_DIR){
    80005bae:	04449703          	lh	a4,68(s1)
    80005bb2:	4785                	li	a5,1
    80005bb4:	04f71063          	bne	a4,a5,80005bf4 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005bb8:	8526                	mv	a0,s1
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	e70080e7          	jalr	-400(ra) # 80003a2a <iunlock>
  iput(p->cwd);
    80005bc2:	15093503          	ld	a0,336(s2)
    80005bc6:	ffffe097          	auipc	ra,0xffffe
    80005bca:	f5c080e7          	jalr	-164(ra) # 80003b22 <iput>
  end_op();
    80005bce:	ffffe097          	auipc	ra,0xffffe
    80005bd2:	7ec080e7          	jalr	2028(ra) # 800043ba <end_op>
  p->cwd = ip;
    80005bd6:	14993823          	sd	s1,336(s2)
  return 0;
    80005bda:	4501                	li	a0,0
}
    80005bdc:	60ea                	ld	ra,152(sp)
    80005bde:	644a                	ld	s0,144(sp)
    80005be0:	64aa                	ld	s1,136(sp)
    80005be2:	690a                	ld	s2,128(sp)
    80005be4:	610d                	addi	sp,sp,160
    80005be6:	8082                	ret
    end_op();
    80005be8:	ffffe097          	auipc	ra,0xffffe
    80005bec:	7d2080e7          	jalr	2002(ra) # 800043ba <end_op>
    return -1;
    80005bf0:	557d                	li	a0,-1
    80005bf2:	b7ed                	j	80005bdc <sys_chdir+0x7a>
    iunlockput(ip);
    80005bf4:	8526                	mv	a0,s1
    80005bf6:	ffffe097          	auipc	ra,0xffffe
    80005bfa:	fd4080e7          	jalr	-44(ra) # 80003bca <iunlockput>
    end_op();
    80005bfe:	ffffe097          	auipc	ra,0xffffe
    80005c02:	7bc080e7          	jalr	1980(ra) # 800043ba <end_op>
    return -1;
    80005c06:	557d                	li	a0,-1
    80005c08:	bfd1                	j	80005bdc <sys_chdir+0x7a>

0000000080005c0a <sys_exec>:

uint64
sys_exec(void)
{
    80005c0a:	7145                	addi	sp,sp,-464
    80005c0c:	e786                	sd	ra,456(sp)
    80005c0e:	e3a2                	sd	s0,448(sp)
    80005c10:	ff26                	sd	s1,440(sp)
    80005c12:	fb4a                	sd	s2,432(sp)
    80005c14:	f74e                	sd	s3,424(sp)
    80005c16:	f352                	sd	s4,416(sp)
    80005c18:	ef56                	sd	s5,408(sp)
    80005c1a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c1c:	08000613          	li	a2,128
    80005c20:	f4040593          	addi	a1,s0,-192
    80005c24:	4501                	li	a0,0
    80005c26:	ffffd097          	auipc	ra,0xffffd
    80005c2a:	202080e7          	jalr	514(ra) # 80002e28 <argstr>
    return -1;
    80005c2e:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c30:	0c054a63          	bltz	a0,80005d04 <sys_exec+0xfa>
    80005c34:	e3840593          	addi	a1,s0,-456
    80005c38:	4505                	li	a0,1
    80005c3a:	ffffd097          	auipc	ra,0xffffd
    80005c3e:	1cc080e7          	jalr	460(ra) # 80002e06 <argaddr>
    80005c42:	0c054163          	bltz	a0,80005d04 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005c46:	10000613          	li	a2,256
    80005c4a:	4581                	li	a1,0
    80005c4c:	e4040513          	addi	a0,s0,-448
    80005c50:	ffffb097          	auipc	ra,0xffffb
    80005c54:	07c080e7          	jalr	124(ra) # 80000ccc <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c58:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c5c:	89a6                	mv	s3,s1
    80005c5e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c60:	02000a13          	li	s4,32
    80005c64:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c68:	00391793          	slli	a5,s2,0x3
    80005c6c:	e3040593          	addi	a1,s0,-464
    80005c70:	e3843503          	ld	a0,-456(s0)
    80005c74:	953e                	add	a0,a0,a5
    80005c76:	ffffd097          	auipc	ra,0xffffd
    80005c7a:	0d4080e7          	jalr	212(ra) # 80002d4a <fetchaddr>
    80005c7e:	02054a63          	bltz	a0,80005cb2 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005c82:	e3043783          	ld	a5,-464(s0)
    80005c86:	c3b9                	beqz	a5,80005ccc <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c88:	ffffb097          	auipc	ra,0xffffb
    80005c8c:	e58080e7          	jalr	-424(ra) # 80000ae0 <kalloc>
    80005c90:	85aa                	mv	a1,a0
    80005c92:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c96:	cd11                	beqz	a0,80005cb2 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c98:	6605                	lui	a2,0x1
    80005c9a:	e3043503          	ld	a0,-464(s0)
    80005c9e:	ffffd097          	auipc	ra,0xffffd
    80005ca2:	0fe080e7          	jalr	254(ra) # 80002d9c <fetchstr>
    80005ca6:	00054663          	bltz	a0,80005cb2 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005caa:	0905                	addi	s2,s2,1
    80005cac:	09a1                	addi	s3,s3,8
    80005cae:	fb491be3          	bne	s2,s4,80005c64 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cb2:	10048913          	addi	s2,s1,256
    80005cb6:	6088                	ld	a0,0(s1)
    80005cb8:	c529                	beqz	a0,80005d02 <sys_exec+0xf8>
    kfree(argv[i]);
    80005cba:	ffffb097          	auipc	ra,0xffffb
    80005cbe:	d2a080e7          	jalr	-726(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cc2:	04a1                	addi	s1,s1,8
    80005cc4:	ff2499e3          	bne	s1,s2,80005cb6 <sys_exec+0xac>
  return -1;
    80005cc8:	597d                	li	s2,-1
    80005cca:	a82d                	j	80005d04 <sys_exec+0xfa>
      argv[i] = 0;
    80005ccc:	0a8e                	slli	s5,s5,0x3
    80005cce:	fc040793          	addi	a5,s0,-64
    80005cd2:	9abe                	add	s5,s5,a5
    80005cd4:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffdbe10>
  int ret = exec(path, argv);
    80005cd8:	e4040593          	addi	a1,s0,-448
    80005cdc:	f4040513          	addi	a0,s0,-192
    80005ce0:	fffff097          	auipc	ra,0xfffff
    80005ce4:	178080e7          	jalr	376(ra) # 80004e58 <exec>
    80005ce8:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cea:	10048993          	addi	s3,s1,256
    80005cee:	6088                	ld	a0,0(s1)
    80005cf0:	c911                	beqz	a0,80005d04 <sys_exec+0xfa>
    kfree(argv[i]);
    80005cf2:	ffffb097          	auipc	ra,0xffffb
    80005cf6:	cf2080e7          	jalr	-782(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cfa:	04a1                	addi	s1,s1,8
    80005cfc:	ff3499e3          	bne	s1,s3,80005cee <sys_exec+0xe4>
    80005d00:	a011                	j	80005d04 <sys_exec+0xfa>
  return -1;
    80005d02:	597d                	li	s2,-1
}
    80005d04:	854a                	mv	a0,s2
    80005d06:	60be                	ld	ra,456(sp)
    80005d08:	641e                	ld	s0,448(sp)
    80005d0a:	74fa                	ld	s1,440(sp)
    80005d0c:	795a                	ld	s2,432(sp)
    80005d0e:	79ba                	ld	s3,424(sp)
    80005d10:	7a1a                	ld	s4,416(sp)
    80005d12:	6afa                	ld	s5,408(sp)
    80005d14:	6179                	addi	sp,sp,464
    80005d16:	8082                	ret

0000000080005d18 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d18:	7139                	addi	sp,sp,-64
    80005d1a:	fc06                	sd	ra,56(sp)
    80005d1c:	f822                	sd	s0,48(sp)
    80005d1e:	f426                	sd	s1,40(sp)
    80005d20:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d22:	ffffc097          	auipc	ra,0xffffc
    80005d26:	ce0080e7          	jalr	-800(ra) # 80001a02 <myproc>
    80005d2a:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d2c:	fd840593          	addi	a1,s0,-40
    80005d30:	4501                	li	a0,0
    80005d32:	ffffd097          	auipc	ra,0xffffd
    80005d36:	0d4080e7          	jalr	212(ra) # 80002e06 <argaddr>
    return -1;
    80005d3a:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d3c:	0e054063          	bltz	a0,80005e1c <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d40:	fc840593          	addi	a1,s0,-56
    80005d44:	fd040513          	addi	a0,s0,-48
    80005d48:	fffff097          	auipc	ra,0xfffff
    80005d4c:	dee080e7          	jalr	-530(ra) # 80004b36 <pipealloc>
    return -1;
    80005d50:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d52:	0c054563          	bltz	a0,80005e1c <sys_pipe+0x104>
  fd0 = -1;
    80005d56:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d5a:	fd043503          	ld	a0,-48(s0)
    80005d5e:	fffff097          	auipc	ra,0xfffff
    80005d62:	50a080e7          	jalr	1290(ra) # 80005268 <fdalloc>
    80005d66:	fca42223          	sw	a0,-60(s0)
    80005d6a:	08054c63          	bltz	a0,80005e02 <sys_pipe+0xea>
    80005d6e:	fc843503          	ld	a0,-56(s0)
    80005d72:	fffff097          	auipc	ra,0xfffff
    80005d76:	4f6080e7          	jalr	1270(ra) # 80005268 <fdalloc>
    80005d7a:	fca42023          	sw	a0,-64(s0)
    80005d7e:	06054863          	bltz	a0,80005dee <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d82:	4691                	li	a3,4
    80005d84:	fc440613          	addi	a2,s0,-60
    80005d88:	fd843583          	ld	a1,-40(s0)
    80005d8c:	68a8                	ld	a0,80(s1)
    80005d8e:	ffffc097          	auipc	ra,0xffffc
    80005d92:	8c8080e7          	jalr	-1848(ra) # 80001656 <copyout>
    80005d96:	02054063          	bltz	a0,80005db6 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d9a:	4691                	li	a3,4
    80005d9c:	fc040613          	addi	a2,s0,-64
    80005da0:	fd843583          	ld	a1,-40(s0)
    80005da4:	0591                	addi	a1,a1,4
    80005da6:	68a8                	ld	a0,80(s1)
    80005da8:	ffffc097          	auipc	ra,0xffffc
    80005dac:	8ae080e7          	jalr	-1874(ra) # 80001656 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005db0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005db2:	06055563          	bgez	a0,80005e1c <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005db6:	fc442783          	lw	a5,-60(s0)
    80005dba:	07e9                	addi	a5,a5,26
    80005dbc:	078e                	slli	a5,a5,0x3
    80005dbe:	97a6                	add	a5,a5,s1
    80005dc0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005dc4:	fc042503          	lw	a0,-64(s0)
    80005dc8:	0569                	addi	a0,a0,26
    80005dca:	050e                	slli	a0,a0,0x3
    80005dcc:	9526                	add	a0,a0,s1
    80005dce:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005dd2:	fd043503          	ld	a0,-48(s0)
    80005dd6:	fffff097          	auipc	ra,0xfffff
    80005dda:	a30080e7          	jalr	-1488(ra) # 80004806 <fileclose>
    fileclose(wf);
    80005dde:	fc843503          	ld	a0,-56(s0)
    80005de2:	fffff097          	auipc	ra,0xfffff
    80005de6:	a24080e7          	jalr	-1500(ra) # 80004806 <fileclose>
    return -1;
    80005dea:	57fd                	li	a5,-1
    80005dec:	a805                	j	80005e1c <sys_pipe+0x104>
    if(fd0 >= 0)
    80005dee:	fc442783          	lw	a5,-60(s0)
    80005df2:	0007c863          	bltz	a5,80005e02 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005df6:	01a78513          	addi	a0,a5,26
    80005dfa:	050e                	slli	a0,a0,0x3
    80005dfc:	9526                	add	a0,a0,s1
    80005dfe:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005e02:	fd043503          	ld	a0,-48(s0)
    80005e06:	fffff097          	auipc	ra,0xfffff
    80005e0a:	a00080e7          	jalr	-1536(ra) # 80004806 <fileclose>
    fileclose(wf);
    80005e0e:	fc843503          	ld	a0,-56(s0)
    80005e12:	fffff097          	auipc	ra,0xfffff
    80005e16:	9f4080e7          	jalr	-1548(ra) # 80004806 <fileclose>
    return -1;
    80005e1a:	57fd                	li	a5,-1
}
    80005e1c:	853e                	mv	a0,a5
    80005e1e:	70e2                	ld	ra,56(sp)
    80005e20:	7442                	ld	s0,48(sp)
    80005e22:	74a2                	ld	s1,40(sp)
    80005e24:	6121                	addi	sp,sp,64
    80005e26:	8082                	ret
	...

0000000080005e30 <kernelvec>:
    80005e30:	7111                	addi	sp,sp,-256
    80005e32:	e006                	sd	ra,0(sp)
    80005e34:	e40a                	sd	sp,8(sp)
    80005e36:	e80e                	sd	gp,16(sp)
    80005e38:	ec12                	sd	tp,24(sp)
    80005e3a:	f016                	sd	t0,32(sp)
    80005e3c:	f41a                	sd	t1,40(sp)
    80005e3e:	f81e                	sd	t2,48(sp)
    80005e40:	fc22                	sd	s0,56(sp)
    80005e42:	e0a6                	sd	s1,64(sp)
    80005e44:	e4aa                	sd	a0,72(sp)
    80005e46:	e8ae                	sd	a1,80(sp)
    80005e48:	ecb2                	sd	a2,88(sp)
    80005e4a:	f0b6                	sd	a3,96(sp)
    80005e4c:	f4ba                	sd	a4,104(sp)
    80005e4e:	f8be                	sd	a5,112(sp)
    80005e50:	fcc2                	sd	a6,120(sp)
    80005e52:	e146                	sd	a7,128(sp)
    80005e54:	e54a                	sd	s2,136(sp)
    80005e56:	e94e                	sd	s3,144(sp)
    80005e58:	ed52                	sd	s4,152(sp)
    80005e5a:	f156                	sd	s5,160(sp)
    80005e5c:	f55a                	sd	s6,168(sp)
    80005e5e:	f95e                	sd	s7,176(sp)
    80005e60:	fd62                	sd	s8,184(sp)
    80005e62:	e1e6                	sd	s9,192(sp)
    80005e64:	e5ea                	sd	s10,200(sp)
    80005e66:	e9ee                	sd	s11,208(sp)
    80005e68:	edf2                	sd	t3,216(sp)
    80005e6a:	f1f6                	sd	t4,224(sp)
    80005e6c:	f5fa                	sd	t5,232(sp)
    80005e6e:	f9fe                	sd	t6,240(sp)
    80005e70:	d99fc0ef          	jal	ra,80002c08 <kerneltrap>
    80005e74:	6082                	ld	ra,0(sp)
    80005e76:	6122                	ld	sp,8(sp)
    80005e78:	61c2                	ld	gp,16(sp)
    80005e7a:	7282                	ld	t0,32(sp)
    80005e7c:	7322                	ld	t1,40(sp)
    80005e7e:	73c2                	ld	t2,48(sp)
    80005e80:	7462                	ld	s0,56(sp)
    80005e82:	6486                	ld	s1,64(sp)
    80005e84:	6526                	ld	a0,72(sp)
    80005e86:	65c6                	ld	a1,80(sp)
    80005e88:	6666                	ld	a2,88(sp)
    80005e8a:	7686                	ld	a3,96(sp)
    80005e8c:	7726                	ld	a4,104(sp)
    80005e8e:	77c6                	ld	a5,112(sp)
    80005e90:	7866                	ld	a6,120(sp)
    80005e92:	688a                	ld	a7,128(sp)
    80005e94:	692a                	ld	s2,136(sp)
    80005e96:	69ca                	ld	s3,144(sp)
    80005e98:	6a6a                	ld	s4,152(sp)
    80005e9a:	7a8a                	ld	s5,160(sp)
    80005e9c:	7b2a                	ld	s6,168(sp)
    80005e9e:	7bca                	ld	s7,176(sp)
    80005ea0:	7c6a                	ld	s8,184(sp)
    80005ea2:	6c8e                	ld	s9,192(sp)
    80005ea4:	6d2e                	ld	s10,200(sp)
    80005ea6:	6dce                	ld	s11,208(sp)
    80005ea8:	6e6e                	ld	t3,216(sp)
    80005eaa:	7e8e                	ld	t4,224(sp)
    80005eac:	7f2e                	ld	t5,232(sp)
    80005eae:	7fce                	ld	t6,240(sp)
    80005eb0:	6111                	addi	sp,sp,256
    80005eb2:	10200073          	sret
    80005eb6:	00000013          	nop
    80005eba:	00000013          	nop
    80005ebe:	0001                	nop

0000000080005ec0 <timervec>:
    80005ec0:	34051573          	csrrw	a0,mscratch,a0
    80005ec4:	e10c                	sd	a1,0(a0)
    80005ec6:	e510                	sd	a2,8(a0)
    80005ec8:	e914                	sd	a3,16(a0)
    80005eca:	6d0c                	ld	a1,24(a0)
    80005ecc:	7110                	ld	a2,32(a0)
    80005ece:	6194                	ld	a3,0(a1)
    80005ed0:	96b2                	add	a3,a3,a2
    80005ed2:	e194                	sd	a3,0(a1)
    80005ed4:	4589                	li	a1,2
    80005ed6:	14459073          	csrw	sip,a1
    80005eda:	6914                	ld	a3,16(a0)
    80005edc:	6510                	ld	a2,8(a0)
    80005ede:	610c                	ld	a1,0(a0)
    80005ee0:	34051573          	csrrw	a0,mscratch,a0
    80005ee4:	30200073          	mret
	...

0000000080005eea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eea:	1141                	addi	sp,sp,-16
    80005eec:	e422                	sd	s0,8(sp)
    80005eee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ef0:	0c0007b7          	lui	a5,0xc000
    80005ef4:	4705                	li	a4,1
    80005ef6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ef8:	c3d8                	sw	a4,4(a5)
}
    80005efa:	6422                	ld	s0,8(sp)
    80005efc:	0141                	addi	sp,sp,16
    80005efe:	8082                	ret

0000000080005f00 <plicinithart>:

void
plicinithart(void)
{
    80005f00:	1141                	addi	sp,sp,-16
    80005f02:	e406                	sd	ra,8(sp)
    80005f04:	e022                	sd	s0,0(sp)
    80005f06:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f08:	ffffc097          	auipc	ra,0xffffc
    80005f0c:	ace080e7          	jalr	-1330(ra) # 800019d6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005f10:	0085171b          	slliw	a4,a0,0x8
    80005f14:	0c0027b7          	lui	a5,0xc002
    80005f18:	97ba                	add	a5,a5,a4
    80005f1a:	40200713          	li	a4,1026
    80005f1e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005f22:	00d5151b          	slliw	a0,a0,0xd
    80005f26:	0c2017b7          	lui	a5,0xc201
    80005f2a:	953e                	add	a0,a0,a5
    80005f2c:	00052023          	sw	zero,0(a0)
}
    80005f30:	60a2                	ld	ra,8(sp)
    80005f32:	6402                	ld	s0,0(sp)
    80005f34:	0141                	addi	sp,sp,16
    80005f36:	8082                	ret

0000000080005f38 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f38:	1141                	addi	sp,sp,-16
    80005f3a:	e406                	sd	ra,8(sp)
    80005f3c:	e022                	sd	s0,0(sp)
    80005f3e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f40:	ffffc097          	auipc	ra,0xffffc
    80005f44:	a96080e7          	jalr	-1386(ra) # 800019d6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f48:	00d5179b          	slliw	a5,a0,0xd
    80005f4c:	0c201537          	lui	a0,0xc201
    80005f50:	953e                	add	a0,a0,a5
  return irq;
}
    80005f52:	4148                	lw	a0,4(a0)
    80005f54:	60a2                	ld	ra,8(sp)
    80005f56:	6402                	ld	s0,0(sp)
    80005f58:	0141                	addi	sp,sp,16
    80005f5a:	8082                	ret

0000000080005f5c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f5c:	1101                	addi	sp,sp,-32
    80005f5e:	ec06                	sd	ra,24(sp)
    80005f60:	e822                	sd	s0,16(sp)
    80005f62:	e426                	sd	s1,8(sp)
    80005f64:	1000                	addi	s0,sp,32
    80005f66:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f68:	ffffc097          	auipc	ra,0xffffc
    80005f6c:	a6e080e7          	jalr	-1426(ra) # 800019d6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f70:	00d5151b          	slliw	a0,a0,0xd
    80005f74:	0c2017b7          	lui	a5,0xc201
    80005f78:	97aa                	add	a5,a5,a0
    80005f7a:	c3c4                	sw	s1,4(a5)
}
    80005f7c:	60e2                	ld	ra,24(sp)
    80005f7e:	6442                	ld	s0,16(sp)
    80005f80:	64a2                	ld	s1,8(sp)
    80005f82:	6105                	addi	sp,sp,32
    80005f84:	8082                	ret

0000000080005f86 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f86:	1141                	addi	sp,sp,-16
    80005f88:	e406                	sd	ra,8(sp)
    80005f8a:	e022                	sd	s0,0(sp)
    80005f8c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f8e:	479d                	li	a5,7
    80005f90:	04a7cc63          	blt	a5,a0,80005fe8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005f94:	0001d797          	auipc	a5,0x1d
    80005f98:	f9c78793          	addi	a5,a5,-100 # 80022f30 <disk>
    80005f9c:	97aa                	add	a5,a5,a0
    80005f9e:	0187c783          	lbu	a5,24(a5)
    80005fa2:	ebb9                	bnez	a5,80005ff8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005fa4:	00451613          	slli	a2,a0,0x4
    80005fa8:	0001d797          	auipc	a5,0x1d
    80005fac:	f8878793          	addi	a5,a5,-120 # 80022f30 <disk>
    80005fb0:	6394                	ld	a3,0(a5)
    80005fb2:	96b2                	add	a3,a3,a2
    80005fb4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005fb8:	6398                	ld	a4,0(a5)
    80005fba:	9732                	add	a4,a4,a2
    80005fbc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005fc0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005fc4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005fc8:	953e                	add	a0,a0,a5
    80005fca:	4785                	li	a5,1
    80005fcc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005fd0:	0001d517          	auipc	a0,0x1d
    80005fd4:	f7850513          	addi	a0,a0,-136 # 80022f48 <disk+0x18>
    80005fd8:	ffffc097          	auipc	ra,0xffffc
    80005fdc:	58e080e7          	jalr	1422(ra) # 80002566 <wakeup>
}
    80005fe0:	60a2                	ld	ra,8(sp)
    80005fe2:	6402                	ld	s0,0(sp)
    80005fe4:	0141                	addi	sp,sp,16
    80005fe6:	8082                	ret
    panic("free_desc 1");
    80005fe8:	00002517          	auipc	a0,0x2
    80005fec:	79850513          	addi	a0,a0,1944 # 80008780 <syscalls+0x338>
    80005ff0:	ffffa097          	auipc	ra,0xffffa
    80005ff4:	548080e7          	jalr	1352(ra) # 80000538 <panic>
    panic("free_desc 2");
    80005ff8:	00002517          	auipc	a0,0x2
    80005ffc:	79850513          	addi	a0,a0,1944 # 80008790 <syscalls+0x348>
    80006000:	ffffa097          	auipc	ra,0xffffa
    80006004:	538080e7          	jalr	1336(ra) # 80000538 <panic>

0000000080006008 <virtio_disk_init>:
{
    80006008:	1101                	addi	sp,sp,-32
    8000600a:	ec06                	sd	ra,24(sp)
    8000600c:	e822                	sd	s0,16(sp)
    8000600e:	e426                	sd	s1,8(sp)
    80006010:	e04a                	sd	s2,0(sp)
    80006012:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006014:	00002597          	auipc	a1,0x2
    80006018:	78c58593          	addi	a1,a1,1932 # 800087a0 <syscalls+0x358>
    8000601c:	0001d517          	auipc	a0,0x1d
    80006020:	03c50513          	addi	a0,a0,60 # 80023058 <disk+0x128>
    80006024:	ffffb097          	auipc	ra,0xffffb
    80006028:	b1c080e7          	jalr	-1252(ra) # 80000b40 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000602c:	100017b7          	lui	a5,0x10001
    80006030:	4398                	lw	a4,0(a5)
    80006032:	2701                	sext.w	a4,a4
    80006034:	747277b7          	lui	a5,0x74727
    80006038:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000603c:	14f71c63          	bne	a4,a5,80006194 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006040:	100017b7          	lui	a5,0x10001
    80006044:	43dc                	lw	a5,4(a5)
    80006046:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006048:	4709                	li	a4,2
    8000604a:	14e79563          	bne	a5,a4,80006194 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000604e:	100017b7          	lui	a5,0x10001
    80006052:	479c                	lw	a5,8(a5)
    80006054:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006056:	12e79f63          	bne	a5,a4,80006194 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000605a:	100017b7          	lui	a5,0x10001
    8000605e:	47d8                	lw	a4,12(a5)
    80006060:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006062:	554d47b7          	lui	a5,0x554d4
    80006066:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000606a:	12f71563          	bne	a4,a5,80006194 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000606e:	100017b7          	lui	a5,0x10001
    80006072:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006076:	4705                	li	a4,1
    80006078:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000607a:	470d                	li	a4,3
    8000607c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000607e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006080:	c7ffe737          	lui	a4,0xc7ffe
    80006084:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdb6ef>
    80006088:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000608a:	2701                	sext.w	a4,a4
    8000608c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000608e:	472d                	li	a4,11
    80006090:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006092:	5bbc                	lw	a5,112(a5)
    80006094:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006098:	8ba1                	andi	a5,a5,8
    8000609a:	10078563          	beqz	a5,800061a4 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000609e:	100017b7          	lui	a5,0x10001
    800060a2:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800060a6:	43fc                	lw	a5,68(a5)
    800060a8:	2781                	sext.w	a5,a5
    800060aa:	10079563          	bnez	a5,800061b4 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800060ae:	100017b7          	lui	a5,0x10001
    800060b2:	5bdc                	lw	a5,52(a5)
    800060b4:	2781                	sext.w	a5,a5
  if(max == 0)
    800060b6:	10078763          	beqz	a5,800061c4 <virtio_disk_init+0x1bc>
  if(max < NUM)
    800060ba:	471d                	li	a4,7
    800060bc:	10f77c63          	bgeu	a4,a5,800061d4 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    800060c0:	ffffb097          	auipc	ra,0xffffb
    800060c4:	a20080e7          	jalr	-1504(ra) # 80000ae0 <kalloc>
    800060c8:	0001d497          	auipc	s1,0x1d
    800060cc:	e6848493          	addi	s1,s1,-408 # 80022f30 <disk>
    800060d0:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800060d2:	ffffb097          	auipc	ra,0xffffb
    800060d6:	a0e080e7          	jalr	-1522(ra) # 80000ae0 <kalloc>
    800060da:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800060dc:	ffffb097          	auipc	ra,0xffffb
    800060e0:	a04080e7          	jalr	-1532(ra) # 80000ae0 <kalloc>
    800060e4:	87aa                	mv	a5,a0
    800060e6:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800060e8:	6088                	ld	a0,0(s1)
    800060ea:	cd6d                	beqz	a0,800061e4 <virtio_disk_init+0x1dc>
    800060ec:	0001d717          	auipc	a4,0x1d
    800060f0:	e4c73703          	ld	a4,-436(a4) # 80022f38 <disk+0x8>
    800060f4:	cb65                	beqz	a4,800061e4 <virtio_disk_init+0x1dc>
    800060f6:	c7fd                	beqz	a5,800061e4 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    800060f8:	6605                	lui	a2,0x1
    800060fa:	4581                	li	a1,0
    800060fc:	ffffb097          	auipc	ra,0xffffb
    80006100:	bd0080e7          	jalr	-1072(ra) # 80000ccc <memset>
  memset(disk.avail, 0, PGSIZE);
    80006104:	0001d497          	auipc	s1,0x1d
    80006108:	e2c48493          	addi	s1,s1,-468 # 80022f30 <disk>
    8000610c:	6605                	lui	a2,0x1
    8000610e:	4581                	li	a1,0
    80006110:	6488                	ld	a0,8(s1)
    80006112:	ffffb097          	auipc	ra,0xffffb
    80006116:	bba080e7          	jalr	-1094(ra) # 80000ccc <memset>
  memset(disk.used, 0, PGSIZE);
    8000611a:	6605                	lui	a2,0x1
    8000611c:	4581                	li	a1,0
    8000611e:	6888                	ld	a0,16(s1)
    80006120:	ffffb097          	auipc	ra,0xffffb
    80006124:	bac080e7          	jalr	-1108(ra) # 80000ccc <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006128:	100017b7          	lui	a5,0x10001
    8000612c:	4721                	li	a4,8
    8000612e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006130:	4098                	lw	a4,0(s1)
    80006132:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006136:	40d8                	lw	a4,4(s1)
    80006138:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000613c:	6498                	ld	a4,8(s1)
    8000613e:	0007069b          	sext.w	a3,a4
    80006142:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006146:	9701                	srai	a4,a4,0x20
    80006148:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000614c:	6898                	ld	a4,16(s1)
    8000614e:	0007069b          	sext.w	a3,a4
    80006152:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006156:	9701                	srai	a4,a4,0x20
    80006158:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000615c:	4705                	li	a4,1
    8000615e:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80006160:	00e48c23          	sb	a4,24(s1)
    80006164:	00e48ca3          	sb	a4,25(s1)
    80006168:	00e48d23          	sb	a4,26(s1)
    8000616c:	00e48da3          	sb	a4,27(s1)
    80006170:	00e48e23          	sb	a4,28(s1)
    80006174:	00e48ea3          	sb	a4,29(s1)
    80006178:	00e48f23          	sb	a4,30(s1)
    8000617c:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006180:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006184:	0727a823          	sw	s2,112(a5)
}
    80006188:	60e2                	ld	ra,24(sp)
    8000618a:	6442                	ld	s0,16(sp)
    8000618c:	64a2                	ld	s1,8(sp)
    8000618e:	6902                	ld	s2,0(sp)
    80006190:	6105                	addi	sp,sp,32
    80006192:	8082                	ret
    panic("could not find virtio disk");
    80006194:	00002517          	auipc	a0,0x2
    80006198:	61c50513          	addi	a0,a0,1564 # 800087b0 <syscalls+0x368>
    8000619c:	ffffa097          	auipc	ra,0xffffa
    800061a0:	39c080e7          	jalr	924(ra) # 80000538 <panic>
    panic("virtio disk FEATURES_OK unset");
    800061a4:	00002517          	auipc	a0,0x2
    800061a8:	62c50513          	addi	a0,a0,1580 # 800087d0 <syscalls+0x388>
    800061ac:	ffffa097          	auipc	ra,0xffffa
    800061b0:	38c080e7          	jalr	908(ra) # 80000538 <panic>
    panic("virtio disk should not be ready");
    800061b4:	00002517          	auipc	a0,0x2
    800061b8:	63c50513          	addi	a0,a0,1596 # 800087f0 <syscalls+0x3a8>
    800061bc:	ffffa097          	auipc	ra,0xffffa
    800061c0:	37c080e7          	jalr	892(ra) # 80000538 <panic>
    panic("virtio disk has no queue 0");
    800061c4:	00002517          	auipc	a0,0x2
    800061c8:	64c50513          	addi	a0,a0,1612 # 80008810 <syscalls+0x3c8>
    800061cc:	ffffa097          	auipc	ra,0xffffa
    800061d0:	36c080e7          	jalr	876(ra) # 80000538 <panic>
    panic("virtio disk max queue too short");
    800061d4:	00002517          	auipc	a0,0x2
    800061d8:	65c50513          	addi	a0,a0,1628 # 80008830 <syscalls+0x3e8>
    800061dc:	ffffa097          	auipc	ra,0xffffa
    800061e0:	35c080e7          	jalr	860(ra) # 80000538 <panic>
    panic("virtio disk kalloc");
    800061e4:	00002517          	auipc	a0,0x2
    800061e8:	66c50513          	addi	a0,a0,1644 # 80008850 <syscalls+0x408>
    800061ec:	ffffa097          	auipc	ra,0xffffa
    800061f0:	34c080e7          	jalr	844(ra) # 80000538 <panic>

00000000800061f4 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061f4:	7119                	addi	sp,sp,-128
    800061f6:	fc86                	sd	ra,120(sp)
    800061f8:	f8a2                	sd	s0,112(sp)
    800061fa:	f4a6                	sd	s1,104(sp)
    800061fc:	f0ca                	sd	s2,96(sp)
    800061fe:	ecce                	sd	s3,88(sp)
    80006200:	e8d2                	sd	s4,80(sp)
    80006202:	e4d6                	sd	s5,72(sp)
    80006204:	e0da                	sd	s6,64(sp)
    80006206:	fc5e                	sd	s7,56(sp)
    80006208:	f862                	sd	s8,48(sp)
    8000620a:	f466                	sd	s9,40(sp)
    8000620c:	f06a                	sd	s10,32(sp)
    8000620e:	ec6e                	sd	s11,24(sp)
    80006210:	0100                	addi	s0,sp,128
    80006212:	8aaa                	mv	s5,a0
    80006214:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006216:	00c52d03          	lw	s10,12(a0)
    8000621a:	001d1d1b          	slliw	s10,s10,0x1
    8000621e:	1d02                	slli	s10,s10,0x20
    80006220:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006224:	0001d517          	auipc	a0,0x1d
    80006228:	e3450513          	addi	a0,a0,-460 # 80023058 <disk+0x128>
    8000622c:	ffffb097          	auipc	ra,0xffffb
    80006230:	9a4080e7          	jalr	-1628(ra) # 80000bd0 <acquire>
  for(int i = 0; i < 3; i++){
    80006234:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006236:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006238:	0001db97          	auipc	s7,0x1d
    8000623c:	cf8b8b93          	addi	s7,s7,-776 # 80022f30 <disk>
  for(int i = 0; i < 3; i++){
    80006240:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006242:	0001dc97          	auipc	s9,0x1d
    80006246:	e16c8c93          	addi	s9,s9,-490 # 80023058 <disk+0x128>
    8000624a:	a08d                	j	800062ac <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000624c:	00fb8733          	add	a4,s7,a5
    80006250:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006254:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006256:	0207c563          	bltz	a5,80006280 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000625a:	2905                	addiw	s2,s2,1
    8000625c:	0611                	addi	a2,a2,4
    8000625e:	05690c63          	beq	s2,s6,800062b6 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006262:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006264:	0001d717          	auipc	a4,0x1d
    80006268:	ccc70713          	addi	a4,a4,-820 # 80022f30 <disk>
    8000626c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000626e:	01874683          	lbu	a3,24(a4)
    80006272:	fee9                	bnez	a3,8000624c <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006274:	2785                	addiw	a5,a5,1
    80006276:	0705                	addi	a4,a4,1
    80006278:	fe979be3          	bne	a5,s1,8000626e <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000627c:	57fd                	li	a5,-1
    8000627e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006280:	01205d63          	blez	s2,8000629a <virtio_disk_rw+0xa6>
    80006284:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006286:	000a2503          	lw	a0,0(s4)
    8000628a:	00000097          	auipc	ra,0x0
    8000628e:	cfc080e7          	jalr	-772(ra) # 80005f86 <free_desc>
      for(int j = 0; j < i; j++)
    80006292:	2d85                	addiw	s11,s11,1
    80006294:	0a11                	addi	s4,s4,4
    80006296:	ffb918e3          	bne	s2,s11,80006286 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000629a:	85e6                	mv	a1,s9
    8000629c:	0001d517          	auipc	a0,0x1d
    800062a0:	cac50513          	addi	a0,a0,-852 # 80022f48 <disk+0x18>
    800062a4:	ffffc097          	auipc	ra,0xffffc
    800062a8:	136080e7          	jalr	310(ra) # 800023da <sleep>
  for(int i = 0; i < 3; i++){
    800062ac:	f8040a13          	addi	s4,s0,-128
{
    800062b0:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800062b2:	894e                	mv	s2,s3
    800062b4:	b77d                	j	80006262 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062b6:	f8042583          	lw	a1,-128(s0)
    800062ba:	00a58793          	addi	a5,a1,10
    800062be:	0792                	slli	a5,a5,0x4

  if(write)
    800062c0:	0001d617          	auipc	a2,0x1d
    800062c4:	c7060613          	addi	a2,a2,-912 # 80022f30 <disk>
    800062c8:	00f60733          	add	a4,a2,a5
    800062cc:	018036b3          	snez	a3,s8
    800062d0:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800062d2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800062d6:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062da:	f6078693          	addi	a3,a5,-160
    800062de:	6218                	ld	a4,0(a2)
    800062e0:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062e2:	00878513          	addi	a0,a5,8
    800062e6:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    800062e8:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062ea:	6208                	ld	a0,0(a2)
    800062ec:	96aa                	add	a3,a3,a0
    800062ee:	4741                	li	a4,16
    800062f0:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800062f2:	4705                	li	a4,1
    800062f4:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800062f8:	f8442703          	lw	a4,-124(s0)
    800062fc:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006300:	0712                	slli	a4,a4,0x4
    80006302:	953a                	add	a0,a0,a4
    80006304:	058a8693          	addi	a3,s5,88
    80006308:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000630a:	6208                	ld	a0,0(a2)
    8000630c:	972a                	add	a4,a4,a0
    8000630e:	40000693          	li	a3,1024
    80006312:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006314:	001c3c13          	seqz	s8,s8
    80006318:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000631a:	001c6c13          	ori	s8,s8,1
    8000631e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006322:	f8842603          	lw	a2,-120(s0)
    80006326:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000632a:	0001d697          	auipc	a3,0x1d
    8000632e:	c0668693          	addi	a3,a3,-1018 # 80022f30 <disk>
    80006332:	00258713          	addi	a4,a1,2
    80006336:	0712                	slli	a4,a4,0x4
    80006338:	9736                	add	a4,a4,a3
    8000633a:	587d                	li	a6,-1
    8000633c:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006340:	0612                	slli	a2,a2,0x4
    80006342:	9532                	add	a0,a0,a2
    80006344:	f9078793          	addi	a5,a5,-112
    80006348:	97b6                	add	a5,a5,a3
    8000634a:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    8000634c:	629c                	ld	a5,0(a3)
    8000634e:	97b2                	add	a5,a5,a2
    80006350:	4605                	li	a2,1
    80006352:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006354:	4509                	li	a0,2
    80006356:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    8000635a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000635e:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006362:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006366:	6698                	ld	a4,8(a3)
    80006368:	00275783          	lhu	a5,2(a4)
    8000636c:	8b9d                	andi	a5,a5,7
    8000636e:	0786                	slli	a5,a5,0x1
    80006370:	97ba                	add	a5,a5,a4
    80006372:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006376:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000637a:	6698                	ld	a4,8(a3)
    8000637c:	00275783          	lhu	a5,2(a4)
    80006380:	2785                	addiw	a5,a5,1
    80006382:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006386:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000638a:	100017b7          	lui	a5,0x10001
    8000638e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006392:	004aa783          	lw	a5,4(s5)
    80006396:	02c79163          	bne	a5,a2,800063b8 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000639a:	0001d917          	auipc	s2,0x1d
    8000639e:	cbe90913          	addi	s2,s2,-834 # 80023058 <disk+0x128>
  while(b->disk == 1) {
    800063a2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800063a4:	85ca                	mv	a1,s2
    800063a6:	8556                	mv	a0,s5
    800063a8:	ffffc097          	auipc	ra,0xffffc
    800063ac:	032080e7          	jalr	50(ra) # 800023da <sleep>
  while(b->disk == 1) {
    800063b0:	004aa783          	lw	a5,4(s5)
    800063b4:	fe9788e3          	beq	a5,s1,800063a4 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800063b8:	f8042903          	lw	s2,-128(s0)
    800063bc:	00290793          	addi	a5,s2,2
    800063c0:	00479713          	slli	a4,a5,0x4
    800063c4:	0001d797          	auipc	a5,0x1d
    800063c8:	b6c78793          	addi	a5,a5,-1172 # 80022f30 <disk>
    800063cc:	97ba                	add	a5,a5,a4
    800063ce:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800063d2:	0001d997          	auipc	s3,0x1d
    800063d6:	b5e98993          	addi	s3,s3,-1186 # 80022f30 <disk>
    800063da:	00491713          	slli	a4,s2,0x4
    800063de:	0009b783          	ld	a5,0(s3)
    800063e2:	97ba                	add	a5,a5,a4
    800063e4:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063e8:	854a                	mv	a0,s2
    800063ea:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063ee:	00000097          	auipc	ra,0x0
    800063f2:	b98080e7          	jalr	-1128(ra) # 80005f86 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800063f6:	8885                	andi	s1,s1,1
    800063f8:	f0ed                	bnez	s1,800063da <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063fa:	0001d517          	auipc	a0,0x1d
    800063fe:	c5e50513          	addi	a0,a0,-930 # 80023058 <disk+0x128>
    80006402:	ffffb097          	auipc	ra,0xffffb
    80006406:	882080e7          	jalr	-1918(ra) # 80000c84 <release>
}
    8000640a:	70e6                	ld	ra,120(sp)
    8000640c:	7446                	ld	s0,112(sp)
    8000640e:	74a6                	ld	s1,104(sp)
    80006410:	7906                	ld	s2,96(sp)
    80006412:	69e6                	ld	s3,88(sp)
    80006414:	6a46                	ld	s4,80(sp)
    80006416:	6aa6                	ld	s5,72(sp)
    80006418:	6b06                	ld	s6,64(sp)
    8000641a:	7be2                	ld	s7,56(sp)
    8000641c:	7c42                	ld	s8,48(sp)
    8000641e:	7ca2                	ld	s9,40(sp)
    80006420:	7d02                	ld	s10,32(sp)
    80006422:	6de2                	ld	s11,24(sp)
    80006424:	6109                	addi	sp,sp,128
    80006426:	8082                	ret

0000000080006428 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006428:	1101                	addi	sp,sp,-32
    8000642a:	ec06                	sd	ra,24(sp)
    8000642c:	e822                	sd	s0,16(sp)
    8000642e:	e426                	sd	s1,8(sp)
    80006430:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006432:	0001d497          	auipc	s1,0x1d
    80006436:	afe48493          	addi	s1,s1,-1282 # 80022f30 <disk>
    8000643a:	0001d517          	auipc	a0,0x1d
    8000643e:	c1e50513          	addi	a0,a0,-994 # 80023058 <disk+0x128>
    80006442:	ffffa097          	auipc	ra,0xffffa
    80006446:	78e080e7          	jalr	1934(ra) # 80000bd0 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000644a:	10001737          	lui	a4,0x10001
    8000644e:	533c                	lw	a5,96(a4)
    80006450:	8b8d                	andi	a5,a5,3
    80006452:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006454:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006458:	689c                	ld	a5,16(s1)
    8000645a:	0204d703          	lhu	a4,32(s1)
    8000645e:	0027d783          	lhu	a5,2(a5)
    80006462:	04f70863          	beq	a4,a5,800064b2 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006466:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000646a:	6898                	ld	a4,16(s1)
    8000646c:	0204d783          	lhu	a5,32(s1)
    80006470:	8b9d                	andi	a5,a5,7
    80006472:	078e                	slli	a5,a5,0x3
    80006474:	97ba                	add	a5,a5,a4
    80006476:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006478:	00278713          	addi	a4,a5,2
    8000647c:	0712                	slli	a4,a4,0x4
    8000647e:	9726                	add	a4,a4,s1
    80006480:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006484:	e721                	bnez	a4,800064cc <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006486:	0789                	addi	a5,a5,2
    80006488:	0792                	slli	a5,a5,0x4
    8000648a:	97a6                	add	a5,a5,s1
    8000648c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000648e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006492:	ffffc097          	auipc	ra,0xffffc
    80006496:	0d4080e7          	jalr	212(ra) # 80002566 <wakeup>

    disk.used_idx += 1;
    8000649a:	0204d783          	lhu	a5,32(s1)
    8000649e:	2785                	addiw	a5,a5,1
    800064a0:	17c2                	slli	a5,a5,0x30
    800064a2:	93c1                	srli	a5,a5,0x30
    800064a4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800064a8:	6898                	ld	a4,16(s1)
    800064aa:	00275703          	lhu	a4,2(a4)
    800064ae:	faf71ce3          	bne	a4,a5,80006466 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800064b2:	0001d517          	auipc	a0,0x1d
    800064b6:	ba650513          	addi	a0,a0,-1114 # 80023058 <disk+0x128>
    800064ba:	ffffa097          	auipc	ra,0xffffa
    800064be:	7ca080e7          	jalr	1994(ra) # 80000c84 <release>
}
    800064c2:	60e2                	ld	ra,24(sp)
    800064c4:	6442                	ld	s0,16(sp)
    800064c6:	64a2                	ld	s1,8(sp)
    800064c8:	6105                	addi	sp,sp,32
    800064ca:	8082                	ret
      panic("virtio_disk_intr status");
    800064cc:	00002517          	auipc	a0,0x2
    800064d0:	39c50513          	addi	a0,a0,924 # 80008868 <syscalls+0x420>
    800064d4:	ffffa097          	auipc	ra,0xffffa
    800064d8:	064080e7          	jalr	100(ra) # 80000538 <panic>

00000000800064dc <enqueue>:
 * @param queue_num the queue to add the process to
 * @param to_insert process to insert
 * @param pass the process' pass value
 */
void enqueue(qentry qtable[QTABLE_SIZE], int queue_num, uint64_t to_insert, uint64_t pass)
{
    800064dc:	1141                	addi	sp,sp,-16
    800064de:	e422                	sd	s0,8(sp)
    800064e0:	0800                	addi	s0,sp,16
    uint64_t curr;
    curr = gethead(queue_num);
    800064e2:	0015959b          	slliw	a1,a1,0x1
    800064e6:	0405859b          	addiw	a1,a1,64

    qtable[to_insert].pass = pass;
    800064ea:	00161793          	slli	a5,a2,0x1
    800064ee:	97b2                	add	a5,a5,a2
    800064f0:	078e                	slli	a5,a5,0x3
    800064f2:	97aa                	add	a5,a5,a0
    800064f4:	e394                	sd	a3,0(a5)

    qtable[to_insert].next = qtable[curr].next;
    800064f6:	00159713          	slli	a4,a1,0x1
    800064fa:	972e                	add	a4,a4,a1
    800064fc:	070e                	slli	a4,a4,0x3
    800064fe:	972a                	add	a4,a4,a0
    80006500:	6b14                	ld	a3,16(a4)
    80006502:	eb94                	sd	a3,16(a5)
    qtable[to_insert].prev = curr;
    80006504:	e78c                	sd	a1,8(a5)
    qtable[curr].next = to_insert;
    80006506:	eb10                	sd	a2,16(a4)
    qtable[qtable[to_insert].next].prev = to_insert;
    80006508:	6b98                	ld	a4,16(a5)
    8000650a:	00171793          	slli	a5,a4,0x1
    8000650e:	97ba                	add	a5,a5,a4
    80006510:	078e                	slli	a5,a5,0x3
    80006512:	953e                	add	a0,a0,a5
    80006514:	e510                	sd	a2,8(a0)
    }

    printf("enqueue front %d\n", to_insert);
    print_queue(qtable);
#endif
}
    80006516:	6422                	ld	s0,8(sp)
    80006518:	0141                	addi	sp,sp,16
    8000651a:	8082                	ret

000000008000651c <enqueue_back>:

void enqueue_back(qentry qtable[QTABLE_SIZE], int queue_num, uint64_t to_insert, uint64_t pass)
{
    8000651c:	1141                	addi	sp,sp,-16
    8000651e:	e422                	sd	s0,8(sp)
    80006520:	0800                	addi	s0,sp,16
    uint64_t curr;
    curr = qtable[gettail(queue_num)].prev;
    80006522:	0015959b          	slliw	a1,a1,0x1
    80006526:	04158593          	addi	a1,a1,65
    8000652a:	00159793          	slli	a5,a1,0x1
    8000652e:	97ae                	add	a5,a5,a1
    80006530:	078e                	slli	a5,a5,0x3
    80006532:	97aa                	add	a5,a5,a0
    80006534:	678c                	ld	a1,8(a5)

    qtable[to_insert].pass = pass;
    80006536:	00161793          	slli	a5,a2,0x1
    8000653a:	97b2                	add	a5,a5,a2
    8000653c:	078e                	slli	a5,a5,0x3
    8000653e:	97aa                	add	a5,a5,a0
    80006540:	e394                	sd	a3,0(a5)

    qtable[to_insert].next = qtable[curr].next;
    80006542:	00159713          	slli	a4,a1,0x1
    80006546:	972e                	add	a4,a4,a1
    80006548:	070e                	slli	a4,a4,0x3
    8000654a:	972a                	add	a4,a4,a0
    8000654c:	6b14                	ld	a3,16(a4)
    8000654e:	eb94                	sd	a3,16(a5)
    qtable[to_insert].prev = curr;
    80006550:	e78c                	sd	a1,8(a5)
    qtable[curr].next = to_insert;
    80006552:	eb10                	sd	a2,16(a4)
    qtable[qtable[to_insert].next].prev = to_insert;
    80006554:	6b98                	ld	a4,16(a5)
    80006556:	00171793          	slli	a5,a4,0x1
    8000655a:	97ba                	add	a5,a5,a4
    8000655c:	078e                	slli	a5,a5,0x3
    8000655e:	953e                	add	a0,a0,a5
    80006560:	e510                	sd	a2,8(a0)

#if DEBUG
    printf("enqueue back %d TO QUEUE %d\n", to_insert, queue_num);
    print_queue(qtable);
#endif
}
    80006562:	6422                	ld	s0,8(sp)
    80006564:	0141                	addi	sp,sp,16
    80006566:	8082                	ret

0000000080006568 <remove_pid>:
 *
 * @param qtable the qtable to remove process from
 * @param pid_to_delete process to remove
 */
void remove_pid(qentry qtable[QTABLE_SIZE], int pid_to_delete)
{
    80006568:	1141                	addi	sp,sp,-16
    8000656a:	e422                	sd	s0,8(sp)
    8000656c:	0800                	addi	s0,sp,16
    // previous' next -> to_delete's next
    qtable[qtable[pid_to_delete].prev].next = qtable[pid_to_delete].next;
    8000656e:	00159793          	slli	a5,a1,0x1
    80006572:	95be                	add	a1,a1,a5
    80006574:	058e                	slli	a1,a1,0x3
    80006576:	95aa                	add	a1,a1,a0
    80006578:	6998                	ld	a4,16(a1)
    8000657a:	6594                	ld	a3,8(a1)
    8000657c:	00169793          	slli	a5,a3,0x1
    80006580:	97b6                	add	a5,a5,a3
    80006582:	078e                	slli	a5,a5,0x3
    80006584:	97aa                	add	a5,a5,a0
    80006586:	eb98                	sd	a4,16(a5)

    // to_delete's next previous = to delet's previous
    qtable[qtable[pid_to_delete].next].prev = qtable[pid_to_delete].prev;
    80006588:	6594                	ld	a3,8(a1)
    8000658a:	00171793          	slli	a5,a4,0x1
    8000658e:	97ba                	add	a5,a5,a4
    80006590:	078e                	slli	a5,a5,0x3
    80006592:	953e                	add	a0,a0,a5
    80006594:	e514                	sd	a3,8(a0)

    qtable[pid_to_delete].next = 999;
    80006596:	3e700793          	li	a5,999
    8000659a:	e99c                	sd	a5,16(a1)
    qtable[pid_to_delete].prev = 999;
    8000659c:	e59c                	sd	a5,8(a1)
}
    8000659e:	6422                	ld	s0,8(sp)
    800065a0:	0141                	addi	sp,sp,16
    800065a2:	8082                	ret

00000000800065a4 <dequeue>:
{
    800065a4:	1101                	addi	sp,sp,-32
    800065a6:	ec06                	sd	ra,24(sp)
    800065a8:	e822                	sd	s0,16(sp)
    800065aa:	e426                	sd	s1,8(sp)
    800065ac:	1000                	addi	s0,sp,32
        if (nonempty(idx))
    800065ae:	67053603          	ld	a2,1648(a0)
    800065b2:	03f00693          	li	a3,63
    800065b6:	64050713          	addi	a4,a0,1600
    800065ba:	04200793          	li	a5,66
    800065be:	03f00593          	li	a1,63
    800065c2:	02c6fc63          	bgeu	a3,a2,800065fa <dequeue+0x56>
    800065c6:	6314                	ld	a3,0(a4)
    800065c8:	863e                	mv	a2,a5
    800065ca:	17f9                	addi	a5,a5,-2
    800065cc:	fd070713          	addi	a4,a4,-48
    800065d0:	fed5ebe3          	bltu	a1,a3,800065c6 <dequeue+0x22>
    to_delete = firstid(head);
    800065d4:	2601                	sext.w	a2,a2
    800065d6:	00161793          	slli	a5,a2,0x1
    800065da:	963e                	add	a2,a2,a5
    800065dc:	060e                	slli	a2,a2,0x3
    800065de:	962a                	add	a2,a2,a0
    800065e0:	6a04                	ld	s1,16(a2)
    remove_pid(qtable, to_delete);
    800065e2:	0004859b          	sext.w	a1,s1
    800065e6:	00000097          	auipc	ra,0x0
    800065ea:	f82080e7          	jalr	-126(ra) # 80006568 <remove_pid>
}
    800065ee:	8526                	mv	a0,s1
    800065f0:	60e2                	ld	ra,24(sp)
    800065f2:	6442                	ld	s0,16(sp)
    800065f4:	64a2                	ld	s1,8(sp)
    800065f6:	6105                	addi	sp,sp,32
    800065f8:	8082                	ret
        idx = NPROC + (i << 1);
    800065fa:	04400613          	li	a2,68
    800065fe:	bfd9                	j	800065d4 <dequeue+0x30>

0000000080006600 <initialize>:
 *
 * @param qtable qtable to initialize
 * @param num_queues the number of queues to setup
 */
void initialize(qentry qtable[QTABLE_SIZE], int num_queues)
{
    80006600:	1141                	addi	sp,sp,-16
    80006602:	e422                	sd	s0,8(sp)
    80006604:	0800                	addi	s0,sp,16
    int i;
    for (i = QTABLE_SIZE - (num_queues << 1); i < QTABLE_SIZE; i += 2)
    80006606:	0015979b          	slliw	a5,a1,0x1
    8000660a:	04600593          	li	a1,70
    8000660e:	9d9d                	subw	a1,a1,a5
    80006610:	04500793          	li	a5,69
    80006614:	02b7ca63          	blt	a5,a1,80006648 <initialize+0x48>
    80006618:	87ae                	mv	a5,a1
    8000661a:	00159713          	slli	a4,a1,0x1
    8000661e:	95ba                	add	a1,a1,a4
    80006620:	058e                	slli	a1,a1,0x3
    80006622:	952e                	add	a0,a0,a1
    {
        qtable[i].next = i + 1;
        qtable[i + 1].prev = i;
        qtable[i].pass = 0;
        qtable[i + 1].pass = UINT16_MAX;
    80006624:	66c1                	lui	a3,0x10
    80006626:	16fd                	addi	a3,a3,-1
    for (i = QTABLE_SIZE - (num_queues << 1); i < QTABLE_SIZE; i += 2)
    80006628:	04500613          	li	a2,69
        qtable[i].next = i + 1;
    8000662c:	00178713          	addi	a4,a5,1
    80006630:	e918                	sd	a4,16(a0)
        qtable[i + 1].prev = i;
    80006632:	f11c                	sd	a5,32(a0)
        qtable[i].pass = 0;
    80006634:	00053023          	sd	zero,0(a0)
        qtable[i + 1].pass = UINT16_MAX;
    80006638:	ed14                	sd	a3,24(a0)
    for (i = QTABLE_SIZE - (num_queues << 1); i < QTABLE_SIZE; i += 2)
    8000663a:	0789                	addi	a5,a5,2
    8000663c:	03050513          	addi	a0,a0,48
    80006640:	0007871b          	sext.w	a4,a5
    80006644:	fee654e3          	bge	a2,a4,8000662c <initialize+0x2c>
    }
}
    80006648:	6422                	ld	s0,8(sp)
    8000664a:	0141                	addi	sp,sp,16
    8000664c:	8082                	ret
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	18031073          	csrw	satp,t1
    80007092:	12000073          	sfence.vma
    80007096:	8282                	jr	t0

0000000080007098 <userret>:
    80007098:	18051073          	csrw	satp,a0
    8000709c:	12000073          	sfence.vma
    800070a0:	02000537          	lui	a0,0x2000
    800070a4:	357d                	addiw	a0,a0,-1
    800070a6:	0536                	slli	a0,a0,0xd
    800070a8:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070ac:	03053103          	ld	sp,48(a0)
    800070b0:	03853183          	ld	gp,56(a0)
    800070b4:	04053203          	ld	tp,64(a0)
    800070b8:	04853283          	ld	t0,72(a0)
    800070bc:	05053303          	ld	t1,80(a0)
    800070c0:	05853383          	ld	t2,88(a0)
    800070c4:	7120                	ld	s0,96(a0)
    800070c6:	7524                	ld	s1,104(a0)
    800070c8:	7d2c                	ld	a1,120(a0)
    800070ca:	6150                	ld	a2,128(a0)
    800070cc:	6554                	ld	a3,136(a0)
    800070ce:	6958                	ld	a4,144(a0)
    800070d0:	6d5c                	ld	a5,152(a0)
    800070d2:	0a053803          	ld	a6,160(a0)
    800070d6:	0a853883          	ld	a7,168(a0)
    800070da:	0b053903          	ld	s2,176(a0)
    800070de:	0b853983          	ld	s3,184(a0)
    800070e2:	0c053a03          	ld	s4,192(a0)
    800070e6:	0c853a83          	ld	s5,200(a0)
    800070ea:	0d053b03          	ld	s6,208(a0)
    800070ee:	0d853b83          	ld	s7,216(a0)
    800070f2:	0e053c03          	ld	s8,224(a0)
    800070f6:	0e853c83          	ld	s9,232(a0)
    800070fa:	0f053d03          	ld	s10,240(a0)
    800070fe:	0f853d83          	ld	s11,248(a0)
    80007102:	10053e03          	ld	t3,256(a0)
    80007106:	10853e83          	ld	t4,264(a0)
    8000710a:	11053f03          	ld	t5,272(a0)
    8000710e:	11853f83          	ld	t6,280(a0)
    80007112:	7928                	ld	a0,112(a0)
    80007114:	10200073          	sret
	...
