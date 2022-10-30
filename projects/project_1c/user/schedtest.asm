
user/_schedtest:     file format elf64-littleriscv


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
  30:	9ff78793          	addi	a5,a5,-1537 # 3b9ac9ff <__global_pointer$+0x3b9ab566>
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
  56:	61a080e7          	jalr	1562(ra) # 66c <sleep>
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
int main() {
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
  9a:	5e6080e7          	jalr	1510(ra) # 67c <startlog>

    printf("running test 1 (two cpu bound)\n\n");
  9e:	00001517          	auipc	a0,0x1
  a2:	a8a50513          	addi	a0,a0,-1398 # b28 <malloc+0xfe>
  a6:	00001097          	auipc	ra,0x1
  aa:	8c6080e7          	jalr	-1850(ra) # 96c <printf>
    a = fork();
  ae:	00000097          	auipc	ra,0x0
  b2:	526080e7          	jalr	1318(ra) # 5d4 <fork>
    if (a == 0)
  b6:	cd5d                	beqz	a0,174 <main+0xfa>
  b8:	892a                	mv	s2,a0
        run_cpu();
        exit(0);
    }
    else
    {
        b = fork();
  ba:	00000097          	auipc	ra,0x0
  be:	51a080e7          	jalr	1306(ra) # 5d4 <fork>
  c2:	84aa                	mv	s1,a0
        if (b == 0)
  c4:	c571                	beqz	a0,190 <main+0x116>
            nice(-19);
            run_cpu();
            exit(0);
        }
    }
    printf("parent pid: %d\n", getpid());
  c6:	00000097          	auipc	ra,0x0
  ca:	596080e7          	jalr	1430(ra) # 65c <getpid>
  ce:	85aa                	mv	a1,a0
  d0:	00001517          	auipc	a0,0x1
  d4:	a8050513          	addi	a0,a0,-1408 # b50 <malloc+0x126>
  d8:	00001097          	auipc	ra,0x1
  dc:	894080e7          	jalr	-1900(ra) # 96c <printf>
    printf("first child pid: %d\n", a);
  e0:	85ca                	mv	a1,s2
  e2:	00001517          	auipc	a0,0x1
  e6:	a7e50513          	addi	a0,a0,-1410 # b60 <malloc+0x136>
  ea:	00001097          	auipc	ra,0x1
  ee:	882080e7          	jalr	-1918(ra) # 96c <printf>
    printf("second child pid: %d\n", b);
  f2:	85a6                	mv	a1,s1
  f4:	00001517          	auipc	a0,0x1
  f8:	a8450513          	addi	a0,a0,-1404 # b78 <malloc+0x14e>
  fc:	00001097          	auipc	ra,0x1
 100:	870080e7          	jalr	-1936(ra) # 96c <printf>

    wait(0);
 104:	4501                	li	a0,0
 106:	00000097          	auipc	ra,0x0
 10a:	4de080e7          	jalr	1246(ra) # 5e4 <wait>
    wait(0);
 10e:	4501                	li	a0,0
 110:	00000097          	auipc	ra,0x0
 114:	4d4080e7          	jalr	1236(ra) # 5e4 <wait>
    printf("long running completed\n\n");
 118:	00001517          	auipc	a0,0x1
 11c:	a7850513          	addi	a0,a0,-1416 # b90 <malloc+0x166>
 120:	00001097          	auipc	ra,0x1
 124:	84c080e7          	jalr	-1972(ra) # 96c <printf>

    uint64 count = getlog(schedlog);
 128:	00001517          	auipc	a0,0x1
 12c:	b8050513          	addi	a0,a0,-1152 # ca8 <schedlog>
 130:	00000097          	auipc	ra,0x0
 134:	554080e7          	jalr	1364(ra) # 684 <getlog>
 138:	89aa                	mv	s3,a0

    for (int i = 0; i < count; i++)
 13a:	c555                	beqz	a0,1e6 <main+0x16c>
 13c:	00001497          	auipc	s1,0x1
 140:	b6c48493          	addi	s1,s1,-1172 # ca8 <schedlog>
 144:	4901                	li	s2,0
    {
        if (schedlog[i].priority_boost)
            printf("** priority boost at time %d **\n", schedlog[i].time);
        else
            printf("pid %d started at %d in queue %s\n", schedlog[i].pid, schedlog[i].time, schedlog[i].queue == 2 ? "High" : schedlog[i].queue == 1 ? "Medium"
 146:	4b09                	li	s6,2
 148:	00001a97          	auipc	s5,0x1
 14c:	9c8a8a93          	addi	s5,s5,-1592 # b10 <malloc+0xe6>
 150:	00001a17          	auipc	s4,0x1
 154:	a88a0a13          	addi	s4,s4,-1400 # bd8 <malloc+0x1ae>
                                                                                                                                                     : "Low");
 158:	4c05                	li	s8,1
 15a:	00001b97          	auipc	s7,0x1
 15e:	9beb8b93          	addi	s7,s7,-1602 # b18 <malloc+0xee>
 162:	00001d17          	auipc	s10,0x1
 166:	9bed0d13          	addi	s10,s10,-1602 # b20 <malloc+0xf6>
            printf("** priority boost at time %d **\n", schedlog[i].time);
 16a:	00001c97          	auipc	s9,0x1
 16e:	a46c8c93          	addi	s9,s9,-1466 # bb0 <malloc+0x186>
 172:	a8a9                	j	1cc <main+0x152>
        nice(-19);
 174:	5535                	li	a0,-19
 176:	00000097          	auipc	ra,0x0
 17a:	516080e7          	jalr	1302(ra) # 68c <nice>
        run_cpu();
 17e:	00000097          	auipc	ra,0x0
 182:	e82080e7          	jalr	-382(ra) # 0 <run_cpu>
        exit(0);
 186:	4501                	li	a0,0
 188:	00000097          	auipc	ra,0x0
 18c:	454080e7          	jalr	1108(ra) # 5dc <exit>
            nice(-19);
 190:	5535                	li	a0,-19
 192:	00000097          	auipc	ra,0x0
 196:	4fa080e7          	jalr	1274(ra) # 68c <nice>
            run_cpu();
 19a:	00000097          	auipc	ra,0x0
 19e:	e66080e7          	jalr	-410(ra) # 0 <run_cpu>
            exit(0);
 1a2:	4501                	li	a0,0
 1a4:	00000097          	auipc	ra,0x0
 1a8:	438080e7          	jalr	1080(ra) # 5dc <exit>
            printf("** priority boost at time %d **\n", schedlog[i].time);
 1ac:	40cc                	lw	a1,4(s1)
 1ae:	8566                	mv	a0,s9
 1b0:	00000097          	auipc	ra,0x0
 1b4:	7bc080e7          	jalr	1980(ra) # 96c <printf>
 1b8:	a031                	j	1c4 <main+0x14a>
            printf("pid %d started at %d in queue %s\n", schedlog[i].pid, schedlog[i].time, schedlog[i].queue == 2 ? "High" : schedlog[i].queue == 1 ? "Medium"
 1ba:	8552                	mv	a0,s4
 1bc:	00000097          	auipc	ra,0x0
 1c0:	7b0080e7          	jalr	1968(ra) # 96c <printf>
    for (int i = 0; i < count; i++)
 1c4:	0905                	addi	s2,s2,1
 1c6:	04c1                	addi	s1,s1,16
 1c8:	01298f63          	beq	s3,s2,1e6 <main+0x16c>
        if (schedlog[i].priority_boost)
 1cc:	44dc                	lw	a5,12(s1)
 1ce:	fff9                	bnez	a5,1ac <main+0x132>
            printf("pid %d started at %d in queue %s\n", schedlog[i].pid, schedlog[i].time, schedlog[i].queue == 2 ? "High" : schedlog[i].queue == 1 ? "Medium"
 1d0:	408c                	lw	a1,0(s1)
 1d2:	40d0                	lw	a2,4(s1)
 1d4:	449c                	lw	a5,8(s1)
 1d6:	86d6                	mv	a3,s5
 1d8:	ff6781e3          	beq	a5,s6,1ba <main+0x140>
                                                                                                                                                     : "Low");
 1dc:	86de                	mv	a3,s7
 1de:	fd878ee3          	beq	a5,s8,1ba <main+0x140>
 1e2:	86ea                	mv	a3,s10
 1e4:	bfd9                	j	1ba <main+0x140>
    }

    printf("\n\nrunning test 2 (one io bound, one cpu bound)\n\n");
 1e6:	00001517          	auipc	a0,0x1
 1ea:	a1a50513          	addi	a0,a0,-1510 # c00 <malloc+0x1d6>
 1ee:	00000097          	auipc	ra,0x0
 1f2:	77e080e7          	jalr	1918(ra) # 96c <printf>
    startlog();
 1f6:	00000097          	auipc	ra,0x0
 1fa:	486080e7          	jalr	1158(ra) # 67c <startlog>

    a = fork();
 1fe:	00000097          	auipc	ra,0x0
 202:	3d6080e7          	jalr	982(ra) # 5d4 <fork>
 206:	892a                	mv	s2,a0
    if (a == 0)
 208:	cd55                	beqz	a0,2c4 <main+0x24a>
        run_io();
        exit(0);
    }
    else
    {
        b = fork();
 20a:	00000097          	auipc	ra,0x0
 20e:	3ca080e7          	jalr	970(ra) # 5d4 <fork>
 212:	84aa                	mv	s1,a0
        if (b == 0)
 214:	c571                	beqz	a0,2e0 <main+0x266>
            nice(-19);
            run_cpu();
            exit(0);
        }
    }
    printf("parent pid: %d\n", getpid());
 216:	00000097          	auipc	ra,0x0
 21a:	446080e7          	jalr	1094(ra) # 65c <getpid>
 21e:	85aa                	mv	a1,a0
 220:	00001517          	auipc	a0,0x1
 224:	93050513          	addi	a0,a0,-1744 # b50 <malloc+0x126>
 228:	00000097          	auipc	ra,0x0
 22c:	744080e7          	jalr	1860(ra) # 96c <printf>
    printf("first child (io bound) pid: %d\n", a);
 230:	85ca                	mv	a1,s2
 232:	00001517          	auipc	a0,0x1
 236:	a0650513          	addi	a0,a0,-1530 # c38 <malloc+0x20e>
 23a:	00000097          	auipc	ra,0x0
 23e:	732080e7          	jalr	1842(ra) # 96c <printf>
    printf("second child (cpu bound) pid: %d\n", b);
 242:	85a6                	mv	a1,s1
 244:	00001517          	auipc	a0,0x1
 248:	a1450513          	addi	a0,a0,-1516 # c58 <malloc+0x22e>
 24c:	00000097          	auipc	ra,0x0
 250:	720080e7          	jalr	1824(ra) # 96c <printf>

    wait(0);
 254:	4501                	li	a0,0
 256:	00000097          	auipc	ra,0x0
 25a:	38e080e7          	jalr	910(ra) # 5e4 <wait>
    wait(0);
 25e:	4501                	li	a0,0
 260:	00000097          	auipc	ra,0x0
 264:	384080e7          	jalr	900(ra) # 5e4 <wait>
    printf("long running completed\n\n");
 268:	00001517          	auipc	a0,0x1
 26c:	92850513          	addi	a0,a0,-1752 # b90 <malloc+0x166>
 270:	00000097          	auipc	ra,0x0
 274:	6fc080e7          	jalr	1788(ra) # 96c <printf>

    count = getlog(schedlog);
 278:	00001517          	auipc	a0,0x1
 27c:	a3050513          	addi	a0,a0,-1488 # ca8 <schedlog>
 280:	00000097          	auipc	ra,0x0
 284:	404080e7          	jalr	1028(ra) # 684 <getlog>
 288:	89aa                	mv	s3,a0

    for (int i = 0; i < count; i++)
 28a:	c555                	beqz	a0,336 <main+0x2bc>
 28c:	00001497          	auipc	s1,0x1
 290:	a1c48493          	addi	s1,s1,-1508 # ca8 <schedlog>
 294:	4901                	li	s2,0
    {
        if (schedlog[i].priority_boost)
            printf("** priority boost at time %d **\n", schedlog[i].time);
        else
            printf("pid %d started at %d in queue %s\n", schedlog[i].pid, schedlog[i].time, schedlog[i].queue == 2 ? "High" : schedlog[i].queue == 1 ? "Medium"
 296:	4b09                	li	s6,2
 298:	00001a97          	auipc	s5,0x1
 29c:	878a8a93          	addi	s5,s5,-1928 # b10 <malloc+0xe6>
 2a0:	00001a17          	auipc	s4,0x1
 2a4:	938a0a13          	addi	s4,s4,-1736 # bd8 <malloc+0x1ae>
                                                                                                                                                     : "Low");
 2a8:	4c05                	li	s8,1
 2aa:	00001b97          	auipc	s7,0x1
 2ae:	86eb8b93          	addi	s7,s7,-1938 # b18 <malloc+0xee>
 2b2:	00001d17          	auipc	s10,0x1
 2b6:	86ed0d13          	addi	s10,s10,-1938 # b20 <malloc+0xf6>
            printf("** priority boost at time %d **\n", schedlog[i].time);
 2ba:	00001c97          	auipc	s9,0x1
 2be:	8f6c8c93          	addi	s9,s9,-1802 # bb0 <malloc+0x186>
 2c2:	a8a9                	j	31c <main+0x2a2>
        nice(-19);
 2c4:	5535                	li	a0,-19
 2c6:	00000097          	auipc	ra,0x0
 2ca:	3c6080e7          	jalr	966(ra) # 68c <nice>
        run_io();
 2ce:	00000097          	auipc	ra,0x0
 2d2:	d74080e7          	jalr	-652(ra) # 42 <run_io>
        exit(0);
 2d6:	4501                	li	a0,0
 2d8:	00000097          	auipc	ra,0x0
 2dc:	304080e7          	jalr	772(ra) # 5dc <exit>
            nice(-19);
 2e0:	5535                	li	a0,-19
 2e2:	00000097          	auipc	ra,0x0
 2e6:	3aa080e7          	jalr	938(ra) # 68c <nice>
            run_cpu();
 2ea:	00000097          	auipc	ra,0x0
 2ee:	d16080e7          	jalr	-746(ra) # 0 <run_cpu>
            exit(0);
 2f2:	4501                	li	a0,0
 2f4:	00000097          	auipc	ra,0x0
 2f8:	2e8080e7          	jalr	744(ra) # 5dc <exit>
            printf("** priority boost at time %d **\n", schedlog[i].time);
 2fc:	40cc                	lw	a1,4(s1)
 2fe:	8566                	mv	a0,s9
 300:	00000097          	auipc	ra,0x0
 304:	66c080e7          	jalr	1644(ra) # 96c <printf>
 308:	a031                	j	314 <main+0x29a>
            printf("pid %d started at %d in queue %s\n", schedlog[i].pid, schedlog[i].time, schedlog[i].queue == 2 ? "High" : schedlog[i].queue == 1 ? "Medium"
 30a:	8552                	mv	a0,s4
 30c:	00000097          	auipc	ra,0x0
 310:	660080e7          	jalr	1632(ra) # 96c <printf>
    for (int i = 0; i < count; i++)
 314:	0905                	addi	s2,s2,1
 316:	04c1                	addi	s1,s1,16
 318:	01390f63          	beq	s2,s3,336 <main+0x2bc>
        if (schedlog[i].priority_boost)
 31c:	44dc                	lw	a5,12(s1)
 31e:	fff9                	bnez	a5,2fc <main+0x282>
            printf("pid %d started at %d in queue %s\n", schedlog[i].pid, schedlog[i].time, schedlog[i].queue == 2 ? "High" : schedlog[i].queue == 1 ? "Medium"
 320:	408c                	lw	a1,0(s1)
 322:	40d0                	lw	a2,4(s1)
 324:	449c                	lw	a5,8(s1)
 326:	86d6                	mv	a3,s5
 328:	ff6781e3          	beq	a5,s6,30a <main+0x290>
                                                                                                                                                     : "Low");
 32c:	86de                	mv	a3,s7
 32e:	fd878ee3          	beq	a5,s8,30a <main+0x290>
 332:	86ea                	mv	a3,s10
 334:	bfd9                	j	30a <main+0x290>
    }

    return 0;
 336:	4501                	li	a0,0
 338:	60e6                	ld	ra,88(sp)
 33a:	6446                	ld	s0,80(sp)
 33c:	64a6                	ld	s1,72(sp)
 33e:	6906                	ld	s2,64(sp)
 340:	79e2                	ld	s3,56(sp)
 342:	7a42                	ld	s4,48(sp)
 344:	7aa2                	ld	s5,40(sp)
 346:	7b02                	ld	s6,32(sp)
 348:	6be2                	ld	s7,24(sp)
 34a:	6c42                	ld	s8,16(sp)
 34c:	6ca2                	ld	s9,8(sp)
 34e:	6d02                	ld	s10,0(sp)
 350:	6125                	addi	sp,sp,96
 352:	8082                	ret

0000000000000354 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 354:	1141                	addi	sp,sp,-16
 356:	e406                	sd	ra,8(sp)
 358:	e022                	sd	s0,0(sp)
 35a:	0800                	addi	s0,sp,16
  extern int main();
  main();
 35c:	00000097          	auipc	ra,0x0
 360:	d1e080e7          	jalr	-738(ra) # 7a <main>
  exit(0);
 364:	4501                	li	a0,0
 366:	00000097          	auipc	ra,0x0
 36a:	276080e7          	jalr	630(ra) # 5dc <exit>

000000000000036e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e422                	sd	s0,8(sp)
 372:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 374:	87aa                	mv	a5,a0
 376:	0585                	addi	a1,a1,1
 378:	0785                	addi	a5,a5,1
 37a:	fff5c703          	lbu	a4,-1(a1)
 37e:	fee78fa3          	sb	a4,-1(a5)
 382:	fb75                	bnez	a4,376 <strcpy+0x8>
    ;
  return os;
}
 384:	6422                	ld	s0,8(sp)
 386:	0141                	addi	sp,sp,16
 388:	8082                	ret

