
user/_test_2:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <run_cpu>:

#pragma GCC push_options
#pragma GCC optimize("O0")

void run_cpu()
{
   0:	1101                	addi	sp,sp,-32
   2:	ec22                	sd	s0,24(sp)
   4:	1000                	addi	s0,sp,32
    uint64 acc = 0;
   6:	fe043423          	sd	zero,-24(s0)
    for (uint64 i = 0; i < COUNT; i++)
   a:	fe043023          	sd	zero,-32(s0)
   e:	a829                	j	28 <run_cpu+0x28>
    {
        acc += i;
  10:	fe843703          	ld	a4,-24(s0)
  14:	fe043783          	ld	a5,-32(s0)
  18:	97ba                	add	a5,a5,a4
  1a:	fef43423          	sd	a5,-24(s0)
    for (uint64 i = 0; i < COUNT; i++)
  1e:	fe043783          	ld	a5,-32(s0)
  22:	0785                	addi	a5,a5,1
  24:	fef43023          	sd	a5,-32(s0)
  28:	fe043703          	ld	a4,-32(s0)
  2c:	3b9ad7b7          	lui	a5,0x3b9ad
  30:	9ff78793          	addi	a5,a5,-1537 # 3b9ac9ff <__global_pointer$+0x3b9ab766>
  34:	fce7fee3          	bgeu	a5,a4,10 <run_cpu+0x10>
    }
}
  38:	0001                	nop
  3a:	0001                	nop
  3c:	6462                	ld	s0,24(sp)
  3e:	6105                	addi	sp,sp,32
  40:	8082                	ret

0000000000000042 <run_io>:

void run_io()
{
  42:	1101                	addi	sp,sp,-32
  44:	ec06                	sd	ra,24(sp)
  46:	e822                	sd	s0,16(sp)
  48:	1000                	addi	s0,sp,32
    for (uint64 i=0; i < 5; i++) {
  4a:	fe043423          	sd	zero,-24(s0)
  4e:	a819                	j	64 <run_io+0x22>
        sleep(1);
  50:	4505                	li	a0,1
  52:	00000097          	auipc	ra,0x0
  56:	4a6080e7          	jalr	1190(ra) # 4f8 <sleep>
    for (uint64 i=0; i < 5; i++) {
  5a:	fe843783          	ld	a5,-24(s0)
  5e:	0785                	addi	a5,a5,1
  60:	fef43423          	sd	a5,-24(s0)
  64:	fe843703          	ld	a4,-24(s0)
  68:	4791                	li	a5,4
  6a:	fee7f3e3          	bgeu	a5,a4,50 <run_io+0xe>
    }
}
  6e:	0001                	nop
  70:	0001                	nop
  72:	60e2                	ld	ra,24(sp)
  74:	6442                	ld	s0,16(sp)
  76:	6105                	addi	sp,sp,32
  78:	8082                	ret

000000000000007a <main>:

#pragma GCC pop_options

int main(int argc, char *argv[])
{
  7a:	711d                	addi	sp,sp,-96
  7c:	ec86                	sd	ra,88(sp)
  7e:	e8a2                	sd	s0,80(sp)
  80:	e4a6                	sd	s1,72(sp)
  82:	e0ca                	sd	s2,64(sp)
  84:	fc4e                	sd	s3,56(sp)
  86:	f852                	sd	s4,48(sp)
  88:	f456                	sd	s5,40(sp)
  8a:	f05a                	sd	s6,32(sp)
  8c:	ec5e                	sd	s7,24(sp)
  8e:	e862                	sd	s8,16(sp)
  90:	e466                	sd	s9,8(sp)
  92:	e06a                	sd	s10,0(sp)
  94:	1080                	addi	s0,sp,96
    int a, b;
    startlog();
  96:	00000097          	auipc	ra,0x0
  9a:	472080e7          	jalr	1138(ra) # 508 <startlog>

    a = fork();
  9e:	00000097          	auipc	ra,0x0
  a2:	3c2080e7          	jalr	962(ra) # 460 <fork>
    if (a == 0)
  a6:	ed19                	bnez	a0,c4 <main+0x4a>
    {
        // child
        nice(-19);
  a8:	5535                	li	a0,-19
  aa:	00000097          	auipc	ra,0x0
  ae:	46e080e7          	jalr	1134(ra) # 518 <nice>
        run_io();
  b2:	00000097          	auipc	ra,0x0
  b6:	f90080e7          	jalr	-112(ra) # 42 <run_io>
        exit(0);
  ba:	4501                	li	a0,0
  bc:	00000097          	auipc	ra,0x0
  c0:	3ac080e7          	jalr	940(ra) # 468 <exit>
  c4:	84aa                	mv	s1,a0
    }
    else
    {
        b = fork();
  c6:	00000097          	auipc	ra,0x0
  ca:	39a080e7          	jalr	922(ra) # 460 <fork>
  ce:	892a                	mv	s2,a0
        // parent
        if (b == 0)
  d0:	ed19                	bnez	a0,ee <main+0x74>
        {
            // child
            nice(-19);
  d2:	5535                	li	a0,-19
  d4:	00000097          	auipc	ra,0x0
  d8:	444080e7          	jalr	1092(ra) # 518 <nice>
            run_cpu();
  dc:	00000097          	auipc	ra,0x0
  e0:	f24080e7          	jalr	-220(ra) # 0 <run_cpu>
            exit(0);
  e4:	4501                	li	a0,0
  e6:	00000097          	auipc	ra,0x0
  ea:	382080e7          	jalr	898(ra) # 468 <exit>
        }
    }
    printf("parent pid: %d\n", getpid());
  ee:	00000097          	auipc	ra,0x0
  f2:	3fa080e7          	jalr	1018(ra) # 4e8 <getpid>
  f6:	85aa                	mv	a1,a0
  f8:	00001517          	auipc	a0,0x1
  fc:	8c050513          	addi	a0,a0,-1856 # 9b8 <malloc+0x102>
 100:	00000097          	auipc	ra,0x0
 104:	6f8080e7          	jalr	1784(ra) # 7f8 <printf>
    printf("first child (io bound) pid: %d\n", a);
 108:	85a6                	mv	a1,s1
 10a:	00001517          	auipc	a0,0x1
 10e:	8be50513          	addi	a0,a0,-1858 # 9c8 <malloc+0x112>
 112:	00000097          	auipc	ra,0x0
 116:	6e6080e7          	jalr	1766(ra) # 7f8 <printf>
    printf("second child (cpu bound) pid: %d\n", b);
 11a:	85ca                	mv	a1,s2
 11c:	00001517          	auipc	a0,0x1
 120:	8cc50513          	addi	a0,a0,-1844 # 9e8 <malloc+0x132>
 124:	00000097          	auipc	ra,0x0
 128:	6d4080e7          	jalr	1748(ra) # 7f8 <printf>

    wait(0);
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	342080e7          	jalr	834(ra) # 470 <wait>
    wait(0);
 136:	4501                	li	a0,0
 138:	00000097          	auipc	ra,0x0
 13c:	338080e7          	jalr	824(ra) # 470 <wait>
    printf("long running completed\n\n");
 140:	00001517          	auipc	a0,0x1
 144:	8d050513          	addi	a0,a0,-1840 # a10 <malloc+0x15a>
 148:	00000097          	auipc	ra,0x0
 14c:	6b0080e7          	jalr	1712(ra) # 7f8 <printf>

    uint64 count = getlog(schedlog);
 150:	00001517          	auipc	a0,0x1
 154:	95850513          	addi	a0,a0,-1704 # aa8 <schedlog>
 158:	00000097          	auipc	ra,0x0
 15c:	3b8080e7          	jalr	952(ra) # 510 <getlog>
 160:	89aa                	mv	s3,a0

    for (int i = 0; i < count; i++)
 162:	c935                	beqz	a0,1d6 <main+0x15c>
 164:	00001497          	auipc	s1,0x1
 168:	94448493          	addi	s1,s1,-1724 # aa8 <schedlog>
 16c:	4901                	li	s2,0
    {
        if (schedlog[i].priority_boost)
            printf("** priority boost at time %d **\n", schedlog[i].time);
        else
            printf("pid %d started at %d in queue %s\n", schedlog[i].pid, schedlog[i].time, schedlog[i].queue == 2 ? "High" : schedlog[i].queue == 1 ? "Medium"
 16e:	4b09                	li	s6,2
 170:	00001a97          	auipc	s5,0x1
 174:	830a8a93          	addi	s5,s5,-2000 # 9a0 <malloc+0xea>
 178:	00001a17          	auipc	s4,0x1
 17c:	8e0a0a13          	addi	s4,s4,-1824 # a58 <malloc+0x1a2>
                                                                                                                                                     : "Low");
 180:	4c05                	li	s8,1
 182:	00001b97          	auipc	s7,0x1
 186:	826b8b93          	addi	s7,s7,-2010 # 9a8 <malloc+0xf2>
 18a:	00001d17          	auipc	s10,0x1
 18e:	826d0d13          	addi	s10,s10,-2010 # 9b0 <malloc+0xfa>
            printf("** priority boost at time %d **\n", schedlog[i].time);
 192:	00001c97          	auipc	s9,0x1
 196:	89ec8c93          	addi	s9,s9,-1890 # a30 <malloc+0x17a>
 19a:	a00d                	j	1bc <main+0x142>
 19c:	40cc                	lw	a1,4(s1)
 19e:	8566                	mv	a0,s9
 1a0:	00000097          	auipc	ra,0x0
 1a4:	658080e7          	jalr	1624(ra) # 7f8 <printf>
 1a8:	a031                	j	1b4 <main+0x13a>
            printf("pid %d started at %d in queue %s\n", schedlog[i].pid, schedlog[i].time, schedlog[i].queue == 2 ? "High" : schedlog[i].queue == 1 ? "Medium"
 1aa:	8552                	mv	a0,s4
 1ac:	00000097          	auipc	ra,0x0
 1b0:	64c080e7          	jalr	1612(ra) # 7f8 <printf>
    for (int i = 0; i < count; i++)
 1b4:	0905                	addi	s2,s2,1
 1b6:	04c1                	addi	s1,s1,16
 1b8:	01390f63          	beq	s2,s3,1d6 <main+0x15c>
        if (schedlog[i].priority_boost)
 1bc:	44dc                	lw	a5,12(s1)
 1be:	fff9                	bnez	a5,19c <main+0x122>
            printf("pid %d started at %d in queue %s\n", schedlog[i].pid, schedlog[i].time, schedlog[i].queue == 2 ? "High" : schedlog[i].queue == 1 ? "Medium"
 1c0:	408c                	lw	a1,0(s1)
 1c2:	40d0                	lw	a2,4(s1)
 1c4:	449c                	lw	a5,8(s1)
 1c6:	86d6                	mv	a3,s5
 1c8:	ff6781e3          	beq	a5,s6,1aa <main+0x130>
                                                                                                                                                     : "Low");
 1cc:	86de                	mv	a3,s7
 1ce:	fd878ee3          	beq	a5,s8,1aa <main+0x130>
 1d2:	86ea                	mv	a3,s10
 1d4:	bfd9                	j	1aa <main+0x130>
    }

    exit(0);
 1d6:	4501                	li	a0,0
 1d8:	00000097          	auipc	ra,0x0
 1dc:	290080e7          	jalr	656(ra) # 468 <exit>

00000000000001e0 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e406                	sd	ra,8(sp)
 1e4:	e022                	sd	s0,0(sp)
 1e6:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1e8:	00000097          	auipc	ra,0x0
 1ec:	e92080e7          	jalr	-366(ra) # 7a <main>
  exit(0);
 1f0:	4501                	li	a0,0
 1f2:	00000097          	auipc	ra,0x0
 1f6:	276080e7          	jalr	630(ra) # 468 <exit>

00000000000001fa <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 200:	87aa                	mv	a5,a0
 202:	0585                	addi	a1,a1,1
 204:	0785                	addi	a5,a5,1
 206:	fff5c703          	lbu	a4,-1(a1)
 20a:	fee78fa3          	sb	a4,-1(a5)
 20e:	fb75                	bnez	a4,202 <strcpy+0x8>
    ;
  return os;
}
 210:	6422                	ld	s0,8(sp)
 212:	0141                	addi	sp,sp,16
 214:	8082                	ret

0000000000000216 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 21c:	00054783          	lbu	a5,0(a0)
 220:	cb91                	beqz	a5,234 <strcmp+0x1e>
 222:	0005c703          	lbu	a4,0(a1)
 226:	00f71763          	bne	a4,a5,234 <strcmp+0x1e>
    p++, q++;
 22a:	0505                	addi	a0,a0,1
 22c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 22e:	00054783          	lbu	a5,0(a0)
 232:	fbe5                	bnez	a5,222 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 234:	0005c503          	lbu	a0,0(a1)
}
 238:	40a7853b          	subw	a0,a5,a0
 23c:	6422                	ld	s0,8(sp)
 23e:	0141                	addi	sp,sp,16
 240:	8082                	ret

0000000000000242 <strlen>:

uint
strlen(const char *s)
{
 242:	1141                	addi	sp,sp,-16
 244:	e422                	sd	s0,8(sp)
 246:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 248:	00054783          	lbu	a5,0(a0)
 24c:	cf91                	beqz	a5,268 <strlen+0x26>
 24e:	0505                	addi	a0,a0,1
 250:	87aa                	mv	a5,a0
 252:	4685                	li	a3,1
 254:	9e89                	subw	a3,a3,a0
 256:	00f6853b          	addw	a0,a3,a5
 25a:	0785                	addi	a5,a5,1
 25c:	fff7c703          	lbu	a4,-1(a5)
 260:	fb7d                	bnez	a4,256 <strlen+0x14>
    ;
  return n;
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret
  for(n = 0; s[n]; n++)
 268:	4501                	li	a0,0
 26a:	bfe5                	j	262 <strlen+0x20>

000000000000026c <memset>:

void*
memset(void *dst, int c, uint n)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e422                	sd	s0,8(sp)
 270:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 272:	ca19                	beqz	a2,288 <memset+0x1c>
 274:	87aa                	mv	a5,a0
 276:	1602                	slli	a2,a2,0x20
 278:	9201                	srli	a2,a2,0x20
 27a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 27e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 282:	0785                	addi	a5,a5,1
 284:	fee79de3          	bne	a5,a4,27e <memset+0x12>
  }
  return dst;
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret

000000000000028e <strchr>:

char*
strchr(const char *s, char c)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  for(; *s; s++)
 294:	00054783          	lbu	a5,0(a0)
 298:	cb99                	beqz	a5,2ae <strchr+0x20>
    if(*s == c)
 29a:	00f58763          	beq	a1,a5,2a8 <strchr+0x1a>
  for(; *s; s++)
 29e:	0505                	addi	a0,a0,1
 2a0:	00054783          	lbu	a5,0(a0)
 2a4:	fbfd                	bnez	a5,29a <strchr+0xc>
      return (char*)s;
  return 0;
 2a6:	4501                	li	a0,0
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret
  return 0;
 2ae:	4501                	li	a0,0
 2b0:	bfe5                	j	2a8 <strchr+0x1a>

00000000000002b2 <gets>:

char*
gets(char *buf, int max)
{
 2b2:	711d                	addi	sp,sp,-96
 2b4:	ec86                	sd	ra,88(sp)
 2b6:	e8a2                	sd	s0,80(sp)
 2b8:	e4a6                	sd	s1,72(sp)
 2ba:	e0ca                	sd	s2,64(sp)
 2bc:	fc4e                	sd	s3,56(sp)
 2be:	f852                	sd	s4,48(sp)
 2c0:	f456                	sd	s5,40(sp)
 2c2:	f05a                	sd	s6,32(sp)
 2c4:	ec5e                	sd	s7,24(sp)
 2c6:	1080                	addi	s0,sp,96
 2c8:	8baa                	mv	s7,a0
 2ca:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2cc:	892a                	mv	s2,a0
 2ce:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2d0:	4aa9                	li	s5,10
 2d2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2d4:	89a6                	mv	s3,s1
 2d6:	2485                	addiw	s1,s1,1
 2d8:	0344d863          	bge	s1,s4,308 <gets+0x56>
    cc = read(0, &c, 1);
 2dc:	4605                	li	a2,1
 2de:	faf40593          	addi	a1,s0,-81
 2e2:	4501                	li	a0,0
 2e4:	00000097          	auipc	ra,0x0
 2e8:	19c080e7          	jalr	412(ra) # 480 <read>
    if(cc < 1)
 2ec:	00a05e63          	blez	a0,308 <gets+0x56>
    buf[i++] = c;
 2f0:	faf44783          	lbu	a5,-81(s0)
 2f4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2f8:	01578763          	beq	a5,s5,306 <gets+0x54>
 2fc:	0905                	addi	s2,s2,1
 2fe:	fd679be3          	bne	a5,s6,2d4 <gets+0x22>
  for(i=0; i+1 < max; ){
 302:	89a6                	mv	s3,s1
 304:	a011                	j	308 <gets+0x56>
 306:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 308:	99de                	add	s3,s3,s7
 30a:	00098023          	sb	zero,0(s3)
  return buf;
}
 30e:	855e                	mv	a0,s7
 310:	60e6                	ld	ra,88(sp)
 312:	6446                	ld	s0,80(sp)
 314:	64a6                	ld	s1,72(sp)
 316:	6906                	ld	s2,64(sp)
 318:	79e2                	ld	s3,56(sp)
 31a:	7a42                	ld	s4,48(sp)
 31c:	7aa2                	ld	s5,40(sp)
 31e:	7b02                	ld	s6,32(sp)
 320:	6be2                	ld	s7,24(sp)
 322:	6125                	addi	sp,sp,96
 324:	8082                	ret

0000000000000326 <stat>:

int
stat(const char *n, struct stat *st)
{
 326:	1101                	addi	sp,sp,-32
 328:	ec06                	sd	ra,24(sp)
 32a:	e822                	sd	s0,16(sp)
 32c:	e426                	sd	s1,8(sp)
 32e:	e04a                	sd	s2,0(sp)
 330:	1000                	addi	s0,sp,32
 332:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 334:	4581                	li	a1,0
 336:	00000097          	auipc	ra,0x0
 33a:	172080e7          	jalr	370(ra) # 4a8 <open>
  if(fd < 0)
 33e:	02054563          	bltz	a0,368 <stat+0x42>
 342:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 344:	85ca                	mv	a1,s2
 346:	00000097          	auipc	ra,0x0
 34a:	17a080e7          	jalr	378(ra) # 4c0 <fstat>
 34e:	892a                	mv	s2,a0
  close(fd);
 350:	8526                	mv	a0,s1
 352:	00000097          	auipc	ra,0x0
 356:	13e080e7          	jalr	318(ra) # 490 <close>
  return r;
}
 35a:	854a                	mv	a0,s2
 35c:	60e2                	ld	ra,24(sp)
 35e:	6442                	ld	s0,16(sp)
 360:	64a2                	ld	s1,8(sp)
 362:	6902                	ld	s2,0(sp)
 364:	6105                	addi	sp,sp,32
 366:	8082                	ret
    return -1;
 368:	597d                	li	s2,-1
 36a:	bfc5                	j	35a <stat+0x34>

000000000000036c <atoi>:

int
atoi(const char *s)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e422                	sd	s0,8(sp)
 370:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 372:	00054603          	lbu	a2,0(a0)
 376:	fd06079b          	addiw	a5,a2,-48
 37a:	0ff7f793          	andi	a5,a5,255
 37e:	4725                	li	a4,9
 380:	02f76963          	bltu	a4,a5,3b2 <atoi+0x46>
 384:	86aa                	mv	a3,a0
  n = 0;
 386:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 388:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 38a:	0685                	addi	a3,a3,1
 38c:	0025179b          	slliw	a5,a0,0x2
 390:	9fa9                	addw	a5,a5,a0
 392:	0017979b          	slliw	a5,a5,0x1
 396:	9fb1                	addw	a5,a5,a2
 398:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 39c:	0006c603          	lbu	a2,0(a3)
 3a0:	fd06071b          	addiw	a4,a2,-48
 3a4:	0ff77713          	andi	a4,a4,255
 3a8:	fee5f1e3          	bgeu	a1,a4,38a <atoi+0x1e>
  return n;
}
 3ac:	6422                	ld	s0,8(sp)
 3ae:	0141                	addi	sp,sp,16
 3b0:	8082                	ret
  n = 0;
 3b2:	4501                	li	a0,0
 3b4:	bfe5                	j	3ac <atoi+0x40>

00000000000003b6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3b6:	1141                	addi	sp,sp,-16
 3b8:	e422                	sd	s0,8(sp)
 3ba:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3bc:	02b57463          	bgeu	a0,a1,3e4 <memmove+0x2e>
    while(n-- > 0)
 3c0:	00c05f63          	blez	a2,3de <memmove+0x28>
 3c4:	1602                	slli	a2,a2,0x20
 3c6:	9201                	srli	a2,a2,0x20
 3c8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3cc:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ce:	0585                	addi	a1,a1,1
 3d0:	0705                	addi	a4,a4,1
 3d2:	fff5c683          	lbu	a3,-1(a1)
 3d6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3da:	fee79ae3          	bne	a5,a4,3ce <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3de:	6422                	ld	s0,8(sp)
 3e0:	0141                	addi	sp,sp,16
 3e2:	8082                	ret
    dst += n;
 3e4:	00c50733          	add	a4,a0,a2
    src += n;
 3e8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3ea:	fec05ae3          	blez	a2,3de <memmove+0x28>
 3ee:	fff6079b          	addiw	a5,a2,-1
 3f2:	1782                	slli	a5,a5,0x20
 3f4:	9381                	srli	a5,a5,0x20
 3f6:	fff7c793          	not	a5,a5
 3fa:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3fc:	15fd                	addi	a1,a1,-1
 3fe:	177d                	addi	a4,a4,-1
 400:	0005c683          	lbu	a3,0(a1)
 404:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 408:	fee79ae3          	bne	a5,a4,3fc <memmove+0x46>
 40c:	bfc9                	j	3de <memmove+0x28>

000000000000040e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 40e:	1141                	addi	sp,sp,-16
 410:	e422                	sd	s0,8(sp)
 412:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 414:	ca05                	beqz	a2,444 <memcmp+0x36>
 416:	fff6069b          	addiw	a3,a2,-1
 41a:	1682                	slli	a3,a3,0x20
 41c:	9281                	srli	a3,a3,0x20
 41e:	0685                	addi	a3,a3,1
 420:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 422:	00054783          	lbu	a5,0(a0)
 426:	0005c703          	lbu	a4,0(a1)
 42a:	00e79863          	bne	a5,a4,43a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 42e:	0505                	addi	a0,a0,1
    p2++;
 430:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 432:	fed518e3          	bne	a0,a3,422 <memcmp+0x14>
  }
  return 0;
 436:	4501                	li	a0,0
 438:	a019                	j	43e <memcmp+0x30>
      return *p1 - *p2;
 43a:	40e7853b          	subw	a0,a5,a4
}
 43e:	6422                	ld	s0,8(sp)
 440:	0141                	addi	sp,sp,16
 442:	8082                	ret
  return 0;
 444:	4501                	li	a0,0
 446:	bfe5                	j	43e <memcmp+0x30>

