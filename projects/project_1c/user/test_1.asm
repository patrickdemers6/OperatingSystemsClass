
user/_test_1:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <run>:

#pragma GCC push_options
#pragma GCC optimize("O0")

uint64 run()
{
   0:	1101                	addi	sp,sp,-32
   2:	ec22                	sd	s0,24(sp)
   4:	1000                	addi	s0,sp,32
    uint64 acc = 0;
   6:	fe043423          	sd	zero,-24(s0)
    for (uint64 i = 0; i < COUNT; i++)
   a:	fe043023          	sd	zero,-32(s0)
   e:	a829                	j	28 <run+0x28>
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
  30:	9ff78793          	addi	a5,a5,-1537 # 3b9ac9ff <__global_pointer$+0x3b9ab7b6>
  34:	fce7fee3          	bgeu	a5,a4,10 <run+0x10>
    }
    return acc;
  38:	fe843783          	ld	a5,-24(s0)
}
  3c:	853e                	mv	a0,a5
  3e:	6462                	ld	s0,24(sp)
  40:	6105                	addi	sp,sp,32
  42:	8082                	ret

0000000000000044 <main>:

#pragma GCC pop_options

int main(int argc, char *argv[])
{
  44:	711d                	addi	sp,sp,-96
  46:	ec86                	sd	ra,88(sp)
  48:	e8a2                	sd	s0,80(sp)
  4a:	e4a6                	sd	s1,72(sp)
  4c:	e0ca                	sd	s2,64(sp)
  4e:	fc4e                	sd	s3,56(sp)
  50:	f852                	sd	s4,48(sp)
  52:	f456                	sd	s5,40(sp)
  54:	f05a                	sd	s6,32(sp)
  56:	ec5e                	sd	s7,24(sp)
  58:	e862                	sd	s8,16(sp)
  5a:	e466                	sd	s9,8(sp)
  5c:	e06a                	sd	s10,0(sp)
  5e:	1080                	addi	s0,sp,96
    int a, b;
    startlog();
  60:	00000097          	auipc	ra,0x0
  64:	472080e7          	jalr	1138(ra) # 4d2 <startlog>

    a = fork();
  68:	00000097          	auipc	ra,0x0
  6c:	3c2080e7          	jalr	962(ra) # 42a <fork>
    if (a == 0)
  70:	ed19                	bnez	a0,8e <main+0x4a>
    {
        // child
        nice(-19);
  72:	5535                	li	a0,-19
  74:	00000097          	auipc	ra,0x0
  78:	46e080e7          	jalr	1134(ra) # 4e2 <nice>
        run();
  7c:	00000097          	auipc	ra,0x0
  80:	f84080e7          	jalr	-124(ra) # 0 <run>
        exit(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	3ac080e7          	jalr	940(ra) # 432 <exit>
  8e:	84aa                	mv	s1,a0
    }
    else
    {
        b = fork();
  90:	00000097          	auipc	ra,0x0
  94:	39a080e7          	jalr	922(ra) # 42a <fork>
  98:	892a                	mv	s2,a0
        // parent
        if (b == 0)
  9a:	ed19                	bnez	a0,b8 <main+0x74>
        {
            // child
            nice(-19);
  9c:	5535                	li	a0,-19
  9e:	00000097          	auipc	ra,0x0
  a2:	444080e7          	jalr	1092(ra) # 4e2 <nice>
            run();
  a6:	00000097          	auipc	ra,0x0
  aa:	f5a080e7          	jalr	-166(ra) # 0 <run>
            exit(0);
  ae:	4501                	li	a0,0
  b0:	00000097          	auipc	ra,0x0
  b4:	382080e7          	jalr	898(ra) # 432 <exit>
        }
    }
    printf("parent pid: %d\n", getpid());
  b8:	00000097          	auipc	ra,0x0
  bc:	3fa080e7          	jalr	1018(ra) # 4b2 <getpid>
  c0:	85aa                	mv	a1,a0
  c2:	00001517          	auipc	a0,0x1
  c6:	8be50513          	addi	a0,a0,-1858 # 980 <malloc+0x100>
  ca:	00000097          	auipc	ra,0x0
  ce:	6f8080e7          	jalr	1784(ra) # 7c2 <printf>
    printf("first child pid: %d\n", a);
  d2:	85a6                	mv	a1,s1
  d4:	00001517          	auipc	a0,0x1
  d8:	8bc50513          	addi	a0,a0,-1860 # 990 <malloc+0x110>
  dc:	00000097          	auipc	ra,0x0
  e0:	6e6080e7          	jalr	1766(ra) # 7c2 <printf>
    printf("second child pid: %d\n", b);
  e4:	85ca                	mv	a1,s2
  e6:	00001517          	auipc	a0,0x1
  ea:	8c250513          	addi	a0,a0,-1854 # 9a8 <malloc+0x128>
  ee:	00000097          	auipc	ra,0x0
  f2:	6d4080e7          	jalr	1748(ra) # 7c2 <printf>

    wait(0);
  f6:	4501                	li	a0,0
  f8:	00000097          	auipc	ra,0x0
  fc:	342080e7          	jalr	834(ra) # 43a <wait>
    wait(0);
 100:	4501                	li	a0,0
 102:	00000097          	auipc	ra,0x0
 106:	338080e7          	jalr	824(ra) # 43a <wait>
    printf("long running completed\n\n");
 10a:	00001517          	auipc	a0,0x1
 10e:	8b650513          	addi	a0,a0,-1866 # 9c0 <malloc+0x140>
 112:	00000097          	auipc	ra,0x0
 116:	6b0080e7          	jalr	1712(ra) # 7c2 <printf>

    uint64 count = getlog(schedlog);
 11a:	00001517          	auipc	a0,0x1
 11e:	93e50513          	addi	a0,a0,-1730 # a58 <schedlog>
 122:	00000097          	auipc	ra,0x0
 126:	3b8080e7          	jalr	952(ra) # 4da <getlog>
 12a:	89aa                	mv	s3,a0

    for (int i = 0; i < count; i++)
 12c:	c935                	beqz	a0,1a0 <main+0x15c>
 12e:	00001497          	auipc	s1,0x1
 132:	92a48493          	addi	s1,s1,-1750 # a58 <schedlog>
 136:	4901                	li	s2,0
    {
        if (schedlog[i].priority_boost)
            printf("** priority boost at time %d **\n", schedlog[i].time);
        else
            printf("pid %d started at %d in queue %s\n", schedlog[i].pid, schedlog[i].time, schedlog[i].queue == 2 ? "High" : schedlog[i].queue == 1 ? "Medium"
 138:	4b09                	li	s6,2
 13a:	00001a97          	auipc	s5,0x1
 13e:	82ea8a93          	addi	s5,s5,-2002 # 968 <malloc+0xe8>
 142:	00001a17          	auipc	s4,0x1
 146:	8c6a0a13          	addi	s4,s4,-1850 # a08 <malloc+0x188>
                                                                                                                                                     : "Low");
 14a:	4c05                	li	s8,1
 14c:	00001b97          	auipc	s7,0x1
 150:	824b8b93          	addi	s7,s7,-2012 # 970 <malloc+0xf0>
 154:	00001d17          	auipc	s10,0x1
 158:	824d0d13          	addi	s10,s10,-2012 # 978 <malloc+0xf8>
            printf("** priority boost at time %d **\n", schedlog[i].time);
 15c:	00001c97          	auipc	s9,0x1
 160:	884c8c93          	addi	s9,s9,-1916 # 9e0 <malloc+0x160>
 164:	a00d                	j	186 <main+0x142>
 166:	40cc                	lw	a1,4(s1)
 168:	8566                	mv	a0,s9
 16a:	00000097          	auipc	ra,0x0
 16e:	658080e7          	jalr	1624(ra) # 7c2 <printf>
 172:	a031                	j	17e <main+0x13a>
            printf("pid %d started at %d in queue %s\n", schedlog[i].pid, schedlog[i].time, schedlog[i].queue == 2 ? "High" : schedlog[i].queue == 1 ? "Medium"
 174:	8552                	mv	a0,s4
 176:	00000097          	auipc	ra,0x0
 17a:	64c080e7          	jalr	1612(ra) # 7c2 <printf>
    for (int i = 0; i < count; i++)
 17e:	0905                	addi	s2,s2,1
 180:	04c1                	addi	s1,s1,16
 182:	01390f63          	beq	s2,s3,1a0 <main+0x15c>
        if (schedlog[i].priority_boost)
 186:	44dc                	lw	a5,12(s1)
 188:	fff9                	bnez	a5,166 <main+0x122>
            printf("pid %d started at %d in queue %s\n", schedlog[i].pid, schedlog[i].time, schedlog[i].queue == 2 ? "High" : schedlog[i].queue == 1 ? "Medium"
 18a:	408c                	lw	a1,0(s1)
 18c:	40d0                	lw	a2,4(s1)
 18e:	449c                	lw	a5,8(s1)
 190:	86d6                	mv	a3,s5
 192:	ff6781e3          	beq	a5,s6,174 <main+0x130>
                                                                                                                                                     : "Low");
 196:	86de                	mv	a3,s7
 198:	fd878ee3          	beq	a5,s8,174 <main+0x130>
 19c:	86ea                	mv	a3,s10
 19e:	bfd9                	j	174 <main+0x130>
    }

    exit(0);
 1a0:	4501                	li	a0,0
 1a2:	00000097          	auipc	ra,0x0
 1a6:	290080e7          	jalr	656(ra) # 432 <exit>

00000000000001aa <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e406                	sd	ra,8(sp)
 1ae:	e022                	sd	s0,0(sp)
 1b0:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1b2:	00000097          	auipc	ra,0x0
 1b6:	e92080e7          	jalr	-366(ra) # 44 <main>
  exit(0);
 1ba:	4501                	li	a0,0
 1bc:	00000097          	auipc	ra,0x0
 1c0:	276080e7          	jalr	630(ra) # 432 <exit>

00000000000001c4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1c4:	1141                	addi	sp,sp,-16
 1c6:	e422                	sd	s0,8(sp)
 1c8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1ca:	87aa                	mv	a5,a0
 1cc:	0585                	addi	a1,a1,1
 1ce:	0785                	addi	a5,a5,1
 1d0:	fff5c703          	lbu	a4,-1(a1)
 1d4:	fee78fa3          	sb	a4,-1(a5)
 1d8:	fb75                	bnez	a4,1cc <strcpy+0x8>
    ;
  return os;
}
 1da:	6422                	ld	s0,8(sp)
 1dc:	0141                	addi	sp,sp,16
 1de:	8082                	ret

00000000000001e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e422                	sd	s0,8(sp)
 1e4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1e6:	00054783          	lbu	a5,0(a0)
 1ea:	cb91                	beqz	a5,1fe <strcmp+0x1e>
 1ec:	0005c703          	lbu	a4,0(a1)
 1f0:	00f71763          	bne	a4,a5,1fe <strcmp+0x1e>
    p++, q++;
 1f4:	0505                	addi	a0,a0,1
 1f6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1f8:	00054783          	lbu	a5,0(a0)
 1fc:	fbe5                	bnez	a5,1ec <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1fe:	0005c503          	lbu	a0,0(a1)
}
 202:	40a7853b          	subw	a0,a5,a0
 206:	6422                	ld	s0,8(sp)
 208:	0141                	addi	sp,sp,16
 20a:	8082                	ret

000000000000020c <strlen>:

uint
strlen(const char *s)
{
 20c:	1141                	addi	sp,sp,-16
 20e:	e422                	sd	s0,8(sp)
 210:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 212:	00054783          	lbu	a5,0(a0)
 216:	cf91                	beqz	a5,232 <strlen+0x26>
 218:	0505                	addi	a0,a0,1
 21a:	87aa                	mv	a5,a0
 21c:	4685                	li	a3,1
 21e:	9e89                	subw	a3,a3,a0
 220:	00f6853b          	addw	a0,a3,a5
 224:	0785                	addi	a5,a5,1
 226:	fff7c703          	lbu	a4,-1(a5)
 22a:	fb7d                	bnez	a4,220 <strlen+0x14>
    ;
  return n;
}
 22c:	6422                	ld	s0,8(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret
  for(n = 0; s[n]; n++)
 232:	4501                	li	a0,0
 234:	bfe5                	j	22c <strlen+0x20>

0000000000000236 <memset>:

void*
memset(void *dst, int c, uint n)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 23c:	ca19                	beqz	a2,252 <memset+0x1c>
 23e:	87aa                	mv	a5,a0
 240:	1602                	slli	a2,a2,0x20
 242:	9201                	srli	a2,a2,0x20
 244:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 248:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 24c:	0785                	addi	a5,a5,1
 24e:	fee79de3          	bne	a5,a4,248 <memset+0x12>
  }
  return dst;
}
 252:	6422                	ld	s0,8(sp)
 254:	0141                	addi	sp,sp,16
 256:	8082                	ret