000000000000038a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 38a:	1141                	addi	sp,sp,-16
 38c:	e422                	sd	s0,8(sp)
 38e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 390:	00054783          	lbu	a5,0(a0)
 394:	cb91                	beqz	a5,3a8 <strcmp+0x1e>
 396:	0005c703          	lbu	a4,0(a1)
 39a:	00f71763          	bne	a4,a5,3a8 <strcmp+0x1e>
    p++, q++;
 39e:	0505                	addi	a0,a0,1
 3a0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 3a2:	00054783          	lbu	a5,0(a0)
 3a6:	fbe5                	bnez	a5,396 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 3a8:	0005c503          	lbu	a0,0(a1)
}
 3ac:	40a7853b          	subw	a0,a5,a0
 3b0:	6422                	ld	s0,8(sp)
 3b2:	0141                	addi	sp,sp,16
 3b4:	8082                	ret

00000000000003b6 <strlen>:

uint
strlen(const char *s)
{
 3b6:	1141                	addi	sp,sp,-16
 3b8:	e422                	sd	s0,8(sp)
 3ba:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 3bc:	00054783          	lbu	a5,0(a0)
 3c0:	cf91                	beqz	a5,3dc <strlen+0x26>
 3c2:	0505                	addi	a0,a0,1
 3c4:	87aa                	mv	a5,a0
 3c6:	4685                	li	a3,1
 3c8:	9e89                	subw	a3,a3,a0
 3ca:	00f6853b          	addw	a0,a3,a5
 3ce:	0785                	addi	a5,a5,1
 3d0:	fff7c703          	lbu	a4,-1(a5)
 3d4:	fb7d                	bnez	a4,3ca <strlen+0x14>
    ;
  return n;
}
 3d6:	6422                	ld	s0,8(sp)
 3d8:	0141                	addi	sp,sp,16
 3da:	8082                	ret
  for(n = 0; s[n]; n++)
 3dc:	4501                	li	a0,0
 3de:	bfe5                	j	3d6 <strlen+0x20>