0000000000000448 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 448:	1141                	addi	sp,sp,-16
 44a:	e406                	sd	ra,8(sp)
 44c:	e022                	sd	s0,0(sp)
 44e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 450:	00000097          	auipc	ra,0x0
 454:	f66080e7          	jalr	-154(ra) # 3b6 <memmove>
}
 458:	60a2                	ld	ra,8(sp)
 45a:	6402                	ld	s0,0(sp)
 45c:	0141                	addi	sp,sp,16
 45e:	8082                	ret

0000000000000460 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 460:	4885                	li	a7,1
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <exit>:
.global exit
exit:
 li a7, SYS_exit
 468:	4889                	li	a7,2
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <wait>:
.global wait
wait:
 li a7, SYS_wait
 470:	488d                	li	a7,3
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 478:	4891                	li	a7,4
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <read>:
.global read
read:
 li a7, SYS_read
 480:	4895                	li	a7,5
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <write>:
.global write
write:
 li a7, SYS_write
 488:	48c1                	li	a7,16
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <close>:
.global close
close:
 li a7, SYS_close
 490:	48d5                	li	a7,21
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <kill>:
.global kill
kill:
 li a7, SYS_kill
 498:	4899                	li	a7,6
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4a0:	489d                	li	a7,7
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <open>:
.global open
open:
 li a7, SYS_open
 4a8:	48bd                	li	a7,15
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4b0:	48c5                	li	a7,17
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4b8:	48c9                	li	a7,18
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4c0:	48a1                	li	a7,8
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <link>:
.global link
link:
 li a7, SYS_link
 4c8:	48cd                	li	a7,19
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4d0:	48d1                	li	a7,20
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4d8:	48a5                	li	a7,9
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4e0:	48a9                	li	a7,10
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4e8:	48ad                	li	a7,11
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4f0:	48b1                	li	a7,12
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4f8:	48b5                	li	a7,13
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 500:	48b9                	li	a7,14
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <startlog>:
.global startlog
startlog:
 li a7, SYS_startlog
 508:	48d9                	li	a7,22
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <getlog>:
.global getlog
getlog:
 li a7, SYS_getlog
 510:	48dd                	li	a7,23
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <nice>:
.global nice
nice:
 li a7, SYS_nice
 518:	48e1                	li	a7,24
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 520:	1101                	addi	sp,sp,-32
 522:	ec06                	sd	ra,24(sp)
 524:	e822                	sd	s0,16(sp)
 526:	1000                	addi	s0,sp,32
 528:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 52c:	4605                	li	a2,1
 52e:	fef40593          	addi	a1,s0,-17
 532:	00000097          	auipc	ra,0x0
 536:	f56080e7          	jalr	-170(ra) # 488 <write>
}
 53a:	60e2                	ld	ra,24(sp)
 53c:	6442                	ld	s0,16(sp)
 53e:	6105                	addi	sp,sp,32
 540:	8082                	ret