0000000000000258 <strchr>:

char*
strchr(const char *s, char c)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e422                	sd	s0,8(sp)
 25c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 25e:	00054783          	lbu	a5,0(a0)
 262:	cb99                	beqz	a5,278 <strchr+0x20>
    if(*s == c)
 264:	00f58763          	beq	a1,a5,272 <strchr+0x1a>
  for(; *s; s++)
 268:	0505                	addi	a0,a0,1
 26a:	00054783          	lbu	a5,0(a0)
 26e:	fbfd                	bnez	a5,264 <strchr+0xc>
      return (char*)s;
  return 0;
 270:	4501                	li	a0,0
}
 272:	6422                	ld	s0,8(sp)
 274:	0141                	addi	sp,sp,16
 276:	8082                	ret
  return 0;
 278:	4501                	li	a0,0
 27a:	bfe5                	j	272 <strchr+0x1a>

000000000000027c <gets>:

char*
gets(char *buf, int max)
{
 27c:	711d                	addi	sp,sp,-96
 27e:	ec86                	sd	ra,88(sp)
 280:	e8a2                	sd	s0,80(sp)
 282:	e4a6                	sd	s1,72(sp)
 284:	e0ca                	sd	s2,64(sp)
 286:	fc4e                	sd	s3,56(sp)
 288:	f852                	sd	s4,48(sp)
 28a:	f456                	sd	s5,40(sp)
 28c:	f05a                	sd	s6,32(sp)
 28e:	ec5e                	sd	s7,24(sp)
 290:	1080                	addi	s0,sp,96
 292:	8baa                	mv	s7,a0
 294:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 296:	892a                	mv	s2,a0
 298:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 29a:	4aa9                	li	s5,10
 29c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 29e:	89a6                	mv	s3,s1
 2a0:	2485                	addiw	s1,s1,1
 2a2:	0344d863          	bge	s1,s4,2d2 <gets+0x56>
    cc = read(0, &c, 1);
 2a6:	4605                	li	a2,1
 2a8:	faf40593          	addi	a1,s0,-81
 2ac:	4501                	li	a0,0
 2ae:	00000097          	auipc	ra,0x0
 2b2:	19c080e7          	jalr	412(ra) # 44a <read>
    if(cc < 1)
 2b6:	00a05e63          	blez	a0,2d2 <gets+0x56>
    buf[i++] = c;
 2ba:	faf44783          	lbu	a5,-81(s0)
 2be:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2c2:	01578763          	beq	a5,s5,2d0 <gets+0x54>
 2c6:	0905                	addi	s2,s2,1
 2c8:	fd679be3          	bne	a5,s6,29e <gets+0x22>
  for(i=0; i+1 < max; ){
 2cc:	89a6                	mv	s3,s1
 2ce:	a011                	j	2d2 <gets+0x56>
 2d0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2d2:	99de                	add	s3,s3,s7
 2d4:	00098023          	sb	zero,0(s3)
  return buf;
}
 2d8:	855e                	mv	a0,s7
 2da:	60e6                	ld	ra,88(sp)
 2dc:	6446                	ld	s0,80(sp)
 2de:	64a6                	ld	s1,72(sp)
 2e0:	6906                	ld	s2,64(sp)
 2e2:	79e2                	ld	s3,56(sp)
 2e4:	7a42                	ld	s4,48(sp)
 2e6:	7aa2                	ld	s5,40(sp)
 2e8:	7b02                	ld	s6,32(sp)
 2ea:	6be2                	ld	s7,24(sp)
 2ec:	6125                	addi	sp,sp,96
 2ee:	8082                	ret

00000000000002f0 <stat>:

int
stat(const char *n, struct stat *st)
{
 2f0:	1101                	addi	sp,sp,-32
 2f2:	ec06                	sd	ra,24(sp)
 2f4:	e822                	sd	s0,16(sp)
 2f6:	e426                	sd	s1,8(sp)
 2f8:	e04a                	sd	s2,0(sp)
 2fa:	1000                	addi	s0,sp,32
 2fc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2fe:	4581                	li	a1,0
 300:	00000097          	auipc	ra,0x0
 304:	172080e7          	jalr	370(ra) # 472 <open>
  if(fd < 0)
 308:	02054563          	bltz	a0,332 <stat+0x42>
 30c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 30e:	85ca                	mv	a1,s2
 310:	00000097          	auipc	ra,0x0
 314:	17a080e7          	jalr	378(ra) # 48a <fstat>
 318:	892a                	mv	s2,a0
  close(fd);
 31a:	8526                	mv	a0,s1
 31c:	00000097          	auipc	ra,0x0
 320:	13e080e7          	jalr	318(ra) # 45a <close>
  return r;
}
 324:	854a                	mv	a0,s2
 326:	60e2                	ld	ra,24(sp)
 328:	6442                	ld	s0,16(sp)
 32a:	64a2                	ld	s1,8(sp)
 32c:	6902                	ld	s2,0(sp)
 32e:	6105                	addi	sp,sp,32
 330:	8082                	ret
    return -1;
 332:	597d                	li	s2,-1
 334:	bfc5                	j	324 <stat+0x34>

0000000000000336 <atoi>:

int
atoi(const char *s)
{
 336:	1141                	addi	sp,sp,-16
 338:	e422                	sd	s0,8(sp)
 33a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 33c:	00054603          	lbu	a2,0(a0)
 340:	fd06079b          	addiw	a5,a2,-48
 344:	0ff7f793          	andi	a5,a5,255
 348:	4725                	li	a4,9
 34a:	02f76963          	bltu	a4,a5,37c <atoi+0x46>
 34e:	86aa                	mv	a3,a0
  n = 0;
 350:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 352:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 354:	0685                	addi	a3,a3,1
 356:	0025179b          	slliw	a5,a0,0x2
 35a:	9fa9                	addw	a5,a5,a0
 35c:	0017979b          	slliw	a5,a5,0x1
 360:	9fb1                	addw	a5,a5,a2
 362:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 366:	0006c603          	lbu	a2,0(a3)
 36a:	fd06071b          	addiw	a4,a2,-48
 36e:	0ff77713          	andi	a4,a4,255
 372:	fee5f1e3          	bgeu	a1,a4,354 <atoi+0x1e>
  return n;
}
 376:	6422                	ld	s0,8(sp)
 378:	0141                	addi	sp,sp,16
 37a:	8082                	ret
  n = 0;
 37c:	4501                	li	a0,0
 37e:	bfe5                	j	376 <atoi+0x40>

0000000000000380 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 380:	1141                	addi	sp,sp,-16
 382:	e422                	sd	s0,8(sp)
 384:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 386:	02b57463          	bgeu	a0,a1,3ae <memmove+0x2e>
    while(n-- > 0)
 38a:	00c05f63          	blez	a2,3a8 <memmove+0x28>
 38e:	1602                	slli	a2,a2,0x20
 390:	9201                	srli	a2,a2,0x20
 392:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 396:	872a                	mv	a4,a0
      *dst++ = *src++;
 398:	0585                	addi	a1,a1,1
 39a:	0705                	addi	a4,a4,1
 39c:	fff5c683          	lbu	a3,-1(a1)
 3a0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3a4:	fee79ae3          	bne	a5,a4,398 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3a8:	6422                	ld	s0,8(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret
    dst += n;
 3ae:	00c50733          	add	a4,a0,a2
    src += n;
 3b2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3b4:	fec05ae3          	blez	a2,3a8 <memmove+0x28>
 3b8:	fff6079b          	addiw	a5,a2,-1
 3bc:	1782                	slli	a5,a5,0x20
 3be:	9381                	srli	a5,a5,0x20
 3c0:	fff7c793          	not	a5,a5
 3c4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3c6:	15fd                	addi	a1,a1,-1
 3c8:	177d                	addi	a4,a4,-1
 3ca:	0005c683          	lbu	a3,0(a1)
 3ce:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3d2:	fee79ae3          	bne	a5,a4,3c6 <memmove+0x46>
 3d6:	bfc9                	j	3a8 <memmove+0x28>

00000000000003d8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3d8:	1141                	addi	sp,sp,-16
 3da:	e422                	sd	s0,8(sp)
 3dc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3de:	ca05                	beqz	a2,40e <memcmp+0x36>
 3e0:	fff6069b          	addiw	a3,a2,-1
 3e4:	1682                	slli	a3,a3,0x20
 3e6:	9281                	srli	a3,a3,0x20
 3e8:	0685                	addi	a3,a3,1
 3ea:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ec:	00054783          	lbu	a5,0(a0)
 3f0:	0005c703          	lbu	a4,0(a1)
 3f4:	00e79863          	bne	a5,a4,404 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3f8:	0505                	addi	a0,a0,1
    p2++;
 3fa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3fc:	fed518e3          	bne	a0,a3,3ec <memcmp+0x14>
  }
  return 0;
 400:	4501                	li	a0,0
 402:	a019                	j	408 <memcmp+0x30>
      return *p1 - *p2;
 404:	40e7853b          	subw	a0,a5,a4
}
 408:	6422                	ld	s0,8(sp)
 40a:	0141                	addi	sp,sp,16
 40c:	8082                	ret
  return 0;
 40e:	4501                	li	a0,0
 410:	bfe5                	j	408 <memcmp+0x30>