00000000000003e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3e0:	1141                	addi	sp,sp,-16
 3e2:	e422                	sd	s0,8(sp)
 3e4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3e6:	ca19                	beqz	a2,3fc <memset+0x1c>
 3e8:	87aa                	mv	a5,a0
 3ea:	1602                	slli	a2,a2,0x20
 3ec:	9201                	srli	a2,a2,0x20
 3ee:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3f2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3f6:	0785                	addi	a5,a5,1
 3f8:	fee79de3          	bne	a5,a4,3f2 <memset+0x12>
  }
  return dst;
}
 3fc:	6422                	ld	s0,8(sp)
 3fe:	0141                	addi	sp,sp,16
 400:	8082                	ret

0000000000000402 <strchr>:

char*
strchr(const char *s, char c)
{
 402:	1141                	addi	sp,sp,-16
 404:	e422                	sd	s0,8(sp)
 406:	0800                	addi	s0,sp,16
  for(; *s; s++)
 408:	00054783          	lbu	a5,0(a0)
 40c:	cb99                	beqz	a5,422 <strchr+0x20>
    if(*s == c)
 40e:	00f58763          	beq	a1,a5,41c <strchr+0x1a>
  for(; *s; s++)
 412:	0505                	addi	a0,a0,1
 414:	00054783          	lbu	a5,0(a0)
 418:	fbfd                	bnez	a5,40e <strchr+0xc>
      return (char*)s;
  return 0;
 41a:	4501                	li	a0,0
}
 41c:	6422                	ld	s0,8(sp)
 41e:	0141                	addi	sp,sp,16
 420:	8082                	ret
  return 0;
 422:	4501                	li	a0,0
 424:	bfe5                	j	41c <strchr+0x1a>