0000000000000542 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 542:	7139                	addi	sp,sp,-64
 544:	fc06                	sd	ra,56(sp)
 546:	f822                	sd	s0,48(sp)
 548:	f426                	sd	s1,40(sp)
 54a:	f04a                	sd	s2,32(sp)
 54c:	ec4e                	sd	s3,24(sp)
 54e:	0080                	addi	s0,sp,64
 550:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 552:	c299                	beqz	a3,558 <printint+0x16>
 554:	0805c863          	bltz	a1,5e4 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 558:	2581                	sext.w	a1,a1
  neg = 0;
 55a:	4881                	li	a7,0
 55c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 560:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 562:	2601                	sext.w	a2,a2
 564:	00000517          	auipc	a0,0x0
 568:	52450513          	addi	a0,a0,1316 # a88 <digits>
 56c:	883a                	mv	a6,a4
 56e:	2705                	addiw	a4,a4,1
 570:	02c5f7bb          	remuw	a5,a1,a2
 574:	1782                	slli	a5,a5,0x20
 576:	9381                	srli	a5,a5,0x20
 578:	97aa                	add	a5,a5,a0
 57a:	0007c783          	lbu	a5,0(a5)
 57e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 582:	0005879b          	sext.w	a5,a1
 586:	02c5d5bb          	divuw	a1,a1,a2
 58a:	0685                	addi	a3,a3,1
 58c:	fec7f0e3          	bgeu	a5,a2,56c <printint+0x2a>
  if(neg)
 590:	00088b63          	beqz	a7,5a6 <printint+0x64>
    buf[i++] = '-';
 594:	fd040793          	addi	a5,s0,-48
 598:	973e                	add	a4,a4,a5
 59a:	02d00793          	li	a5,45
 59e:	fef70823          	sb	a5,-16(a4)
 5a2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5a6:	02e05863          	blez	a4,5d6 <printint+0x94>
 5aa:	fc040793          	addi	a5,s0,-64
 5ae:	00e78933          	add	s2,a5,a4
 5b2:	fff78993          	addi	s3,a5,-1
 5b6:	99ba                	add	s3,s3,a4
 5b8:	377d                	addiw	a4,a4,-1
 5ba:	1702                	slli	a4,a4,0x20
 5bc:	9301                	srli	a4,a4,0x20
 5be:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5c2:	fff94583          	lbu	a1,-1(s2)
 5c6:	8526                	mv	a0,s1
 5c8:	00000097          	auipc	ra,0x0
 5cc:	f58080e7          	jalr	-168(ra) # 520 <putc>
  while(--i >= 0)
 5d0:	197d                	addi	s2,s2,-1
 5d2:	ff3918e3          	bne	s2,s3,5c2 <printint+0x80>
}
 5d6:	70e2                	ld	ra,56(sp)
 5d8:	7442                	ld	s0,48(sp)
 5da:	74a2                	ld	s1,40(sp)
 5dc:	7902                	ld	s2,32(sp)
 5de:	69e2                	ld	s3,24(sp)
 5e0:	6121                	addi	sp,sp,64
 5e2:	8082                	ret
    x = -xx;
 5e4:	40b005bb          	negw	a1,a1
    neg = 1;
 5e8:	4885                	li	a7,1
    x = -xx;
 5ea:	bf8d                	j	55c <printint+0x1a>