0000000000000412 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 412:	1141                	addi	sp,sp,-16
 414:	e406                	sd	ra,8(sp)
 416:	e022                	sd	s0,0(sp)
 418:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 41a:	00000097          	auipc	ra,0x0
 41e:	f66080e7          	jalr	-154(ra) # 380 <memmove>
}
 422:	60a2                	ld	ra,8(sp)
 424:	6402                	ld	s0,0(sp)
 426:	0141                	addi	sp,sp,16
 428:	8082                	ret

000000000000042a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 42a:	4885                	li	a7,1
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <exit>:
.global exit
exit:
 li a7, SYS_exit
 432:	4889                	li	a7,2
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <wait>:
.global wait
wait:
 li a7, SYS_wait
 43a:	488d                	li	a7,3
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 442:	4891                	li	a7,4
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <read>:
.global read
read:
 li a7, SYS_read
 44a:	4895                	li	a7,5
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <write>:
.global write
write:
 li a7, SYS_write
 452:	48c1                	li	a7,16
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <close>:
.global close
close:
 li a7, SYS_close
 45a:	48d5                	li	a7,21
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <kill>:
.global kill
kill:
 li a7, SYS_kill
 462:	4899                	li	a7,6
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <exec>:
.global exec
exec:
 li a7, SYS_exec
 46a:	489d                	li	a7,7
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <open>:
.global open
open:
 li a7, SYS_open
 472:	48bd                	li	a7,15
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 47a:	48c5                	li	a7,17
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 482:	48c9                	li	a7,18
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 48a:	48a1                	li	a7,8
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <link>:
.global link
link:
 li a7, SYS_link
 492:	48cd                	li	a7,19
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 49a:	48d1                	li	a7,20
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4a2:	48a5                	li	a7,9
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <dup>:
.global dup
dup:
 li a7, SYS_dup
 4aa:	48a9                	li	a7,10
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4b2:	48ad                	li	a7,11
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ba:	48b1                	li	a7,12
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4c2:	48b5                	li	a7,13
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4ca:	48b9                	li	a7,14
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <startlog>:
.global startlog
startlog:
 li a7, SYS_startlog
 4d2:	48d9                	li	a7,22
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <getlog>:
.global getlog
getlog:
 li a7, SYS_getlog
 4da:	48dd                	li	a7,23
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <nice>:
.global nice
nice:
 li a7, SYS_nice
 4e2:	48e1                	li	a7,24
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ea:	1101                	addi	sp,sp,-32
 4ec:	ec06                	sd	ra,24(sp)
 4ee:	e822                	sd	s0,16(sp)
 4f0:	1000                	addi	s0,sp,32
 4f2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4f6:	4605                	li	a2,1
 4f8:	fef40593          	addi	a1,s0,-17
 4fc:	00000097          	auipc	ra,0x0
 500:	f56080e7          	jalr	-170(ra) # 452 <write>
}
 504:	60e2                	ld	ra,24(sp)
 506:	6442                	ld	s0,16(sp)
 508:	6105                	addi	sp,sp,32
 50a:	8082                	ret