0000000000000426 <gets>:

char*
gets(char *buf, int max)
{
 426:	711d                	addi	sp,sp,-96
 428:	ec86                	sd	ra,88(sp)
 42a:	e8a2                	sd	s0,80(sp)
 42c:	e4a6                	sd	s1,72(sp)
 42e:	e0ca                	sd	s2,64(sp)
 430:	fc4e                	sd	s3,56(sp)
 432:	f852                	sd	s4,48(sp)
 434:	f456                	sd	s5,40(sp)
 436:	f05a                	sd	s6,32(sp)
 438:	ec5e                	sd	s7,24(sp)
 43a:	1080                	addi	s0,sp,96
 43c:	8baa                	mv	s7,a0
 43e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 440:	892a                	mv	s2,a0
 442:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 444:	4aa9                	li	s5,10
 446:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 448:	89a6                	mv	s3,s1
 44a:	2485                	addiw	s1,s1,1
 44c:	0344d863          	bge	s1,s4,47c <gets+0x56>
    cc = read(0, &c, 1);
 450:	4605                	li	a2,1
 452:	faf40593          	addi	a1,s0,-81
 456:	4501                	li	a0,0
 458:	00000097          	auipc	ra,0x0
 45c:	19c080e7          	jalr	412(ra) # 5f4 <read>
    if(cc < 1)
 460:	00a05e63          	blez	a0,47c <gets+0x56>
    buf[i++] = c;
 464:	faf44783          	lbu	a5,-81(s0)
 468:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 46c:	01578763          	beq	a5,s5,47a <gets+0x54>
 470:	0905                	addi	s2,s2,1
 472:	fd679be3          	bne	a5,s6,448 <gets+0x22>
  for(i=0; i+1 < max; ){
 476:	89a6                	mv	s3,s1
 478:	a011                	j	47c <gets+0x56>
 47a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 47c:	99de                	add	s3,s3,s7
 47e:	00098023          	sb	zero,0(s3)
  return buf;
}
 482:	855e                	mv	a0,s7
 484:	60e6                	ld	ra,88(sp)
 486:	6446                	ld	s0,80(sp)
 488:	64a6                	ld	s1,72(sp)
 48a:	6906                	ld	s2,64(sp)
 48c:	79e2                	ld	s3,56(sp)
 48e:	7a42                	ld	s4,48(sp)
 490:	7aa2                	ld	s5,40(sp)
 492:	7b02                	ld	s6,32(sp)
 494:	6be2                	ld	s7,24(sp)
 496:	6125                	addi	sp,sp,96
 498:	8082                	ret

000000000000049a <stat>:

int
stat(const char *n, struct stat *st)
{
 49a:	1101                	addi	sp,sp,-32
 49c:	ec06                	sd	ra,24(sp)
 49e:	e822                	sd	s0,16(sp)
 4a0:	e426                	sd	s1,8(sp)
 4a2:	e04a                	sd	s2,0(sp)
 4a4:	1000                	addi	s0,sp,32
 4a6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4a8:	4581                	li	a1,0
 4aa:	00000097          	auipc	ra,0x0
 4ae:	172080e7          	jalr	370(ra) # 61c <open>
  if(fd < 0)
 4b2:	02054563          	bltz	a0,4dc <stat+0x42>
 4b6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 4b8:	85ca                	mv	a1,s2
 4ba:	00000097          	auipc	ra,0x0
 4be:	17a080e7          	jalr	378(ra) # 634 <fstat>
 4c2:	892a                	mv	s2,a0
  close(fd);
 4c4:	8526                	mv	a0,s1
 4c6:	00000097          	auipc	ra,0x0
 4ca:	13e080e7          	jalr	318(ra) # 604 <close>
  return r;
}
 4ce:	854a                	mv	a0,s2
 4d0:	60e2                	ld	ra,24(sp)
 4d2:	6442                	ld	s0,16(sp)
 4d4:	64a2                	ld	s1,8(sp)
 4d6:	6902                	ld	s2,0(sp)
 4d8:	6105                	addi	sp,sp,32
 4da:	8082                	ret
    return -1;
 4dc:	597d                	li	s2,-1
 4de:	bfc5                	j	4ce <stat+0x34>

00000000000004e0 <atoi>:

int
atoi(const char *s)
{
 4e0:	1141                	addi	sp,sp,-16
 4e2:	e422                	sd	s0,8(sp)
 4e4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4e6:	00054603          	lbu	a2,0(a0)
 4ea:	fd06079b          	addiw	a5,a2,-48
 4ee:	0ff7f793          	andi	a5,a5,255
 4f2:	4725                	li	a4,9
 4f4:	02f76963          	bltu	a4,a5,526 <atoi+0x46>
 4f8:	86aa                	mv	a3,a0
  n = 0;
 4fa:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4fc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4fe:	0685                	addi	a3,a3,1
 500:	0025179b          	slliw	a5,a0,0x2
 504:	9fa9                	addw	a5,a5,a0
 506:	0017979b          	slliw	a5,a5,0x1
 50a:	9fb1                	addw	a5,a5,a2
 50c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 510:	0006c603          	lbu	a2,0(a3)
 514:	fd06071b          	addiw	a4,a2,-48
 518:	0ff77713          	andi	a4,a4,255
 51c:	fee5f1e3          	bgeu	a1,a4,4fe <atoi+0x1e>
  return n;
}
 520:	6422                	ld	s0,8(sp)
 522:	0141                	addi	sp,sp,16
 524:	8082                	ret
  n = 0;
 526:	4501                	li	a0,0
 528:	bfe5                	j	520 <atoi+0x40>

000000000000052a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 52a:	1141                	addi	sp,sp,-16
 52c:	e422                	sd	s0,8(sp)
 52e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 530:	02b57463          	bgeu	a0,a1,558 <memmove+0x2e>
    while(n-- > 0)
 534:	00c05f63          	blez	a2,552 <memmove+0x28>
 538:	1602                	slli	a2,a2,0x20
 53a:	9201                	srli	a2,a2,0x20
 53c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 540:	872a                	mv	a4,a0
      *dst++ = *src++;
 542:	0585                	addi	a1,a1,1
 544:	0705                	addi	a4,a4,1
 546:	fff5c683          	lbu	a3,-1(a1)
 54a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 54e:	fee79ae3          	bne	a5,a4,542 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 552:	6422                	ld	s0,8(sp)
 554:	0141                	addi	sp,sp,16
 556:	8082                	ret
    dst += n;
 558:	00c50733          	add	a4,a0,a2
    src += n;
 55c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 55e:	fec05ae3          	blez	a2,552 <memmove+0x28>
 562:	fff6079b          	addiw	a5,a2,-1
 566:	1782                	slli	a5,a5,0x20
 568:	9381                	srli	a5,a5,0x20
 56a:	fff7c793          	not	a5,a5
 56e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 570:	15fd                	addi	a1,a1,-1
 572:	177d                	addi	a4,a4,-1
 574:	0005c683          	lbu	a3,0(a1)
 578:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 57c:	fee79ae3          	bne	a5,a4,570 <memmove+0x46>
 580:	bfc9                	j	552 <memmove+0x28>

0000000000000582 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 582:	1141                	addi	sp,sp,-16
 584:	e422                	sd	s0,8(sp)
 586:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 588:	ca05                	beqz	a2,5b8 <memcmp+0x36>
 58a:	fff6069b          	addiw	a3,a2,-1
 58e:	1682                	slli	a3,a3,0x20
 590:	9281                	srli	a3,a3,0x20
 592:	0685                	addi	a3,a3,1
 594:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 596:	00054783          	lbu	a5,0(a0)
 59a:	0005c703          	lbu	a4,0(a1)
 59e:	00e79863          	bne	a5,a4,5ae <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 5a2:	0505                	addi	a0,a0,1
    p2++;
 5a4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 5a6:	fed518e3          	bne	a0,a3,596 <memcmp+0x14>
  }
  return 0;
 5aa:	4501                	li	a0,0
 5ac:	a019                	j	5b2 <memcmp+0x30>
      return *p1 - *p2;
 5ae:	40e7853b          	subw	a0,a5,a4
}
 5b2:	6422                	ld	s0,8(sp)
 5b4:	0141                	addi	sp,sp,16
 5b6:	8082                	ret
  return 0;
 5b8:	4501                	li	a0,0
 5ba:	bfe5                	j	5b2 <memcmp+0x30>