00000000000005ec <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ec:	7119                	addi	sp,sp,-128
 5ee:	fc86                	sd	ra,120(sp)
 5f0:	f8a2                	sd	s0,112(sp)
 5f2:	f4a6                	sd	s1,104(sp)
 5f4:	f0ca                	sd	s2,96(sp)
 5f6:	ecce                	sd	s3,88(sp)
 5f8:	e8d2                	sd	s4,80(sp)
 5fa:	e4d6                	sd	s5,72(sp)
 5fc:	e0da                	sd	s6,64(sp)
 5fe:	fc5e                	sd	s7,56(sp)
 600:	f862                	sd	s8,48(sp)
 602:	f466                	sd	s9,40(sp)
 604:	f06a                	sd	s10,32(sp)
 606:	ec6e                	sd	s11,24(sp)
 608:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 60a:	0005c903          	lbu	s2,0(a1)
 60e:	18090f63          	beqz	s2,7ac <vprintf+0x1c0>
 612:	8aaa                	mv	s5,a0
 614:	8b32                	mv	s6,a2
 616:	00158493          	addi	s1,a1,1
  state = 0;
 61a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 61c:	02500a13          	li	s4,37
      if(c == 'd'){
 620:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 624:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 628:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 62c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 630:	00000b97          	auipc	s7,0x0
 634:	458b8b93          	addi	s7,s7,1112 # a88 <digits>
 638:	a839                	j	656 <vprintf+0x6a>
        putc(fd, c);
 63a:	85ca                	mv	a1,s2
 63c:	8556                	mv	a0,s5
 63e:	00000097          	auipc	ra,0x0
 642:	ee2080e7          	jalr	-286(ra) # 520 <putc>
 646:	a019                	j	64c <vprintf+0x60>
    } else if(state == '%'){
 648:	01498f63          	beq	s3,s4,666 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 64c:	0485                	addi	s1,s1,1
 64e:	fff4c903          	lbu	s2,-1(s1)
 652:	14090d63          	beqz	s2,7ac <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 656:	0009079b          	sext.w	a5,s2
    if(state == 0){
 65a:	fe0997e3          	bnez	s3,648 <vprintf+0x5c>
      if(c == '%'){
 65e:	fd479ee3          	bne	a5,s4,63a <vprintf+0x4e>
        state = '%';
 662:	89be                	mv	s3,a5
 664:	b7e5                	j	64c <vprintf+0x60>
      if(c == 'd'){
 666:	05878063          	beq	a5,s8,6a6 <vprintf+0xba>
      } else if(c == 'l') {
 66a:	05978c63          	beq	a5,s9,6c2 <vprintf+0xd6>
      } else if(c == 'x') {
 66e:	07a78863          	beq	a5,s10,6de <vprintf+0xf2>
      } else if(c == 'p') {
 672:	09b78463          	beq	a5,s11,6fa <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 676:	07300713          	li	a4,115
 67a:	0ce78663          	beq	a5,a4,746 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 67e:	06300713          	li	a4,99
 682:	0ee78e63          	beq	a5,a4,77e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 686:	11478863          	beq	a5,s4,796 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 68a:	85d2                	mv	a1,s4
 68c:	8556                	mv	a0,s5
 68e:	00000097          	auipc	ra,0x0
 692:	e92080e7          	jalr	-366(ra) # 520 <putc>
        putc(fd, c);
 696:	85ca                	mv	a1,s2
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	e86080e7          	jalr	-378(ra) # 520 <putc>
      }
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	b765                	j	64c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6a6:	008b0913          	addi	s2,s6,8
 6aa:	4685                	li	a3,1
 6ac:	4629                	li	a2,10
 6ae:	000b2583          	lw	a1,0(s6)
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	e8e080e7          	jalr	-370(ra) # 542 <printint>
 6bc:	8b4a                	mv	s6,s2
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b771                	j	64c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c2:	008b0913          	addi	s2,s6,8
 6c6:	4681                	li	a3,0
 6c8:	4629                	li	a2,10
 6ca:	000b2583          	lw	a1,0(s6)
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	e72080e7          	jalr	-398(ra) # 542 <printint>
 6d8:	8b4a                	mv	s6,s2
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	bf85                	j	64c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6de:	008b0913          	addi	s2,s6,8
 6e2:	4681                	li	a3,0
 6e4:	4641                	li	a2,16
 6e6:	000b2583          	lw	a1,0(s6)
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	e56080e7          	jalr	-426(ra) # 542 <printint>
 6f4:	8b4a                	mv	s6,s2
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bf91                	j	64c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6fa:	008b0793          	addi	a5,s6,8
 6fe:	f8f43423          	sd	a5,-120(s0)
 702:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 706:	03000593          	li	a1,48
 70a:	8556                	mv	a0,s5
 70c:	00000097          	auipc	ra,0x0
 710:	e14080e7          	jalr	-492(ra) # 520 <putc>
  putc(fd, 'x');
 714:	85ea                	mv	a1,s10
 716:	8556                	mv	a0,s5
 718:	00000097          	auipc	ra,0x0
 71c:	e08080e7          	jalr	-504(ra) # 520 <putc>
 720:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 722:	03c9d793          	srli	a5,s3,0x3c
 726:	97de                	add	a5,a5,s7
 728:	0007c583          	lbu	a1,0(a5)
 72c:	8556                	mv	a0,s5
 72e:	00000097          	auipc	ra,0x0
 732:	df2080e7          	jalr	-526(ra) # 520 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 736:	0992                	slli	s3,s3,0x4
 738:	397d                	addiw	s2,s2,-1
 73a:	fe0914e3          	bnez	s2,722 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 73e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 742:	4981                	li	s3,0
 744:	b721                	j	64c <vprintf+0x60>
        s = va_arg(ap, char*);
 746:	008b0993          	addi	s3,s6,8
 74a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 74e:	02090163          	beqz	s2,770 <vprintf+0x184>
        while(*s != 0){
 752:	00094583          	lbu	a1,0(s2)
 756:	c9a1                	beqz	a1,7a6 <vprintf+0x1ba>
          putc(fd, *s);
 758:	8556                	mv	a0,s5
 75a:	00000097          	auipc	ra,0x0
 75e:	dc6080e7          	jalr	-570(ra) # 520 <putc>
          s++;
 762:	0905                	addi	s2,s2,1
        while(*s != 0){
 764:	00094583          	lbu	a1,0(s2)
 768:	f9e5                	bnez	a1,758 <vprintf+0x16c>
        s = va_arg(ap, char*);
 76a:	8b4e                	mv	s6,s3
      state = 0;
 76c:	4981                	li	s3,0
 76e:	bdf9                	j	64c <vprintf+0x60>
          s = "(null)";
 770:	00000917          	auipc	s2,0x0
 774:	31090913          	addi	s2,s2,784 # a80 <malloc+0x1ca>
        while(*s != 0){
 778:	02800593          	li	a1,40
 77c:	bff1                	j	758 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 77e:	008b0913          	addi	s2,s6,8
 782:	000b4583          	lbu	a1,0(s6)
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	d98080e7          	jalr	-616(ra) # 520 <putc>
 790:	8b4a                	mv	s6,s2
      state = 0;
 792:	4981                	li	s3,0
 794:	bd65                	j	64c <vprintf+0x60>
        putc(fd, c);
 796:	85d2                	mv	a1,s4
 798:	8556                	mv	a0,s5
 79a:	00000097          	auipc	ra,0x0
 79e:	d86080e7          	jalr	-634(ra) # 520 <putc>
      state = 0;
 7a2:	4981                	li	s3,0
 7a4:	b565                	j	64c <vprintf+0x60>
        s = va_arg(ap, char*);
 7a6:	8b4e                	mv	s6,s3
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	b54d                	j	64c <vprintf+0x60>
    }
  }
}
 7ac:	70e6                	ld	ra,120(sp)
 7ae:	7446                	ld	s0,112(sp)
 7b0:	74a6                	ld	s1,104(sp)
 7b2:	7906                	ld	s2,96(sp)
 7b4:	69e6                	ld	s3,88(sp)
 7b6:	6a46                	ld	s4,80(sp)
 7b8:	6aa6                	ld	s5,72(sp)
 7ba:	6b06                	ld	s6,64(sp)
 7bc:	7be2                	ld	s7,56(sp)
 7be:	7c42                	ld	s8,48(sp)
 7c0:	7ca2                	ld	s9,40(sp)
 7c2:	7d02                	ld	s10,32(sp)
 7c4:	6de2                	ld	s11,24(sp)
 7c6:	6109                	addi	sp,sp,128
 7c8:	8082                	ret

00000000000007ca <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ca:	715d                	addi	sp,sp,-80
 7cc:	ec06                	sd	ra,24(sp)
 7ce:	e822                	sd	s0,16(sp)
 7d0:	1000                	addi	s0,sp,32
 7d2:	e010                	sd	a2,0(s0)
 7d4:	e414                	sd	a3,8(s0)
 7d6:	e818                	sd	a4,16(s0)
 7d8:	ec1c                	sd	a5,24(s0)
 7da:	03043023          	sd	a6,32(s0)
 7de:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7e2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7e6:	8622                	mv	a2,s0
 7e8:	00000097          	auipc	ra,0x0
 7ec:	e04080e7          	jalr	-508(ra) # 5ec <vprintf>
}
 7f0:	60e2                	ld	ra,24(sp)
 7f2:	6442                	ld	s0,16(sp)
 7f4:	6161                	addi	sp,sp,80
 7f6:	8082                	ret

00000000000007f8 <printf>:

void
printf(const char *fmt, ...)
{
 7f8:	711d                	addi	sp,sp,-96
 7fa:	ec06                	sd	ra,24(sp)
 7fc:	e822                	sd	s0,16(sp)
 7fe:	1000                	addi	s0,sp,32
 800:	e40c                	sd	a1,8(s0)
 802:	e810                	sd	a2,16(s0)
 804:	ec14                	sd	a3,24(s0)
 806:	f018                	sd	a4,32(s0)
 808:	f41c                	sd	a5,40(s0)
 80a:	03043823          	sd	a6,48(s0)
 80e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 812:	00840613          	addi	a2,s0,8
 816:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 81a:	85aa                	mv	a1,a0
 81c:	4505                	li	a0,1
 81e:	00000097          	auipc	ra,0x0
 822:	dce080e7          	jalr	-562(ra) # 5ec <vprintf>
}
 826:	60e2                	ld	ra,24(sp)
 828:	6442                	ld	s0,16(sp)
 82a:	6125                	addi	sp,sp,96
 82c:	8082                	ret

000000000000082e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 82e:	1141                	addi	sp,sp,-16
 830:	e422                	sd	s0,8(sp)
 832:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 834:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 838:	00000797          	auipc	a5,0x0
 83c:	2687b783          	ld	a5,616(a5) # aa0 <freep>
 840:	a805                	j	870 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 842:	4618                	lw	a4,8(a2)
 844:	9db9                	addw	a1,a1,a4
 846:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 84a:	6398                	ld	a4,0(a5)
 84c:	6318                	ld	a4,0(a4)
 84e:	fee53823          	sd	a4,-16(a0)
 852:	a091                	j	896 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 854:	ff852703          	lw	a4,-8(a0)
 858:	9e39                	addw	a2,a2,a4
 85a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 85c:	ff053703          	ld	a4,-16(a0)
 860:	e398                	sd	a4,0(a5)
 862:	a099                	j	8a8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 864:	6398                	ld	a4,0(a5)
 866:	00e7e463          	bltu	a5,a4,86e <free+0x40>
 86a:	00e6ea63          	bltu	a3,a4,87e <free+0x50>
{
 86e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 870:	fed7fae3          	bgeu	a5,a3,864 <free+0x36>
 874:	6398                	ld	a4,0(a5)
 876:	00e6e463          	bltu	a3,a4,87e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87a:	fee7eae3          	bltu	a5,a4,86e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 87e:	ff852583          	lw	a1,-8(a0)
 882:	6390                	ld	a2,0(a5)
 884:	02059713          	slli	a4,a1,0x20
 888:	9301                	srli	a4,a4,0x20
 88a:	0712                	slli	a4,a4,0x4
 88c:	9736                	add	a4,a4,a3
 88e:	fae60ae3          	beq	a2,a4,842 <free+0x14>
    bp->s.ptr = p->s.ptr;
 892:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 896:	4790                	lw	a2,8(a5)
 898:	02061713          	slli	a4,a2,0x20
 89c:	9301                	srli	a4,a4,0x20
 89e:	0712                	slli	a4,a4,0x4
 8a0:	973e                	add	a4,a4,a5
 8a2:	fae689e3          	beq	a3,a4,854 <free+0x26>
  } else
    p->s.ptr = bp;
 8a6:	e394                	sd	a3,0(a5)
  freep = p;
 8a8:	00000717          	auipc	a4,0x0
 8ac:	1ef73c23          	sd	a5,504(a4) # aa0 <freep>
}
 8b0:	6422                	ld	s0,8(sp)
 8b2:	0141                	addi	sp,sp,16
 8b4:	8082                	ret

00000000000008b6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b6:	7139                	addi	sp,sp,-64
 8b8:	fc06                	sd	ra,56(sp)
 8ba:	f822                	sd	s0,48(sp)
 8bc:	f426                	sd	s1,40(sp)
 8be:	f04a                	sd	s2,32(sp)
 8c0:	ec4e                	sd	s3,24(sp)
 8c2:	e852                	sd	s4,16(sp)
 8c4:	e456                	sd	s5,8(sp)
 8c6:	e05a                	sd	s6,0(sp)
 8c8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ca:	02051493          	slli	s1,a0,0x20
 8ce:	9081                	srli	s1,s1,0x20
 8d0:	04bd                	addi	s1,s1,15
 8d2:	8091                	srli	s1,s1,0x4
 8d4:	0014899b          	addiw	s3,s1,1
 8d8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8da:	00000517          	auipc	a0,0x0
 8de:	1c653503          	ld	a0,454(a0) # aa0 <freep>
 8e2:	c515                	beqz	a0,90e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e6:	4798                	lw	a4,8(a5)
 8e8:	02977f63          	bgeu	a4,s1,926 <malloc+0x70>
 8ec:	8a4e                	mv	s4,s3
 8ee:	0009871b          	sext.w	a4,s3
 8f2:	6685                	lui	a3,0x1
 8f4:	00d77363          	bgeu	a4,a3,8fa <malloc+0x44>
 8f8:	6a05                	lui	s4,0x1
 8fa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8fe:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 902:	00000917          	auipc	s2,0x0
 906:	19e90913          	addi	s2,s2,414 # aa0 <freep>
  if(p == (char*)-1)
 90a:	5afd                	li	s5,-1
 90c:	a88d                	j	97e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 90e:	00000797          	auipc	a5,0x0
 912:	7da78793          	addi	a5,a5,2010 # 10e8 <base>
 916:	00000717          	auipc	a4,0x0
 91a:	18f73523          	sd	a5,394(a4) # aa0 <freep>
 91e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 920:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 924:	b7e1                	j	8ec <malloc+0x36>
      if(p->s.size == nunits)
 926:	02e48b63          	beq	s1,a4,95c <malloc+0xa6>
        p->s.size -= nunits;
 92a:	4137073b          	subw	a4,a4,s3
 92e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 930:	1702                	slli	a4,a4,0x20
 932:	9301                	srli	a4,a4,0x20
 934:	0712                	slli	a4,a4,0x4
 936:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 938:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 93c:	00000717          	auipc	a4,0x0
 940:	16a73223          	sd	a0,356(a4) # aa0 <freep>
      return (void*)(p + 1);
 944:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 948:	70e2                	ld	ra,56(sp)
 94a:	7442                	ld	s0,48(sp)
 94c:	74a2                	ld	s1,40(sp)
 94e:	7902                	ld	s2,32(sp)
 950:	69e2                	ld	s3,24(sp)
 952:	6a42                	ld	s4,16(sp)
 954:	6aa2                	ld	s5,8(sp)
 956:	6b02                	ld	s6,0(sp)
 958:	6121                	addi	sp,sp,64
 95a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 95c:	6398                	ld	a4,0(a5)
 95e:	e118                	sd	a4,0(a0)
 960:	bff1                	j	93c <malloc+0x86>
  hp->s.size = nu;
 962:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 966:	0541                	addi	a0,a0,16
 968:	00000097          	auipc	ra,0x0
 96c:	ec6080e7          	jalr	-314(ra) # 82e <free>
  return freep;
 970:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 974:	d971                	beqz	a0,948 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 976:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 978:	4798                	lw	a4,8(a5)
 97a:	fa9776e3          	bgeu	a4,s1,926 <malloc+0x70>
    if(p == freep)
 97e:	00093703          	ld	a4,0(s2)
 982:	853e                	mv	a0,a5
 984:	fef719e3          	bne	a4,a5,976 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 988:	8552                	mv	a0,s4
 98a:	00000097          	auipc	ra,0x0
 98e:	b66080e7          	jalr	-1178(ra) # 4f0 <sbrk>
  if(p == (char*)-1)
 992:	fd5518e3          	bne	a0,s5,962 <malloc+0xac>
        return 0;
 996:	4501                	li	a0,0
 998:	bf45                	j	948 <malloc+0x92>