000000000000050c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 50c:	7139                	addi	sp,sp,-64
 50e:	fc06                	sd	ra,56(sp)
 510:	f822                	sd	s0,48(sp)
 512:	f426                	sd	s1,40(sp)
 514:	f04a                	sd	s2,32(sp)
 516:	ec4e                	sd	s3,24(sp)
 518:	0080                	addi	s0,sp,64
 51a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 51c:	c299                	beqz	a3,522 <printint+0x16>
 51e:	0805c863          	bltz	a1,5ae <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 522:	2581                	sext.w	a1,a1
  neg = 0;
 524:	4881                	li	a7,0
 526:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 52a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 52c:	2601                	sext.w	a2,a2
 52e:	00000517          	auipc	a0,0x0
 532:	50a50513          	addi	a0,a0,1290 # a38 <digits>
 536:	883a                	mv	a6,a4
 538:	2705                	addiw	a4,a4,1
 53a:	02c5f7bb          	remuw	a5,a1,a2
 53e:	1782                	slli	a5,a5,0x20
 540:	9381                	srli	a5,a5,0x20
 542:	97aa                	add	a5,a5,a0
 544:	0007c783          	lbu	a5,0(a5)
 548:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 54c:	0005879b          	sext.w	a5,a1
 550:	02c5d5bb          	divuw	a1,a1,a2
 554:	0685                	addi	a3,a3,1
 556:	fec7f0e3          	bgeu	a5,a2,536 <printint+0x2a>
  if(neg)
 55a:	00088b63          	beqz	a7,570 <printint+0x64>
    buf[i++] = '-';
 55e:	fd040793          	addi	a5,s0,-48
 562:	973e                	add	a4,a4,a5
 564:	02d00793          	li	a5,45
 568:	fef70823          	sb	a5,-16(a4)
 56c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 570:	02e05863          	blez	a4,5a0 <printint+0x94>
 574:	fc040793          	addi	a5,s0,-64
 578:	00e78933          	add	s2,a5,a4
 57c:	fff78993          	addi	s3,a5,-1
 580:	99ba                	add	s3,s3,a4
 582:	377d                	addiw	a4,a4,-1
 584:	1702                	slli	a4,a4,0x20
 586:	9301                	srli	a4,a4,0x20
 588:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 58c:	fff94583          	lbu	a1,-1(s2)
 590:	8526                	mv	a0,s1
 592:	00000097          	auipc	ra,0x0
 596:	f58080e7          	jalr	-168(ra) # 4ea <putc>
  while(--i >= 0)
 59a:	197d                	addi	s2,s2,-1
 59c:	ff3918e3          	bne	s2,s3,58c <printint+0x80>
}
 5a0:	70e2                	ld	ra,56(sp)
 5a2:	7442                	ld	s0,48(sp)
 5a4:	74a2                	ld	s1,40(sp)
 5a6:	7902                	ld	s2,32(sp)
 5a8:	69e2                	ld	s3,24(sp)
 5aa:	6121                	addi	sp,sp,64
 5ac:	8082                	ret
    x = -xx;
 5ae:	40b005bb          	negw	a1,a1
    neg = 1;
 5b2:	4885                	li	a7,1
    x = -xx;
 5b4:	bf8d                	j	526 <printint+0x1a>