00000000000005bc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 5bc:	1141                	addi	sp,sp,-16
 5be:	e406                	sd	ra,8(sp)
 5c0:	e022                	sd	s0,0(sp)
 5c2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 5c4:	00000097          	auipc	ra,0x0
 5c8:	f66080e7          	jalr	-154(ra) # 52a <memmove>
}
 5cc:	60a2                	ld	ra,8(sp)
 5ce:	6402                	ld	s0,0(sp)
 5d0:	0141                	addi	sp,sp,16
 5d2:	8082                	ret

00000000000005d4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5d4:	4885                	li	a7,1
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <exit>:
.global exit
exit:
 li a7, SYS_exit
 5dc:	4889                	li	a7,2
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5e4:	488d                	li	a7,3
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5ec:	4891                	li	a7,4
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <read>:
.global read
read:
 li a7, SYS_read
 5f4:	4895                	li	a7,5
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <write>:
.global write
write:
 li a7, SYS_write
 5fc:	48c1                	li	a7,16
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <close>:
.global close
close:
 li a7, SYS_close
 604:	48d5                	li	a7,21
 ecall
 606:	00000073          	ecall
 ret
 60a:	8082                	ret

000000000000060c <kill>:
.global kill
kill:
 li a7, SYS_kill
 60c:	4899                	li	a7,6
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <exec>:
.global exec
exec:
 li a7, SYS_exec
 614:	489d                	li	a7,7
 ecall
 616:	00000073          	ecall
 ret
 61a:	8082                	ret

000000000000061c <open>:
.global open
open:
 li a7, SYS_open
 61c:	48bd                	li	a7,15
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 624:	48c5                	li	a7,17
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 62c:	48c9                	li	a7,18
 ecall
 62e:	00000073          	ecall
 ret
 632:	8082                	ret

0000000000000634 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 634:	48a1                	li	a7,8
 ecall
 636:	00000073          	ecall
 ret
 63a:	8082                	ret

000000000000063c <link>:
.global link
link:
 li a7, SYS_link
 63c:	48cd                	li	a7,19
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 644:	48d1                	li	a7,20
 ecall
 646:	00000073          	ecall
 ret
 64a:	8082                	ret

000000000000064c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 64c:	48a5                	li	a7,9
 ecall
 64e:	00000073          	ecall
 ret
 652:	8082                	ret

0000000000000654 <dup>:
.global dup
dup:
 li a7, SYS_dup
 654:	48a9                	li	a7,10
 ecall
 656:	00000073          	ecall
 ret
 65a:	8082                	ret

000000000000065c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 65c:	48ad                	li	a7,11
 ecall
 65e:	00000073          	ecall
 ret
 662:	8082                	ret

0000000000000664 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 664:	48b1                	li	a7,12
 ecall
 666:	00000073          	ecall
 ret
 66a:	8082                	ret

000000000000066c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 66c:	48b5                	li	a7,13
 ecall
 66e:	00000073          	ecall
 ret
 672:	8082                	ret

0000000000000674 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 674:	48b9                	li	a7,14
 ecall
 676:	00000073          	ecall
 ret
 67a:	8082                	ret

000000000000067c <startlog>:
.global startlog
startlog:
 li a7, SYS_startlog
 67c:	48d9                	li	a7,22
 ecall
 67e:	00000073          	ecall
 ret
 682:	8082                	ret

0000000000000684 <getlog>:
.global getlog
getlog:
 li a7, SYS_getlog
 684:	48dd                	li	a7,23
 ecall
 686:	00000073          	ecall
 ret
 68a:	8082                	ret

000000000000068c <nice>:
.global nice
nice:
 li a7, SYS_nice
 68c:	48e1                	li	a7,24
 ecall
 68e:	00000073          	ecall
 ret
 692:	8082                	ret

0000000000000694 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 694:	1101                	addi	sp,sp,-32
 696:	ec06                	sd	ra,24(sp)
 698:	e822                	sd	s0,16(sp)
 69a:	1000                	addi	s0,sp,32
 69c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 6a0:	4605                	li	a2,1
 6a2:	fef40593          	addi	a1,s0,-17
 6a6:	00000097          	auipc	ra,0x0
 6aa:	f56080e7          	jalr	-170(ra) # 5fc <write>
}
 6ae:	60e2                	ld	ra,24(sp)
 6b0:	6442                	ld	s0,16(sp)
 6b2:	6105                	addi	sp,sp,32
 6b4:	8082                	ret