00000000000005b6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5b6:	7119                	addi	sp,sp,-128
 5b8:	fc86                	sd	ra,120(sp)
 5ba:	f8a2                	sd	s0,112(sp)
 5bc:	f4a6                	sd	s1,104(sp)
 5be:	f0ca                	sd	s2,96(sp)
 5c0:	ecce                	sd	s3,88(sp)
 5c2:	e8d2                	sd	s4,80(sp)
 5c4:	e4d6                	sd	s5,72(sp)
 5c6:	e0da                	sd	s6,64(sp)
 5c8:	fc5e                	sd	s7,56(sp)
 5ca:	f862                	sd	s8,48(sp)
 5cc:	f466                	sd	s9,40(sp)
 5ce:	f06a                	sd	s10,32(sp)
 5d0:	ec6e                	sd	s11,24(sp)
 5d2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5d4:	0005c903          	lbu	s2,0(a1)
 5d8:	18090f63          	beqz	s2,776 <vprintf+0x1c0>
 5dc:	8aaa                	mv	s5,a0
 5de:	8b32                	mv	s6,a2
 5e0:	00158493          	addi	s1,a1,1
  state = 0;
 5e4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5e6:	02500a13          	li	s4,37
      if(c == 'd'){
 5ea:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5ee:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5f2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5f6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5fa:	00000b97          	auipc	s7,0x0
 5fe:	43eb8b93          	addi	s7,s7,1086 # a38 <digits>
 602:	a839                	j	620 <vprintf+0x6a>
        putc(fd, c);
 604:	85ca                	mv	a1,s2
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	ee2080e7          	jalr	-286(ra) # 4ea <putc>
 610:	a019                	j	616 <vprintf+0x60>
    } else if(state == '%'){
 612:	01498f63          	beq	s3,s4,630 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 616:	0485                	addi	s1,s1,1
 618:	fff4c903          	lbu	s2,-1(s1)
 61c:	14090d63          	beqz	s2,776 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 620:	0009079b          	sext.w	a5,s2
    if(state == 0){
 624:	fe0997e3          	bnez	s3,612 <vprintf+0x5c>
      if(c == '%'){
 628:	fd479ee3          	bne	a5,s4,604 <vprintf+0x4e>
        state = '%';
 62c:	89be                	mv	s3,a5
 62e:	b7e5                	j	616 <vprintf+0x60>
      if(c == 'd'){
 630:	05878063          	beq	a5,s8,670 <vprintf+0xba>
      } else if(c == 'l') {
 634:	05978c63          	beq	a5,s9,68c <vprintf+0xd6>
      } else if(c == 'x') {
 638:	07a78863          	beq	a5,s10,6a8 <vprintf+0xf2>
      } else if(c == 'p') {
 63c:	09b78463          	beq	a5,s11,6c4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 640:	07300713          	li	a4,115
 644:	0ce78663          	beq	a5,a4,710 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 648:	06300713          	li	a4,99
 64c:	0ee78e63          	beq	a5,a4,748 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 650:	11478863          	beq	a5,s4,760 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 654:	85d2                	mv	a1,s4
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	e92080e7          	jalr	-366(ra) # 4ea <putc>
        putc(fd, c);
 660:	85ca                	mv	a1,s2
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	e86080e7          	jalr	-378(ra) # 4ea <putc>
      }
      state = 0;
 66c:	4981                	li	s3,0
 66e:	b765                	j	616 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 670:	008b0913          	addi	s2,s6,8
 674:	4685                	li	a3,1
 676:	4629                	li	a2,10
 678:	000b2583          	lw	a1,0(s6)
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	e8e080e7          	jalr	-370(ra) # 50c <printint>
 686:	8b4a                	mv	s6,s2
      state = 0;
 688:	4981                	li	s3,0
 68a:	b771                	j	616 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 68c:	008b0913          	addi	s2,s6,8
 690:	4681                	li	a3,0
 692:	4629                	li	a2,10
 694:	000b2583          	lw	a1,0(s6)
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	e72080e7          	jalr	-398(ra) # 50c <printint>
 6a2:	8b4a                	mv	s6,s2
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	bf85                	j	616 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6a8:	008b0913          	addi	s2,s6,8
 6ac:	4681                	li	a3,0
 6ae:	4641                	li	a2,16
 6b0:	000b2583          	lw	a1,0(s6)
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	e56080e7          	jalr	-426(ra) # 50c <printint>
 6be:	8b4a                	mv	s6,s2
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	bf91                	j	616 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6c4:	008b0793          	addi	a5,s6,8
 6c8:	f8f43423          	sd	a5,-120(s0)
 6cc:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6d0:	03000593          	li	a1,48
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	e14080e7          	jalr	-492(ra) # 4ea <putc>
  putc(fd, 'x');
 6de:	85ea                	mv	a1,s10
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	e08080e7          	jalr	-504(ra) # 4ea <putc>
 6ea:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ec:	03c9d793          	srli	a5,s3,0x3c
 6f0:	97de                	add	a5,a5,s7
 6f2:	0007c583          	lbu	a1,0(a5)
 6f6:	8556                	mv	a0,s5
 6f8:	00000097          	auipc	ra,0x0
 6fc:	df2080e7          	jalr	-526(ra) # 4ea <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 700:	0992                	slli	s3,s3,0x4
 702:	397d                	addiw	s2,s2,-1
 704:	fe0914e3          	bnez	s2,6ec <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 708:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 70c:	4981                	li	s3,0
 70e:	b721                	j	616 <vprintf+0x60>
        s = va_arg(ap, char*);
 710:	008b0993          	addi	s3,s6,8
 714:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 718:	02090163          	beqz	s2,73a <vprintf+0x184>
        while(*s != 0){
 71c:	00094583          	lbu	a1,0(s2)
 720:	c9a1                	beqz	a1,770 <vprintf+0x1ba>
          putc(fd, *s);
 722:	8556                	mv	a0,s5
 724:	00000097          	auipc	ra,0x0
 728:	dc6080e7          	jalr	-570(ra) # 4ea <putc>
          s++;
 72c:	0905                	addi	s2,s2,1
        while(*s != 0){
 72e:	00094583          	lbu	a1,0(s2)
 732:	f9e5                	bnez	a1,722 <vprintf+0x16c>
        s = va_arg(ap, char*);
 734:	8b4e                	mv	s6,s3
      state = 0;
 736:	4981                	li	s3,0
 738:	bdf9                	j	616 <vprintf+0x60>
          s = "(null)";
 73a:	00000917          	auipc	s2,0x0
 73e:	2f690913          	addi	s2,s2,758 # a30 <malloc+0x1b0>
        while(*s != 0){
 742:	02800593          	li	a1,40
 746:	bff1                	j	722 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 748:	008b0913          	addi	s2,s6,8
 74c:	000b4583          	lbu	a1,0(s6)
 750:	8556                	mv	a0,s5
 752:	00000097          	auipc	ra,0x0
 756:	d98080e7          	jalr	-616(ra) # 4ea <putc>
 75a:	8b4a                	mv	s6,s2
      state = 0;
 75c:	4981                	li	s3,0
 75e:	bd65                	j	616 <vprintf+0x60>
        putc(fd, c);
 760:	85d2                	mv	a1,s4
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	d86080e7          	jalr	-634(ra) # 4ea <putc>
      state = 0;
 76c:	4981                	li	s3,0
 76e:	b565                	j	616 <vprintf+0x60>
        s = va_arg(ap, char*);
 770:	8b4e                	mv	s6,s3
      state = 0;
 772:	4981                	li	s3,0
 774:	b54d                	j	616 <vprintf+0x60>
    }
  }
}
 776:	70e6                	ld	ra,120(sp)
 778:	7446                	ld	s0,112(sp)
 77a:	74a6                	ld	s1,104(sp)
 77c:	7906                	ld	s2,96(sp)
 77e:	69e6                	ld	s3,88(sp)
 780:	6a46                	ld	s4,80(sp)
 782:	6aa6                	ld	s5,72(sp)
 784:	6b06                	ld	s6,64(sp)
 786:	7be2                	ld	s7,56(sp)
 788:	7c42                	ld	s8,48(sp)
 78a:	7ca2                	ld	s9,40(sp)
 78c:	7d02                	ld	s10,32(sp)
 78e:	6de2                	ld	s11,24(sp)
 790:	6109                	addi	sp,sp,128
 792:	8082                	ret

0000000000000794 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 794:	715d                	addi	sp,sp,-80
 796:	ec06                	sd	ra,24(sp)
 798:	e822                	sd	s0,16(sp)
 79a:	1000                	addi	s0,sp,32
 79c:	e010                	sd	a2,0(s0)
 79e:	e414                	sd	a3,8(s0)
 7a0:	e818                	sd	a4,16(s0)
 7a2:	ec1c                	sd	a5,24(s0)
 7a4:	03043023          	sd	a6,32(s0)
 7a8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ac:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7b0:	8622                	mv	a2,s0
 7b2:	00000097          	auipc	ra,0x0
 7b6:	e04080e7          	jalr	-508(ra) # 5b6 <vprintf>
}
 7ba:	60e2                	ld	ra,24(sp)
 7bc:	6442                	ld	s0,16(sp)
 7be:	6161                	addi	sp,sp,80
 7c0:	8082                	ret

00000000000007c2 <printf>:

void
printf(const char *fmt, ...)
{
 7c2:	711d                	addi	sp,sp,-96
 7c4:	ec06                	sd	ra,24(sp)
 7c6:	e822                	sd	s0,16(sp)
 7c8:	1000                	addi	s0,sp,32
 7ca:	e40c                	sd	a1,8(s0)
 7cc:	e810                	sd	a2,16(s0)
 7ce:	ec14                	sd	a3,24(s0)
 7d0:	f018                	sd	a4,32(s0)
 7d2:	f41c                	sd	a5,40(s0)
 7d4:	03043823          	sd	a6,48(s0)
 7d8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7dc:	00840613          	addi	a2,s0,8
 7e0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7e4:	85aa                	mv	a1,a0
 7e6:	4505                	li	a0,1
 7e8:	00000097          	auipc	ra,0x0
 7ec:	dce080e7          	jalr	-562(ra) # 5b6 <vprintf>
}
 7f0:	60e2                	ld	ra,24(sp)
 7f2:	6442                	ld	s0,16(sp)
 7f4:	6125                	addi	sp,sp,96
 7f6:	8082                	ret

00000000000007f8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7f8:	1141                	addi	sp,sp,-16
 7fa:	e422                	sd	s0,8(sp)
 7fc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7fe:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 802:	00000797          	auipc	a5,0x0
 806:	24e7b783          	ld	a5,590(a5) # a50 <freep>
 80a:	a805                	j	83a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 80c:	4618                	lw	a4,8(a2)
 80e:	9db9                	addw	a1,a1,a4
 810:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 814:	6398                	ld	a4,0(a5)
 816:	6318                	ld	a4,0(a4)
 818:	fee53823          	sd	a4,-16(a0)
 81c:	a091                	j	860 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 81e:	ff852703          	lw	a4,-8(a0)
 822:	9e39                	addw	a2,a2,a4
 824:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 826:	ff053703          	ld	a4,-16(a0)
 82a:	e398                	sd	a4,0(a5)
 82c:	a099                	j	872 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82e:	6398                	ld	a4,0(a5)
 830:	00e7e463          	bltu	a5,a4,838 <free+0x40>
 834:	00e6ea63          	bltu	a3,a4,848 <free+0x50>
{
 838:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83a:	fed7fae3          	bgeu	a5,a3,82e <free+0x36>
 83e:	6398                	ld	a4,0(a5)
 840:	00e6e463          	bltu	a3,a4,848 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 844:	fee7eae3          	bltu	a5,a4,838 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 848:	ff852583          	lw	a1,-8(a0)
 84c:	6390                	ld	a2,0(a5)
 84e:	02059713          	slli	a4,a1,0x20
 852:	9301                	srli	a4,a4,0x20
 854:	0712                	slli	a4,a4,0x4
 856:	9736                	add	a4,a4,a3
 858:	fae60ae3          	beq	a2,a4,80c <free+0x14>
    bp->s.ptr = p->s.ptr;
 85c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 860:	4790                	lw	a2,8(a5)
 862:	02061713          	slli	a4,a2,0x20
 866:	9301                	srli	a4,a4,0x20
 868:	0712                	slli	a4,a4,0x4
 86a:	973e                	add	a4,a4,a5
 86c:	fae689e3          	beq	a3,a4,81e <free+0x26>
  } else
    p->s.ptr = bp;
 870:	e394                	sd	a3,0(a5)
  freep = p;
 872:	00000717          	auipc	a4,0x0
 876:	1cf73f23          	sd	a5,478(a4) # a50 <freep>
}
 87a:	6422                	ld	s0,8(sp)
 87c:	0141                	addi	sp,sp,16
 87e:	8082                	ret

0000000000000880 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 880:	7139                	addi	sp,sp,-64
 882:	fc06                	sd	ra,56(sp)
 884:	f822                	sd	s0,48(sp)
 886:	f426                	sd	s1,40(sp)
 888:	f04a                	sd	s2,32(sp)
 88a:	ec4e                	sd	s3,24(sp)
 88c:	e852                	sd	s4,16(sp)
 88e:	e456                	sd	s5,8(sp)
 890:	e05a                	sd	s6,0(sp)
 892:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 894:	02051493          	slli	s1,a0,0x20
 898:	9081                	srli	s1,s1,0x20
 89a:	04bd                	addi	s1,s1,15
 89c:	8091                	srli	s1,s1,0x4
 89e:	0014899b          	addiw	s3,s1,1
 8a2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8a4:	00000517          	auipc	a0,0x0
 8a8:	1ac53503          	ld	a0,428(a0) # a50 <freep>
 8ac:	c515                	beqz	a0,8d8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b0:	4798                	lw	a4,8(a5)
 8b2:	02977f63          	bgeu	a4,s1,8f0 <malloc+0x70>
 8b6:	8a4e                	mv	s4,s3
 8b8:	0009871b          	sext.w	a4,s3
 8bc:	6685                	lui	a3,0x1
 8be:	00d77363          	bgeu	a4,a3,8c4 <malloc+0x44>
 8c2:	6a05                	lui	s4,0x1
 8c4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8c8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8cc:	00000917          	auipc	s2,0x0
 8d0:	18490913          	addi	s2,s2,388 # a50 <freep>
  if(p == (char*)-1)
 8d4:	5afd                	li	s5,-1
 8d6:	a88d                	j	948 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8d8:	00000797          	auipc	a5,0x0
 8dc:	7c078793          	addi	a5,a5,1984 # 1098 <base>
 8e0:	00000717          	auipc	a4,0x0
 8e4:	16f73823          	sd	a5,368(a4) # a50 <freep>
 8e8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ea:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ee:	b7e1                	j	8b6 <malloc+0x36>
      if(p->s.size == nunits)
 8f0:	02e48b63          	beq	s1,a4,926 <malloc+0xa6>
        p->s.size -= nunits;
 8f4:	4137073b          	subw	a4,a4,s3
 8f8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8fa:	1702                	slli	a4,a4,0x20
 8fc:	9301                	srli	a4,a4,0x20
 8fe:	0712                	slli	a4,a4,0x4
 900:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 902:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 906:	00000717          	auipc	a4,0x0
 90a:	14a73523          	sd	a0,330(a4) # a50 <freep>
      return (void*)(p + 1);
 90e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 912:	70e2                	ld	ra,56(sp)
 914:	7442                	ld	s0,48(sp)
 916:	74a2                	ld	s1,40(sp)
 918:	7902                	ld	s2,32(sp)
 91a:	69e2                	ld	s3,24(sp)
 91c:	6a42                	ld	s4,16(sp)
 91e:	6aa2                	ld	s5,8(sp)
 920:	6b02                	ld	s6,0(sp)
 922:	6121                	addi	sp,sp,64
 924:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 926:	6398                	ld	a4,0(a5)
 928:	e118                	sd	a4,0(a0)
 92a:	bff1                	j	906 <malloc+0x86>
  hp->s.size = nu;
 92c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 930:	0541                	addi	a0,a0,16
 932:	00000097          	auipc	ra,0x0
 936:	ec6080e7          	jalr	-314(ra) # 7f8 <free>
  return freep;
 93a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 93e:	d971                	beqz	a0,912 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 940:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 942:	4798                	lw	a4,8(a5)
 944:	fa9776e3          	bgeu	a4,s1,8f0 <malloc+0x70>
    if(p == freep)
 948:	00093703          	ld	a4,0(s2)
 94c:	853e                	mv	a0,a5
 94e:	fef719e3          	bne	a4,a5,940 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 952:	8552                	mv	a0,s4
 954:	00000097          	auipc	ra,0x0
 958:	b66080e7          	jalr	-1178(ra) # 4ba <sbrk>
  if(p == (char*)-1)
 95c:	fd5518e3          	bne	a0,s5,92c <malloc+0xac>
        return 0;
 960:	4501                	li	a0,0
 962:	bf45                	j	912 <malloc+0x92>