00000000000006b6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6b6:	7139                	addi	sp,sp,-64
 6b8:	fc06                	sd	ra,56(sp)
 6ba:	f822                	sd	s0,48(sp)
 6bc:	f426                	sd	s1,40(sp)
 6be:	f04a                	sd	s2,32(sp)
 6c0:	ec4e                	sd	s3,24(sp)
 6c2:	0080                	addi	s0,sp,64
 6c4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6c6:	c299                	beqz	a3,6cc <printint+0x16>
 6c8:	0805c863          	bltz	a1,758 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 6cc:	2581                	sext.w	a1,a1
  neg = 0;
 6ce:	4881                	li	a7,0
 6d0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 6d4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 6d6:	2601                	sext.w	a2,a2
 6d8:	00000517          	auipc	a0,0x0
 6dc:	5b050513          	addi	a0,a0,1456 # c88 <digits>
 6e0:	883a                	mv	a6,a4
 6e2:	2705                	addiw	a4,a4,1
 6e4:	02c5f7bb          	remuw	a5,a1,a2
 6e8:	1782                	slli	a5,a5,0x20
 6ea:	9381                	srli	a5,a5,0x20
 6ec:	97aa                	add	a5,a5,a0
 6ee:	0007c783          	lbu	a5,0(a5)
 6f2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6f6:	0005879b          	sext.w	a5,a1
 6fa:	02c5d5bb          	divuw	a1,a1,a2
 6fe:	0685                	addi	a3,a3,1
 700:	fec7f0e3          	bgeu	a5,a2,6e0 <printint+0x2a>
  if(neg)
 704:	00088b63          	beqz	a7,71a <printint+0x64>
    buf[i++] = '-';
 708:	fd040793          	addi	a5,s0,-48
 70c:	973e                	add	a4,a4,a5
 70e:	02d00793          	li	a5,45
 712:	fef70823          	sb	a5,-16(a4)
 716:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 71a:	02e05863          	blez	a4,74a <printint+0x94>
 71e:	fc040793          	addi	a5,s0,-64
 722:	00e78933          	add	s2,a5,a4
 726:	fff78993          	addi	s3,a5,-1
 72a:	99ba                	add	s3,s3,a4
 72c:	377d                	addiw	a4,a4,-1
 72e:	1702                	slli	a4,a4,0x20
 730:	9301                	srli	a4,a4,0x20
 732:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 736:	fff94583          	lbu	a1,-1(s2)
 73a:	8526                	mv	a0,s1
 73c:	00000097          	auipc	ra,0x0
 740:	f58080e7          	jalr	-168(ra) # 694 <putc>
  while(--i >= 0)
 744:	197d                	addi	s2,s2,-1
 746:	ff3918e3          	bne	s2,s3,736 <printint+0x80>
}
 74a:	70e2                	ld	ra,56(sp)
 74c:	7442                	ld	s0,48(sp)
 74e:	74a2                	ld	s1,40(sp)
 750:	7902                	ld	s2,32(sp)
 752:	69e2                	ld	s3,24(sp)
 754:	6121                	addi	sp,sp,64
 756:	8082                	ret
    x = -xx;
 758:	40b005bb          	negw	a1,a1
    neg = 1;
 75c:	4885                	li	a7,1
    x = -xx;
 75e:	bf8d                	j	6d0 <printint+0x1a>

0000000000000760 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 760:	7119                	addi	sp,sp,-128
 762:	fc86                	sd	ra,120(sp)
 764:	f8a2                	sd	s0,112(sp)
 766:	f4a6                	sd	s1,104(sp)
 768:	f0ca                	sd	s2,96(sp)
 76a:	ecce                	sd	s3,88(sp)
 76c:	e8d2                	sd	s4,80(sp)
 76e:	e4d6                	sd	s5,72(sp)
 770:	e0da                	sd	s6,64(sp)
 772:	fc5e                	sd	s7,56(sp)
 774:	f862                	sd	s8,48(sp)
 776:	f466                	sd	s9,40(sp)
 778:	f06a                	sd	s10,32(sp)
 77a:	ec6e                	sd	s11,24(sp)
 77c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 77e:	0005c903          	lbu	s2,0(a1)
 782:	18090f63          	beqz	s2,920 <vprintf+0x1c0>
 786:	8aaa                	mv	s5,a0
 788:	8b32                	mv	s6,a2
 78a:	00158493          	addi	s1,a1,1
  state = 0;
 78e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 790:	02500a13          	li	s4,37
      if(c == 'd'){
 794:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 798:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 79c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 7a0:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7a4:	00000b97          	auipc	s7,0x0
 7a8:	4e4b8b93          	addi	s7,s7,1252 # c88 <digits>
 7ac:	a839                	j	7ca <vprintf+0x6a>
        putc(fd, c);
 7ae:	85ca                	mv	a1,s2
 7b0:	8556                	mv	a0,s5
 7b2:	00000097          	auipc	ra,0x0
 7b6:	ee2080e7          	jalr	-286(ra) # 694 <putc>
 7ba:	a019                	j	7c0 <vprintf+0x60>
    } else if(state == '%'){
 7bc:	01498f63          	beq	s3,s4,7da <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 7c0:	0485                	addi	s1,s1,1
 7c2:	fff4c903          	lbu	s2,-1(s1)
 7c6:	14090d63          	beqz	s2,920 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 7ca:	0009079b          	sext.w	a5,s2
    if(state == 0){
 7ce:	fe0997e3          	bnez	s3,7bc <vprintf+0x5c>
      if(c == '%'){
 7d2:	fd479ee3          	bne	a5,s4,7ae <vprintf+0x4e>
        state = '%';
 7d6:	89be                	mv	s3,a5
 7d8:	b7e5                	j	7c0 <vprintf+0x60>
      if(c == 'd'){
 7da:	05878063          	beq	a5,s8,81a <vprintf+0xba>
      } else if(c == 'l') {
 7de:	05978c63          	beq	a5,s9,836 <vprintf+0xd6>
      } else if(c == 'x') {
 7e2:	07a78863          	beq	a5,s10,852 <vprintf+0xf2>
      } else if(c == 'p') {
 7e6:	09b78463          	beq	a5,s11,86e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7ea:	07300713          	li	a4,115
 7ee:	0ce78663          	beq	a5,a4,8ba <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7f2:	06300713          	li	a4,99
 7f6:	0ee78e63          	beq	a5,a4,8f2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7fa:	11478863          	beq	a5,s4,90a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7fe:	85d2                	mv	a1,s4
 800:	8556                	mv	a0,s5
 802:	00000097          	auipc	ra,0x0
 806:	e92080e7          	jalr	-366(ra) # 694 <putc>
        putc(fd, c);
 80a:	85ca                	mv	a1,s2
 80c:	8556                	mv	a0,s5
 80e:	00000097          	auipc	ra,0x0
 812:	e86080e7          	jalr	-378(ra) # 694 <putc>
      }
      state = 0;
 816:	4981                	li	s3,0
 818:	b765                	j	7c0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 81a:	008b0913          	addi	s2,s6,8
 81e:	4685                	li	a3,1
 820:	4629                	li	a2,10
 822:	000b2583          	lw	a1,0(s6)
 826:	8556                	mv	a0,s5
 828:	00000097          	auipc	ra,0x0
 82c:	e8e080e7          	jalr	-370(ra) # 6b6 <printint>
 830:	8b4a                	mv	s6,s2
      state = 0;
 832:	4981                	li	s3,0
 834:	b771                	j	7c0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 836:	008b0913          	addi	s2,s6,8
 83a:	4681                	li	a3,0
 83c:	4629                	li	a2,10
 83e:	000b2583          	lw	a1,0(s6)
 842:	8556                	mv	a0,s5
 844:	00000097          	auipc	ra,0x0
 848:	e72080e7          	jalr	-398(ra) # 6b6 <printint>
 84c:	8b4a                	mv	s6,s2
      state = 0;
 84e:	4981                	li	s3,0
 850:	bf85                	j	7c0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 852:	008b0913          	addi	s2,s6,8
 856:	4681                	li	a3,0
 858:	4641                	li	a2,16
 85a:	000b2583          	lw	a1,0(s6)
 85e:	8556                	mv	a0,s5
 860:	00000097          	auipc	ra,0x0
 864:	e56080e7          	jalr	-426(ra) # 6b6 <printint>
 868:	8b4a                	mv	s6,s2
      state = 0;
 86a:	4981                	li	s3,0
 86c:	bf91                	j	7c0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 86e:	008b0793          	addi	a5,s6,8
 872:	f8f43423          	sd	a5,-120(s0)
 876:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 87a:	03000593          	li	a1,48
 87e:	8556                	mv	a0,s5
 880:	00000097          	auipc	ra,0x0
 884:	e14080e7          	jalr	-492(ra) # 694 <putc>
  putc(fd, 'x');
 888:	85ea                	mv	a1,s10
 88a:	8556                	mv	a0,s5
 88c:	00000097          	auipc	ra,0x0
 890:	e08080e7          	jalr	-504(ra) # 694 <putc>
 894:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 896:	03c9d793          	srli	a5,s3,0x3c
 89a:	97de                	add	a5,a5,s7
 89c:	0007c583          	lbu	a1,0(a5)
 8a0:	8556                	mv	a0,s5
 8a2:	00000097          	auipc	ra,0x0
 8a6:	df2080e7          	jalr	-526(ra) # 694 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8aa:	0992                	slli	s3,s3,0x4
 8ac:	397d                	addiw	s2,s2,-1
 8ae:	fe0914e3          	bnez	s2,896 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 8b2:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 8b6:	4981                	li	s3,0
 8b8:	b721                	j	7c0 <vprintf+0x60>
        s = va_arg(ap, char*);
 8ba:	008b0993          	addi	s3,s6,8
 8be:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 8c2:	02090163          	beqz	s2,8e4 <vprintf+0x184>
        while(*s != 0){
 8c6:	00094583          	lbu	a1,0(s2)
 8ca:	c9a1                	beqz	a1,91a <vprintf+0x1ba>
          putc(fd, *s);
 8cc:	8556                	mv	a0,s5
 8ce:	00000097          	auipc	ra,0x0
 8d2:	dc6080e7          	jalr	-570(ra) # 694 <putc>
          s++;
 8d6:	0905                	addi	s2,s2,1
        while(*s != 0){
 8d8:	00094583          	lbu	a1,0(s2)
 8dc:	f9e5                	bnez	a1,8cc <vprintf+0x16c>
        s = va_arg(ap, char*);
 8de:	8b4e                	mv	s6,s3
      state = 0;
 8e0:	4981                	li	s3,0
 8e2:	bdf9                	j	7c0 <vprintf+0x60>
          s = "(null)";
 8e4:	00000917          	auipc	s2,0x0
 8e8:	39c90913          	addi	s2,s2,924 # c80 <malloc+0x256>
        while(*s != 0){
 8ec:	02800593          	li	a1,40
 8f0:	bff1                	j	8cc <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 8f2:	008b0913          	addi	s2,s6,8
 8f6:	000b4583          	lbu	a1,0(s6)
 8fa:	8556                	mv	a0,s5
 8fc:	00000097          	auipc	ra,0x0
 900:	d98080e7          	jalr	-616(ra) # 694 <putc>
 904:	8b4a                	mv	s6,s2
      state = 0;
 906:	4981                	li	s3,0
 908:	bd65                	j	7c0 <vprintf+0x60>
        putc(fd, c);
 90a:	85d2                	mv	a1,s4
 90c:	8556                	mv	a0,s5
 90e:	00000097          	auipc	ra,0x0
 912:	d86080e7          	jalr	-634(ra) # 694 <putc>
      state = 0;
 916:	4981                	li	s3,0
 918:	b565                	j	7c0 <vprintf+0x60>
        s = va_arg(ap, char*);
 91a:	8b4e                	mv	s6,s3
      state = 0;
 91c:	4981                	li	s3,0
 91e:	b54d                	j	7c0 <vprintf+0x60>
    }
  }
}
 920:	70e6                	ld	ra,120(sp)
 922:	7446                	ld	s0,112(sp)
 924:	74a6                	ld	s1,104(sp)
 926:	7906                	ld	s2,96(sp)
 928:	69e6                	ld	s3,88(sp)
 92a:	6a46                	ld	s4,80(sp)
 92c:	6aa6                	ld	s5,72(sp)
 92e:	6b06                	ld	s6,64(sp)
 930:	7be2                	ld	s7,56(sp)
 932:	7c42                	ld	s8,48(sp)
 934:	7ca2                	ld	s9,40(sp)
 936:	7d02                	ld	s10,32(sp)
 938:	6de2                	ld	s11,24(sp)
 93a:	6109                	addi	sp,sp,128
 93c:	8082                	ret

000000000000093e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 93e:	715d                	addi	sp,sp,-80
 940:	ec06                	sd	ra,24(sp)
 942:	e822                	sd	s0,16(sp)
 944:	1000                	addi	s0,sp,32
 946:	e010                	sd	a2,0(s0)
 948:	e414                	sd	a3,8(s0)
 94a:	e818                	sd	a4,16(s0)
 94c:	ec1c                	sd	a5,24(s0)
 94e:	03043023          	sd	a6,32(s0)
 952:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 956:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 95a:	8622                	mv	a2,s0
 95c:	00000097          	auipc	ra,0x0
 960:	e04080e7          	jalr	-508(ra) # 760 <vprintf>
}
 964:	60e2                	ld	ra,24(sp)
 966:	6442                	ld	s0,16(sp)
 968:	6161                	addi	sp,sp,80
 96a:	8082                	ret

000000000000096c <printf>:

void
printf(const char *fmt, ...)
{
 96c:	711d                	addi	sp,sp,-96
 96e:	ec06                	sd	ra,24(sp)
 970:	e822                	sd	s0,16(sp)
 972:	1000                	addi	s0,sp,32
 974:	e40c                	sd	a1,8(s0)
 976:	e810                	sd	a2,16(s0)
 978:	ec14                	sd	a3,24(s0)
 97a:	f018                	sd	a4,32(s0)
 97c:	f41c                	sd	a5,40(s0)
 97e:	03043823          	sd	a6,48(s0)
 982:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 986:	00840613          	addi	a2,s0,8
 98a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 98e:	85aa                	mv	a1,a0
 990:	4505                	li	a0,1
 992:	00000097          	auipc	ra,0x0
 996:	dce080e7          	jalr	-562(ra) # 760 <vprintf>
}
 99a:	60e2                	ld	ra,24(sp)
 99c:	6442                	ld	s0,16(sp)
 99e:	6125                	addi	sp,sp,96
 9a0:	8082                	ret

00000000000009a2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9a2:	1141                	addi	sp,sp,-16
 9a4:	e422                	sd	s0,8(sp)
 9a6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9a8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ac:	00000797          	auipc	a5,0x0
 9b0:	2f47b783          	ld	a5,756(a5) # ca0 <freep>
 9b4:	a805                	j	9e4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9b6:	4618                	lw	a4,8(a2)
 9b8:	9db9                	addw	a1,a1,a4
 9ba:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9be:	6398                	ld	a4,0(a5)
 9c0:	6318                	ld	a4,0(a4)
 9c2:	fee53823          	sd	a4,-16(a0)
 9c6:	a091                	j	a0a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9c8:	ff852703          	lw	a4,-8(a0)
 9cc:	9e39                	addw	a2,a2,a4
 9ce:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 9d0:	ff053703          	ld	a4,-16(a0)
 9d4:	e398                	sd	a4,0(a5)
 9d6:	a099                	j	a1c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9d8:	6398                	ld	a4,0(a5)
 9da:	00e7e463          	bltu	a5,a4,9e2 <free+0x40>
 9de:	00e6ea63          	bltu	a3,a4,9f2 <free+0x50>
{
 9e2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9e4:	fed7fae3          	bgeu	a5,a3,9d8 <free+0x36>
 9e8:	6398                	ld	a4,0(a5)
 9ea:	00e6e463          	bltu	a3,a4,9f2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ee:	fee7eae3          	bltu	a5,a4,9e2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9f2:	ff852583          	lw	a1,-8(a0)
 9f6:	6390                	ld	a2,0(a5)
 9f8:	02059713          	slli	a4,a1,0x20
 9fc:	9301                	srli	a4,a4,0x20
 9fe:	0712                	slli	a4,a4,0x4
 a00:	9736                	add	a4,a4,a3
 a02:	fae60ae3          	beq	a2,a4,9b6 <free+0x14>
    bp->s.ptr = p->s.ptr;
 a06:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a0a:	4790                	lw	a2,8(a5)
 a0c:	02061713          	slli	a4,a2,0x20
 a10:	9301                	srli	a4,a4,0x20
 a12:	0712                	slli	a4,a4,0x4
 a14:	973e                	add	a4,a4,a5
 a16:	fae689e3          	beq	a3,a4,9c8 <free+0x26>
  } else
    p->s.ptr = bp;
 a1a:	e394                	sd	a3,0(a5)
  freep = p;
 a1c:	00000717          	auipc	a4,0x0
 a20:	28f73223          	sd	a5,644(a4) # ca0 <freep>
}
 a24:	6422                	ld	s0,8(sp)
 a26:	0141                	addi	sp,sp,16
 a28:	8082                	ret

0000000000000a2a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a2a:	7139                	addi	sp,sp,-64
 a2c:	fc06                	sd	ra,56(sp)
 a2e:	f822                	sd	s0,48(sp)
 a30:	f426                	sd	s1,40(sp)
 a32:	f04a                	sd	s2,32(sp)
 a34:	ec4e                	sd	s3,24(sp)
 a36:	e852                	sd	s4,16(sp)
 a38:	e456                	sd	s5,8(sp)
 a3a:	e05a                	sd	s6,0(sp)
 a3c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a3e:	02051493          	slli	s1,a0,0x20
 a42:	9081                	srli	s1,s1,0x20
 a44:	04bd                	addi	s1,s1,15
 a46:	8091                	srli	s1,s1,0x4
 a48:	0014899b          	addiw	s3,s1,1
 a4c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a4e:	00000517          	auipc	a0,0x0
 a52:	25253503          	ld	a0,594(a0) # ca0 <freep>
 a56:	c515                	beqz	a0,a82 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a58:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a5a:	4798                	lw	a4,8(a5)
 a5c:	02977f63          	bgeu	a4,s1,a9a <malloc+0x70>
 a60:	8a4e                	mv	s4,s3
 a62:	0009871b          	sext.w	a4,s3
 a66:	6685                	lui	a3,0x1
 a68:	00d77363          	bgeu	a4,a3,a6e <malloc+0x44>
 a6c:	6a05                	lui	s4,0x1
 a6e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a72:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a76:	00000917          	auipc	s2,0x0
 a7a:	22a90913          	addi	s2,s2,554 # ca0 <freep>
  if(p == (char*)-1)
 a7e:	5afd                	li	s5,-1
 a80:	a88d                	j	af2 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 a82:	00001797          	auipc	a5,0x1
 a86:	86678793          	addi	a5,a5,-1946 # 12e8 <base>
 a8a:	00000717          	auipc	a4,0x0
 a8e:	20f73b23          	sd	a5,534(a4) # ca0 <freep>
 a92:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a94:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a98:	b7e1                	j	a60 <malloc+0x36>
      if(p->s.size == nunits)
 a9a:	02e48b63          	beq	s1,a4,ad0 <malloc+0xa6>
        p->s.size -= nunits;
 a9e:	4137073b          	subw	a4,a4,s3
 aa2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 aa4:	1702                	slli	a4,a4,0x20
 aa6:	9301                	srli	a4,a4,0x20
 aa8:	0712                	slli	a4,a4,0x4
 aaa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 aac:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ab0:	00000717          	auipc	a4,0x0
 ab4:	1ea73823          	sd	a0,496(a4) # ca0 <freep>
      return (void*)(p + 1);
 ab8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 abc:	70e2                	ld	ra,56(sp)
 abe:	7442                	ld	s0,48(sp)
 ac0:	74a2                	ld	s1,40(sp)
 ac2:	7902                	ld	s2,32(sp)
 ac4:	69e2                	ld	s3,24(sp)
 ac6:	6a42                	ld	s4,16(sp)
 ac8:	6aa2                	ld	s5,8(sp)
 aca:	6b02                	ld	s6,0(sp)
 acc:	6121                	addi	sp,sp,64
 ace:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 ad0:	6398                	ld	a4,0(a5)
 ad2:	e118                	sd	a4,0(a0)
 ad4:	bff1                	j	ab0 <malloc+0x86>
  hp->s.size = nu;
 ad6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ada:	0541                	addi	a0,a0,16
 adc:	00000097          	auipc	ra,0x0
 ae0:	ec6080e7          	jalr	-314(ra) # 9a2 <free>
  return freep;
 ae4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ae8:	d971                	beqz	a0,abc <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aec:	4798                	lw	a4,8(a5)
 aee:	fa9776e3          	bgeu	a4,s1,a9a <malloc+0x70>
    if(p == freep)
 af2:	00093703          	ld	a4,0(s2)
 af6:	853e                	mv	a0,a5
 af8:	fef719e3          	bne	a4,a5,aea <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 afc:	8552                	mv	a0,s4
 afe:	00000097          	auipc	ra,0x0
 b02:	b66080e7          	jalr	-1178(ra) # 664 <sbrk>
  if(p == (char*)-1)
 b06:	fd5518e3          	bne	a0,s5,ad6 <malloc+0xac>
        return 0;
 b0a:	4501                	li	a0,0
 b0c:	bf45                	j	abc <malloc+0x92>
