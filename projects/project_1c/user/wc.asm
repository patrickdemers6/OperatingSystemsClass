
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:
#include "user/user.h"

char buf[512];

void wc(int fd, char *name)
{
   0:	7175                	addi	sp,sp,-144
   2:	e506                	sd	ra,136(sp)
   4:	e122                	sd	s0,128(sp)
   6:	fca6                	sd	s1,120(sp)
   8:	f8ca                	sd	s2,112(sp)
   a:	f4ce                	sd	s3,104(sp)
   c:	f0d2                	sd	s4,96(sp)
   e:	ecd6                	sd	s5,88(sp)
  10:	e8da                	sd	s6,80(sp)
  12:	e4de                	sd	s7,72(sp)
  14:	e0e2                	sd	s8,64(sp)
  16:	fc66                	sd	s9,56(sp)
  18:	f86a                	sd	s10,48(sp)
  1a:	f46e                	sd	s11,40(sp)
  1c:	0900                	addi	s0,sp,144
  1e:	f8a43023          	sd	a0,-128(s0)
  22:	f6b43c23          	sd	a1,-136(s0)
  int i, n;
  int l, w, c, v, inword;

  l = w = c = v = 0;
  inword = 0;
  26:	4a81                	li	s5,0
  l = w = c = v = 0;
  28:	4a01                	li	s4,0
  2a:	4d81                	li	s11,0
  2c:	4d01                	li	s10,0
  2e:	4c81                	li	s9,0
      c++;
      if (buf[i] == '\n')
        l++;

      // addition: count occurences of vowels
      if (strchr("aeiouAEIOU", buf[i]))
  30:	00001c17          	auipc	s8,0x1
  34:	948c0c13          	addi	s8,s8,-1720 # 978 <malloc+0xe6>
      {
        v++;
      }
      if (strchr(" \r\t\n\v", buf[i]))
  38:	00001b97          	auipc	s7,0x1
  3c:	950b8b93          	addi	s7,s7,-1712 # 988 <malloc+0xf6>
  while ((n = read(fd, buf, sizeof(buf))) > 0)
  40:	a0a1                	j	88 <wc+0x88>
      if (strchr("aeiouAEIOU", buf[i]))
  42:	8562                	mv	a0,s8
  44:	00000097          	auipc	ra,0x0
  48:	226080e7          	jalr	550(ra) # 26a <strchr>
  4c:	c111                	beqz	a0,50 <wc+0x50>
        v++;
  4e:	2a05                	addiw	s4,s4,1
      if (strchr(" \r\t\n\v", buf[i]))
  50:	0009c583          	lbu	a1,0(s3)
  54:	855e                	mv	a0,s7
  56:	00000097          	auipc	ra,0x0
  5a:	214080e7          	jalr	532(ra) # 26a <strchr>
  5e:	cd01                	beqz	a0,76 <wc+0x76>
        inword = 0;
  60:	4a81                	li	s5,0
    for (i = 0; i < n; i++)
  62:	0485                	addi	s1,s1,1
  64:	01248e63          	beq	s1,s2,80 <wc+0x80>
      if (buf[i] == '\n')
  68:	89a6                	mv	s3,s1
  6a:	0004c583          	lbu	a1,0(s1)
  6e:	fd659ae3          	bne	a1,s6,42 <wc+0x42>
        l++;
  72:	2c85                	addiw	s9,s9,1
  74:	b7f9                	j	42 <wc+0x42>
      else if (!inword)
  76:	fe0a96e3          	bnez	s5,62 <wc+0x62>
      {
        w++;
  7a:	2d05                	addiw	s10,s10,1
        inword = 1;
  7c:	4a85                	li	s5,1
  7e:	b7d5                	j	62 <wc+0x62>
      c++;
  80:	f8843783          	ld	a5,-120(s0)
  84:	00fd8dbb          	addw	s11,s11,a5
  while ((n = read(fd, buf, sizeof(buf))) > 0)
  88:	20000613          	li	a2,512
  8c:	00001597          	auipc	a1,0x1
  90:	96c58593          	addi	a1,a1,-1684 # 9f8 <buf>
  94:	f8043503          	ld	a0,-128(s0)
  98:	00000097          	auipc	ra,0x0
  9c:	3c4080e7          	jalr	964(ra) # 45c <read>
  a0:	02a05663          	blez	a0,cc <wc+0xcc>
    for (i = 0; i < n; i++)
  a4:	00001497          	auipc	s1,0x1
  a8:	95448493          	addi	s1,s1,-1708 # 9f8 <buf>
  ac:	0005079b          	sext.w	a5,a0
  b0:	f8f43423          	sd	a5,-120(s0)
  b4:	fff5091b          	addiw	s2,a0,-1
  b8:	1902                	slli	s2,s2,0x20
  ba:	02095913          	srli	s2,s2,0x20
  be:	00001797          	auipc	a5,0x1
  c2:	93b78793          	addi	a5,a5,-1733 # 9f9 <buf+0x1>
  c6:	993e                	add	s2,s2,a5
      if (buf[i] == '\n')
  c8:	4b29                	li	s6,10
  ca:	bf79                	j	68 <wc+0x68>
      }
    }
  }
  if (n < 0)
  cc:	02054f63          	bltz	a0,10a <wc+0x10a>
    printf("wc: read error\n");
    exit(1);
  }

  // modification: print vowel count before file name
  printf("%d %d %d %d %s\n", l, w, c, v, name);
  d0:	f7843783          	ld	a5,-136(s0)
  d4:	8752                	mv	a4,s4
  d6:	86ee                	mv	a3,s11
  d8:	866a                	mv	a2,s10
  da:	85e6                	mv	a1,s9
  dc:	00001517          	auipc	a0,0x1
  e0:	8c450513          	addi	a0,a0,-1852 # 9a0 <malloc+0x10e>
  e4:	00000097          	auipc	ra,0x0
  e8:	6f0080e7          	jalr	1776(ra) # 7d4 <printf>
}
  ec:	60aa                	ld	ra,136(sp)
  ee:	640a                	ld	s0,128(sp)
  f0:	74e6                	ld	s1,120(sp)
  f2:	7946                	ld	s2,112(sp)
  f4:	79a6                	ld	s3,104(sp)
  f6:	7a06                	ld	s4,96(sp)
  f8:	6ae6                	ld	s5,88(sp)
  fa:	6b46                	ld	s6,80(sp)
  fc:	6ba6                	ld	s7,72(sp)
  fe:	6c06                	ld	s8,64(sp)
 100:	7ce2                	ld	s9,56(sp)
 102:	7d42                	ld	s10,48(sp)
 104:	7da2                	ld	s11,40(sp)
 106:	6149                	addi	sp,sp,144
 108:	8082                	ret
    printf("wc: read error\n");
 10a:	00001517          	auipc	a0,0x1
 10e:	88650513          	addi	a0,a0,-1914 # 990 <malloc+0xfe>
 112:	00000097          	auipc	ra,0x0
 116:	6c2080e7          	jalr	1730(ra) # 7d4 <printf>
    exit(1);
 11a:	4505                	li	a0,1
 11c:	00000097          	auipc	ra,0x0
 120:	328080e7          	jalr	808(ra) # 444 <exit>

0000000000000124 <main>:

int main(int argc, char *argv[])
{
 124:	7179                	addi	sp,sp,-48
 126:	f406                	sd	ra,40(sp)
 128:	f022                	sd	s0,32(sp)
 12a:	ec26                	sd	s1,24(sp)
 12c:	e84a                	sd	s2,16(sp)
 12e:	e44e                	sd	s3,8(sp)
 130:	e052                	sd	s4,0(sp)
 132:	1800                	addi	s0,sp,48
  int fd, i;

  if (argc <= 1)
 134:	4785                	li	a5,1
 136:	04a7d763          	bge	a5,a0,184 <main+0x60>
 13a:	00858493          	addi	s1,a1,8
 13e:	ffe5099b          	addiw	s3,a0,-2
 142:	1982                	slli	s3,s3,0x20
 144:	0209d993          	srli	s3,s3,0x20
 148:	098e                	slli	s3,s3,0x3
 14a:	05c1                	addi	a1,a1,16
 14c:	99ae                	add	s3,s3,a1
    exit(0);
  }

  for (i = 1; i < argc; i++)
  {
    if ((fd = open(argv[i], 0)) < 0)
 14e:	4581                	li	a1,0
 150:	6088                	ld	a0,0(s1)
 152:	00000097          	auipc	ra,0x0
 156:	332080e7          	jalr	818(ra) # 484 <open>
 15a:	892a                	mv	s2,a0
 15c:	04054263          	bltz	a0,1a0 <main+0x7c>
    {
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 160:	608c                	ld	a1,0(s1)
 162:	00000097          	auipc	ra,0x0
 166:	e9e080e7          	jalr	-354(ra) # 0 <wc>
    close(fd);
 16a:	854a                	mv	a0,s2
 16c:	00000097          	auipc	ra,0x0
 170:	300080e7          	jalr	768(ra) # 46c <close>
  for (i = 1; i < argc; i++)
 174:	04a1                	addi	s1,s1,8
 176:	fd349ce3          	bne	s1,s3,14e <main+0x2a>
  }
  exit(0);
 17a:	4501                	li	a0,0
 17c:	00000097          	auipc	ra,0x0
 180:	2c8080e7          	jalr	712(ra) # 444 <exit>
    wc(0, "");
 184:	00001597          	auipc	a1,0x1
 188:	82c58593          	addi	a1,a1,-2004 # 9b0 <malloc+0x11e>
 18c:	4501                	li	a0,0
 18e:	00000097          	auipc	ra,0x0
 192:	e72080e7          	jalr	-398(ra) # 0 <wc>
    exit(0);
 196:	4501                	li	a0,0
 198:	00000097          	auipc	ra,0x0
 19c:	2ac080e7          	jalr	684(ra) # 444 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 1a0:	608c                	ld	a1,0(s1)
 1a2:	00001517          	auipc	a0,0x1
 1a6:	81650513          	addi	a0,a0,-2026 # 9b8 <malloc+0x126>
 1aa:	00000097          	auipc	ra,0x0
 1ae:	62a080e7          	jalr	1578(ra) # 7d4 <printf>
      exit(1);
 1b2:	4505                	li	a0,1
 1b4:	00000097          	auipc	ra,0x0
 1b8:	290080e7          	jalr	656(ra) # 444 <exit>

00000000000001bc <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1bc:	1141                	addi	sp,sp,-16
 1be:	e406                	sd	ra,8(sp)
 1c0:	e022                	sd	s0,0(sp)
 1c2:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1c4:	00000097          	auipc	ra,0x0
 1c8:	f60080e7          	jalr	-160(ra) # 124 <main>
  exit(0);
 1cc:	4501                	li	a0,0
 1ce:	00000097          	auipc	ra,0x0
 1d2:	276080e7          	jalr	630(ra) # 444 <exit>

00000000000001d6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1dc:	87aa                	mv	a5,a0
 1de:	0585                	addi	a1,a1,1
 1e0:	0785                	addi	a5,a5,1
 1e2:	fff5c703          	lbu	a4,-1(a1)
 1e6:	fee78fa3          	sb	a4,-1(a5)
 1ea:	fb75                	bnez	a4,1de <strcpy+0x8>
    ;
  return os;
}
 1ec:	6422                	ld	s0,8(sp)
 1ee:	0141                	addi	sp,sp,16
 1f0:	8082                	ret

00000000000001f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1f8:	00054783          	lbu	a5,0(a0)
 1fc:	cb91                	beqz	a5,210 <strcmp+0x1e>
 1fe:	0005c703          	lbu	a4,0(a1)
 202:	00f71763          	bne	a4,a5,210 <strcmp+0x1e>
    p++, q++;
 206:	0505                	addi	a0,a0,1
 208:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 20a:	00054783          	lbu	a5,0(a0)
 20e:	fbe5                	bnez	a5,1fe <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 210:	0005c503          	lbu	a0,0(a1)
}
 214:	40a7853b          	subw	a0,a5,a0
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	addi	sp,sp,16
 21c:	8082                	ret

000000000000021e <strlen>:

uint
strlen(const char *s)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e422                	sd	s0,8(sp)
 222:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 224:	00054783          	lbu	a5,0(a0)
 228:	cf91                	beqz	a5,244 <strlen+0x26>
 22a:	0505                	addi	a0,a0,1
 22c:	87aa                	mv	a5,a0
 22e:	4685                	li	a3,1
 230:	9e89                	subw	a3,a3,a0
 232:	00f6853b          	addw	a0,a3,a5
 236:	0785                	addi	a5,a5,1
 238:	fff7c703          	lbu	a4,-1(a5)
 23c:	fb7d                	bnez	a4,232 <strlen+0x14>
    ;
  return n;
}
 23e:	6422                	ld	s0,8(sp)
 240:	0141                	addi	sp,sp,16
 242:	8082                	ret
  for(n = 0; s[n]; n++)
 244:	4501                	li	a0,0
 246:	bfe5                	j	23e <strlen+0x20>

0000000000000248 <memset>:

void*
memset(void *dst, int c, uint n)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 24e:	ca19                	beqz	a2,264 <memset+0x1c>
 250:	87aa                	mv	a5,a0
 252:	1602                	slli	a2,a2,0x20
 254:	9201                	srli	a2,a2,0x20
 256:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 25a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 25e:	0785                	addi	a5,a5,1
 260:	fee79de3          	bne	a5,a4,25a <memset+0x12>
  }
  return dst;
}
 264:	6422                	ld	s0,8(sp)
 266:	0141                	addi	sp,sp,16
 268:	8082                	ret

000000000000026a <strchr>:

char*
strchr(const char *s, char c)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 270:	00054783          	lbu	a5,0(a0)
 274:	cb99                	beqz	a5,28a <strchr+0x20>
    if(*s == c)
 276:	00f58763          	beq	a1,a5,284 <strchr+0x1a>
  for(; *s; s++)
 27a:	0505                	addi	a0,a0,1
 27c:	00054783          	lbu	a5,0(a0)
 280:	fbfd                	bnez	a5,276 <strchr+0xc>
      return (char*)s;
  return 0;
 282:	4501                	li	a0,0
}
 284:	6422                	ld	s0,8(sp)
 286:	0141                	addi	sp,sp,16
 288:	8082                	ret
  return 0;
 28a:	4501                	li	a0,0
 28c:	bfe5                	j	284 <strchr+0x1a>

000000000000028e <gets>:

char*
gets(char *buf, int max)
{
 28e:	711d                	addi	sp,sp,-96
 290:	ec86                	sd	ra,88(sp)
 292:	e8a2                	sd	s0,80(sp)
 294:	e4a6                	sd	s1,72(sp)
 296:	e0ca                	sd	s2,64(sp)
 298:	fc4e                	sd	s3,56(sp)
 29a:	f852                	sd	s4,48(sp)
 29c:	f456                	sd	s5,40(sp)
 29e:	f05a                	sd	s6,32(sp)
 2a0:	ec5e                	sd	s7,24(sp)
 2a2:	1080                	addi	s0,sp,96
 2a4:	8baa                	mv	s7,a0
 2a6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2a8:	892a                	mv	s2,a0
 2aa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ac:	4aa9                	li	s5,10
 2ae:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2b0:	89a6                	mv	s3,s1
 2b2:	2485                	addiw	s1,s1,1
 2b4:	0344d863          	bge	s1,s4,2e4 <gets+0x56>
    cc = read(0, &c, 1);
 2b8:	4605                	li	a2,1
 2ba:	faf40593          	addi	a1,s0,-81
 2be:	4501                	li	a0,0
 2c0:	00000097          	auipc	ra,0x0
 2c4:	19c080e7          	jalr	412(ra) # 45c <read>
    if(cc < 1)
 2c8:	00a05e63          	blez	a0,2e4 <gets+0x56>
    buf[i++] = c;
 2cc:	faf44783          	lbu	a5,-81(s0)
 2d0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2d4:	01578763          	beq	a5,s5,2e2 <gets+0x54>
 2d8:	0905                	addi	s2,s2,1
 2da:	fd679be3          	bne	a5,s6,2b0 <gets+0x22>
  for(i=0; i+1 < max; ){
 2de:	89a6                	mv	s3,s1
 2e0:	a011                	j	2e4 <gets+0x56>
 2e2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2e4:	99de                	add	s3,s3,s7
 2e6:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ea:	855e                	mv	a0,s7
 2ec:	60e6                	ld	ra,88(sp)
 2ee:	6446                	ld	s0,80(sp)
 2f0:	64a6                	ld	s1,72(sp)
 2f2:	6906                	ld	s2,64(sp)
 2f4:	79e2                	ld	s3,56(sp)
 2f6:	7a42                	ld	s4,48(sp)
 2f8:	7aa2                	ld	s5,40(sp)
 2fa:	7b02                	ld	s6,32(sp)
 2fc:	6be2                	ld	s7,24(sp)
 2fe:	6125                	addi	sp,sp,96
 300:	8082                	ret

0000000000000302 <stat>:

int
stat(const char *n, struct stat *st)
{
 302:	1101                	addi	sp,sp,-32
 304:	ec06                	sd	ra,24(sp)
 306:	e822                	sd	s0,16(sp)
 308:	e426                	sd	s1,8(sp)
 30a:	e04a                	sd	s2,0(sp)
 30c:	1000                	addi	s0,sp,32
 30e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 310:	4581                	li	a1,0
 312:	00000097          	auipc	ra,0x0
 316:	172080e7          	jalr	370(ra) # 484 <open>
  if(fd < 0)
 31a:	02054563          	bltz	a0,344 <stat+0x42>
 31e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 320:	85ca                	mv	a1,s2
 322:	00000097          	auipc	ra,0x0
 326:	17a080e7          	jalr	378(ra) # 49c <fstat>
 32a:	892a                	mv	s2,a0
  close(fd);
 32c:	8526                	mv	a0,s1
 32e:	00000097          	auipc	ra,0x0
 332:	13e080e7          	jalr	318(ra) # 46c <close>
  return r;
}
 336:	854a                	mv	a0,s2
 338:	60e2                	ld	ra,24(sp)
 33a:	6442                	ld	s0,16(sp)
 33c:	64a2                	ld	s1,8(sp)
 33e:	6902                	ld	s2,0(sp)
 340:	6105                	addi	sp,sp,32
 342:	8082                	ret
    return -1;
 344:	597d                	li	s2,-1
 346:	bfc5                	j	336 <stat+0x34>

0000000000000348 <atoi>:

int
atoi(const char *s)
{
 348:	1141                	addi	sp,sp,-16
 34a:	e422                	sd	s0,8(sp)
 34c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 34e:	00054603          	lbu	a2,0(a0)
 352:	fd06079b          	addiw	a5,a2,-48
 356:	0ff7f793          	andi	a5,a5,255
 35a:	4725                	li	a4,9
 35c:	02f76963          	bltu	a4,a5,38e <atoi+0x46>
 360:	86aa                	mv	a3,a0
  n = 0;
 362:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 364:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 366:	0685                	addi	a3,a3,1
 368:	0025179b          	slliw	a5,a0,0x2
 36c:	9fa9                	addw	a5,a5,a0
 36e:	0017979b          	slliw	a5,a5,0x1
 372:	9fb1                	addw	a5,a5,a2
 374:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 378:	0006c603          	lbu	a2,0(a3)
 37c:	fd06071b          	addiw	a4,a2,-48
 380:	0ff77713          	andi	a4,a4,255
 384:	fee5f1e3          	bgeu	a1,a4,366 <atoi+0x1e>
  return n;
}
 388:	6422                	ld	s0,8(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret
  n = 0;
 38e:	4501                	li	a0,0
 390:	bfe5                	j	388 <atoi+0x40>

0000000000000392 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 392:	1141                	addi	sp,sp,-16
 394:	e422                	sd	s0,8(sp)
 396:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 398:	02b57463          	bgeu	a0,a1,3c0 <memmove+0x2e>
    while(n-- > 0)
 39c:	00c05f63          	blez	a2,3ba <memmove+0x28>
 3a0:	1602                	slli	a2,a2,0x20
 3a2:	9201                	srli	a2,a2,0x20
 3a4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3a8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3aa:	0585                	addi	a1,a1,1
 3ac:	0705                	addi	a4,a4,1
 3ae:	fff5c683          	lbu	a3,-1(a1)
 3b2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3b6:	fee79ae3          	bne	a5,a4,3aa <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3ba:	6422                	ld	s0,8(sp)
 3bc:	0141                	addi	sp,sp,16
 3be:	8082                	ret
    dst += n;
 3c0:	00c50733          	add	a4,a0,a2
    src += n;
 3c4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3c6:	fec05ae3          	blez	a2,3ba <memmove+0x28>
 3ca:	fff6079b          	addiw	a5,a2,-1
 3ce:	1782                	slli	a5,a5,0x20
 3d0:	9381                	srli	a5,a5,0x20
 3d2:	fff7c793          	not	a5,a5
 3d6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3d8:	15fd                	addi	a1,a1,-1
 3da:	177d                	addi	a4,a4,-1
 3dc:	0005c683          	lbu	a3,0(a1)
 3e0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3e4:	fee79ae3          	bne	a5,a4,3d8 <memmove+0x46>
 3e8:	bfc9                	j	3ba <memmove+0x28>

00000000000003ea <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ea:	1141                	addi	sp,sp,-16
 3ec:	e422                	sd	s0,8(sp)
 3ee:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f0:	ca05                	beqz	a2,420 <memcmp+0x36>
 3f2:	fff6069b          	addiw	a3,a2,-1
 3f6:	1682                	slli	a3,a3,0x20
 3f8:	9281                	srli	a3,a3,0x20
 3fa:	0685                	addi	a3,a3,1
 3fc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3fe:	00054783          	lbu	a5,0(a0)
 402:	0005c703          	lbu	a4,0(a1)
 406:	00e79863          	bne	a5,a4,416 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 40a:	0505                	addi	a0,a0,1
    p2++;
 40c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 40e:	fed518e3          	bne	a0,a3,3fe <memcmp+0x14>
  }
  return 0;
 412:	4501                	li	a0,0
 414:	a019                	j	41a <memcmp+0x30>
      return *p1 - *p2;
 416:	40e7853b          	subw	a0,a5,a4
}
 41a:	6422                	ld	s0,8(sp)
 41c:	0141                	addi	sp,sp,16
 41e:	8082                	ret
  return 0;
 420:	4501                	li	a0,0
 422:	bfe5                	j	41a <memcmp+0x30>

0000000000000424 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 424:	1141                	addi	sp,sp,-16
 426:	e406                	sd	ra,8(sp)
 428:	e022                	sd	s0,0(sp)
 42a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 42c:	00000097          	auipc	ra,0x0
 430:	f66080e7          	jalr	-154(ra) # 392 <memmove>
}
 434:	60a2                	ld	ra,8(sp)
 436:	6402                	ld	s0,0(sp)
 438:	0141                	addi	sp,sp,16
 43a:	8082                	ret

000000000000043c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 43c:	4885                	li	a7,1
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <exit>:
.global exit
exit:
 li a7, SYS_exit
 444:	4889                	li	a7,2
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <wait>:
.global wait
wait:
 li a7, SYS_wait
 44c:	488d                	li	a7,3
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 454:	4891                	li	a7,4
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <read>:
.global read
read:
 li a7, SYS_read
 45c:	4895                	li	a7,5
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <write>:
.global write
write:
 li a7, SYS_write
 464:	48c1                	li	a7,16
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <close>:
.global close
close:
 li a7, SYS_close
 46c:	48d5                	li	a7,21
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <kill>:
.global kill
kill:
 li a7, SYS_kill
 474:	4899                	li	a7,6
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <exec>:
.global exec
exec:
 li a7, SYS_exec
 47c:	489d                	li	a7,7
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <open>:
.global open
open:
 li a7, SYS_open
 484:	48bd                	li	a7,15
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 48c:	48c5                	li	a7,17
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 494:	48c9                	li	a7,18
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 49c:	48a1                	li	a7,8
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <link>:
.global link
link:
 li a7, SYS_link
 4a4:	48cd                	li	a7,19
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4ac:	48d1                	li	a7,20
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4b4:	48a5                	li	a7,9
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <dup>:
.global dup
dup:
 li a7, SYS_dup
 4bc:	48a9                	li	a7,10
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4c4:	48ad                	li	a7,11
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4cc:	48b1                	li	a7,12
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4d4:	48b5                	li	a7,13
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4dc:	48b9                	li	a7,14
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <startlog>:
.global startlog
startlog:
 li a7, SYS_startlog
 4e4:	48d9                	li	a7,22
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <getlog>:
.global getlog
getlog:
 li a7, SYS_getlog
 4ec:	48dd                	li	a7,23
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <nice>:
.global nice
nice:
 li a7, SYS_nice
 4f4:	48e1                	li	a7,24
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4fc:	1101                	addi	sp,sp,-32
 4fe:	ec06                	sd	ra,24(sp)
 500:	e822                	sd	s0,16(sp)
 502:	1000                	addi	s0,sp,32
 504:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 508:	4605                	li	a2,1
 50a:	fef40593          	addi	a1,s0,-17
 50e:	00000097          	auipc	ra,0x0
 512:	f56080e7          	jalr	-170(ra) # 464 <write>
}
 516:	60e2                	ld	ra,24(sp)
 518:	6442                	ld	s0,16(sp)
 51a:	6105                	addi	sp,sp,32
 51c:	8082                	ret

000000000000051e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 51e:	7139                	addi	sp,sp,-64
 520:	fc06                	sd	ra,56(sp)
 522:	f822                	sd	s0,48(sp)
 524:	f426                	sd	s1,40(sp)
 526:	f04a                	sd	s2,32(sp)
 528:	ec4e                	sd	s3,24(sp)
 52a:	0080                	addi	s0,sp,64
 52c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 52e:	c299                	beqz	a3,534 <printint+0x16>
 530:	0805c863          	bltz	a1,5c0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 534:	2581                	sext.w	a1,a1
  neg = 0;
 536:	4881                	li	a7,0
 538:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 53c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 53e:	2601                	sext.w	a2,a2
 540:	00000517          	auipc	a0,0x0
 544:	49850513          	addi	a0,a0,1176 # 9d8 <digits>
 548:	883a                	mv	a6,a4
 54a:	2705                	addiw	a4,a4,1
 54c:	02c5f7bb          	remuw	a5,a1,a2
 550:	1782                	slli	a5,a5,0x20
 552:	9381                	srli	a5,a5,0x20
 554:	97aa                	add	a5,a5,a0
 556:	0007c783          	lbu	a5,0(a5)
 55a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 55e:	0005879b          	sext.w	a5,a1
 562:	02c5d5bb          	divuw	a1,a1,a2
 566:	0685                	addi	a3,a3,1
 568:	fec7f0e3          	bgeu	a5,a2,548 <printint+0x2a>
  if(neg)
 56c:	00088b63          	beqz	a7,582 <printint+0x64>
    buf[i++] = '-';
 570:	fd040793          	addi	a5,s0,-48
 574:	973e                	add	a4,a4,a5
 576:	02d00793          	li	a5,45
 57a:	fef70823          	sb	a5,-16(a4)
 57e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 582:	02e05863          	blez	a4,5b2 <printint+0x94>
 586:	fc040793          	addi	a5,s0,-64
 58a:	00e78933          	add	s2,a5,a4
 58e:	fff78993          	addi	s3,a5,-1
 592:	99ba                	add	s3,s3,a4
 594:	377d                	addiw	a4,a4,-1
 596:	1702                	slli	a4,a4,0x20
 598:	9301                	srli	a4,a4,0x20
 59a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 59e:	fff94583          	lbu	a1,-1(s2)
 5a2:	8526                	mv	a0,s1
 5a4:	00000097          	auipc	ra,0x0
 5a8:	f58080e7          	jalr	-168(ra) # 4fc <putc>
  while(--i >= 0)
 5ac:	197d                	addi	s2,s2,-1
 5ae:	ff3918e3          	bne	s2,s3,59e <printint+0x80>
}
 5b2:	70e2                	ld	ra,56(sp)
 5b4:	7442                	ld	s0,48(sp)
 5b6:	74a2                	ld	s1,40(sp)
 5b8:	7902                	ld	s2,32(sp)
 5ba:	69e2                	ld	s3,24(sp)
 5bc:	6121                	addi	sp,sp,64
 5be:	8082                	ret
    x = -xx;
 5c0:	40b005bb          	negw	a1,a1
    neg = 1;
 5c4:	4885                	li	a7,1
    x = -xx;
 5c6:	bf8d                	j	538 <printint+0x1a>

00000000000005c8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5c8:	7119                	addi	sp,sp,-128
 5ca:	fc86                	sd	ra,120(sp)
 5cc:	f8a2                	sd	s0,112(sp)
 5ce:	f4a6                	sd	s1,104(sp)
 5d0:	f0ca                	sd	s2,96(sp)
 5d2:	ecce                	sd	s3,88(sp)
 5d4:	e8d2                	sd	s4,80(sp)
 5d6:	e4d6                	sd	s5,72(sp)
 5d8:	e0da                	sd	s6,64(sp)
 5da:	fc5e                	sd	s7,56(sp)
 5dc:	f862                	sd	s8,48(sp)
 5de:	f466                	sd	s9,40(sp)
 5e0:	f06a                	sd	s10,32(sp)
 5e2:	ec6e                	sd	s11,24(sp)
 5e4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5e6:	0005c903          	lbu	s2,0(a1)
 5ea:	18090f63          	beqz	s2,788 <vprintf+0x1c0>
 5ee:	8aaa                	mv	s5,a0
 5f0:	8b32                	mv	s6,a2
 5f2:	00158493          	addi	s1,a1,1
  state = 0;
 5f6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5f8:	02500a13          	li	s4,37
      if(c == 'd'){
 5fc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 600:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 604:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 608:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 60c:	00000b97          	auipc	s7,0x0
 610:	3ccb8b93          	addi	s7,s7,972 # 9d8 <digits>
 614:	a839                	j	632 <vprintf+0x6a>
        putc(fd, c);
 616:	85ca                	mv	a1,s2
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	ee2080e7          	jalr	-286(ra) # 4fc <putc>
 622:	a019                	j	628 <vprintf+0x60>
    } else if(state == '%'){
 624:	01498f63          	beq	s3,s4,642 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 628:	0485                	addi	s1,s1,1
 62a:	fff4c903          	lbu	s2,-1(s1)
 62e:	14090d63          	beqz	s2,788 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 632:	0009079b          	sext.w	a5,s2
    if(state == 0){
 636:	fe0997e3          	bnez	s3,624 <vprintf+0x5c>
      if(c == '%'){
 63a:	fd479ee3          	bne	a5,s4,616 <vprintf+0x4e>
        state = '%';
 63e:	89be                	mv	s3,a5
 640:	b7e5                	j	628 <vprintf+0x60>
      if(c == 'd'){
 642:	05878063          	beq	a5,s8,682 <vprintf+0xba>
      } else if(c == 'l') {
 646:	05978c63          	beq	a5,s9,69e <vprintf+0xd6>
      } else if(c == 'x') {
 64a:	07a78863          	beq	a5,s10,6ba <vprintf+0xf2>
      } else if(c == 'p') {
 64e:	09b78463          	beq	a5,s11,6d6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 652:	07300713          	li	a4,115
 656:	0ce78663          	beq	a5,a4,722 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 65a:	06300713          	li	a4,99
 65e:	0ee78e63          	beq	a5,a4,75a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 662:	11478863          	beq	a5,s4,772 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 666:	85d2                	mv	a1,s4
 668:	8556                	mv	a0,s5
 66a:	00000097          	auipc	ra,0x0
 66e:	e92080e7          	jalr	-366(ra) # 4fc <putc>
        putc(fd, c);
 672:	85ca                	mv	a1,s2
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	e86080e7          	jalr	-378(ra) # 4fc <putc>
      }
      state = 0;
 67e:	4981                	li	s3,0
 680:	b765                	j	628 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 682:	008b0913          	addi	s2,s6,8
 686:	4685                	li	a3,1
 688:	4629                	li	a2,10
 68a:	000b2583          	lw	a1,0(s6)
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	e8e080e7          	jalr	-370(ra) # 51e <printint>
 698:	8b4a                	mv	s6,s2
      state = 0;
 69a:	4981                	li	s3,0
 69c:	b771                	j	628 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 69e:	008b0913          	addi	s2,s6,8
 6a2:	4681                	li	a3,0
 6a4:	4629                	li	a2,10
 6a6:	000b2583          	lw	a1,0(s6)
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	e72080e7          	jalr	-398(ra) # 51e <printint>
 6b4:	8b4a                	mv	s6,s2
      state = 0;
 6b6:	4981                	li	s3,0
 6b8:	bf85                	j	628 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6ba:	008b0913          	addi	s2,s6,8
 6be:	4681                	li	a3,0
 6c0:	4641                	li	a2,16
 6c2:	000b2583          	lw	a1,0(s6)
 6c6:	8556                	mv	a0,s5
 6c8:	00000097          	auipc	ra,0x0
 6cc:	e56080e7          	jalr	-426(ra) # 51e <printint>
 6d0:	8b4a                	mv	s6,s2
      state = 0;
 6d2:	4981                	li	s3,0
 6d4:	bf91                	j	628 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6d6:	008b0793          	addi	a5,s6,8
 6da:	f8f43423          	sd	a5,-120(s0)
 6de:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6e2:	03000593          	li	a1,48
 6e6:	8556                	mv	a0,s5
 6e8:	00000097          	auipc	ra,0x0
 6ec:	e14080e7          	jalr	-492(ra) # 4fc <putc>
  putc(fd, 'x');
 6f0:	85ea                	mv	a1,s10
 6f2:	8556                	mv	a0,s5
 6f4:	00000097          	auipc	ra,0x0
 6f8:	e08080e7          	jalr	-504(ra) # 4fc <putc>
 6fc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6fe:	03c9d793          	srli	a5,s3,0x3c
 702:	97de                	add	a5,a5,s7
 704:	0007c583          	lbu	a1,0(a5)
 708:	8556                	mv	a0,s5
 70a:	00000097          	auipc	ra,0x0
 70e:	df2080e7          	jalr	-526(ra) # 4fc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 712:	0992                	slli	s3,s3,0x4
 714:	397d                	addiw	s2,s2,-1
 716:	fe0914e3          	bnez	s2,6fe <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 71a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 71e:	4981                	li	s3,0
 720:	b721                	j	628 <vprintf+0x60>
        s = va_arg(ap, char*);
 722:	008b0993          	addi	s3,s6,8
 726:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 72a:	02090163          	beqz	s2,74c <vprintf+0x184>
        while(*s != 0){
 72e:	00094583          	lbu	a1,0(s2)
 732:	c9a1                	beqz	a1,782 <vprintf+0x1ba>
          putc(fd, *s);
 734:	8556                	mv	a0,s5
 736:	00000097          	auipc	ra,0x0
 73a:	dc6080e7          	jalr	-570(ra) # 4fc <putc>
          s++;
 73e:	0905                	addi	s2,s2,1
        while(*s != 0){
 740:	00094583          	lbu	a1,0(s2)
 744:	f9e5                	bnez	a1,734 <vprintf+0x16c>
        s = va_arg(ap, char*);
 746:	8b4e                	mv	s6,s3
      state = 0;
 748:	4981                	li	s3,0
 74a:	bdf9                	j	628 <vprintf+0x60>
          s = "(null)";
 74c:	00000917          	auipc	s2,0x0
 750:	28490913          	addi	s2,s2,644 # 9d0 <malloc+0x13e>
        while(*s != 0){
 754:	02800593          	li	a1,40
 758:	bff1                	j	734 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 75a:	008b0913          	addi	s2,s6,8
 75e:	000b4583          	lbu	a1,0(s6)
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	d98080e7          	jalr	-616(ra) # 4fc <putc>
 76c:	8b4a                	mv	s6,s2
      state = 0;
 76e:	4981                	li	s3,0
 770:	bd65                	j	628 <vprintf+0x60>
        putc(fd, c);
 772:	85d2                	mv	a1,s4
 774:	8556                	mv	a0,s5
 776:	00000097          	auipc	ra,0x0
 77a:	d86080e7          	jalr	-634(ra) # 4fc <putc>
      state = 0;
 77e:	4981                	li	s3,0
 780:	b565                	j	628 <vprintf+0x60>
        s = va_arg(ap, char*);
 782:	8b4e                	mv	s6,s3
      state = 0;
 784:	4981                	li	s3,0
 786:	b54d                	j	628 <vprintf+0x60>
    }
  }
}
 788:	70e6                	ld	ra,120(sp)
 78a:	7446                	ld	s0,112(sp)
 78c:	74a6                	ld	s1,104(sp)
 78e:	7906                	ld	s2,96(sp)
 790:	69e6                	ld	s3,88(sp)
 792:	6a46                	ld	s4,80(sp)
 794:	6aa6                	ld	s5,72(sp)
 796:	6b06                	ld	s6,64(sp)
 798:	7be2                	ld	s7,56(sp)
 79a:	7c42                	ld	s8,48(sp)
 79c:	7ca2                	ld	s9,40(sp)
 79e:	7d02                	ld	s10,32(sp)
 7a0:	6de2                	ld	s11,24(sp)
 7a2:	6109                	addi	sp,sp,128
 7a4:	8082                	ret

00000000000007a6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7a6:	715d                	addi	sp,sp,-80
 7a8:	ec06                	sd	ra,24(sp)
 7aa:	e822                	sd	s0,16(sp)
 7ac:	1000                	addi	s0,sp,32
 7ae:	e010                	sd	a2,0(s0)
 7b0:	e414                	sd	a3,8(s0)
 7b2:	e818                	sd	a4,16(s0)
 7b4:	ec1c                	sd	a5,24(s0)
 7b6:	03043023          	sd	a6,32(s0)
 7ba:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7be:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7c2:	8622                	mv	a2,s0
 7c4:	00000097          	auipc	ra,0x0
 7c8:	e04080e7          	jalr	-508(ra) # 5c8 <vprintf>
}
 7cc:	60e2                	ld	ra,24(sp)
 7ce:	6442                	ld	s0,16(sp)
 7d0:	6161                	addi	sp,sp,80
 7d2:	8082                	ret

00000000000007d4 <printf>:

void
printf(const char *fmt, ...)
{
 7d4:	711d                	addi	sp,sp,-96
 7d6:	ec06                	sd	ra,24(sp)
 7d8:	e822                	sd	s0,16(sp)
 7da:	1000                	addi	s0,sp,32
 7dc:	e40c                	sd	a1,8(s0)
 7de:	e810                	sd	a2,16(s0)
 7e0:	ec14                	sd	a3,24(s0)
 7e2:	f018                	sd	a4,32(s0)
 7e4:	f41c                	sd	a5,40(s0)
 7e6:	03043823          	sd	a6,48(s0)
 7ea:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ee:	00840613          	addi	a2,s0,8
 7f2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7f6:	85aa                	mv	a1,a0
 7f8:	4505                	li	a0,1
 7fa:	00000097          	auipc	ra,0x0
 7fe:	dce080e7          	jalr	-562(ra) # 5c8 <vprintf>
}
 802:	60e2                	ld	ra,24(sp)
 804:	6442                	ld	s0,16(sp)
 806:	6125                	addi	sp,sp,96
 808:	8082                	ret

000000000000080a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 80a:	1141                	addi	sp,sp,-16
 80c:	e422                	sd	s0,8(sp)
 80e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 810:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 814:	00000797          	auipc	a5,0x0
 818:	1dc7b783          	ld	a5,476(a5) # 9f0 <freep>
 81c:	a805                	j	84c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 81e:	4618                	lw	a4,8(a2)
 820:	9db9                	addw	a1,a1,a4
 822:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 826:	6398                	ld	a4,0(a5)
 828:	6318                	ld	a4,0(a4)
 82a:	fee53823          	sd	a4,-16(a0)
 82e:	a091                	j	872 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 830:	ff852703          	lw	a4,-8(a0)
 834:	9e39                	addw	a2,a2,a4
 836:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 838:	ff053703          	ld	a4,-16(a0)
 83c:	e398                	sd	a4,0(a5)
 83e:	a099                	j	884 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 840:	6398                	ld	a4,0(a5)
 842:	00e7e463          	bltu	a5,a4,84a <free+0x40>
 846:	00e6ea63          	bltu	a3,a4,85a <free+0x50>
{
 84a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 84c:	fed7fae3          	bgeu	a5,a3,840 <free+0x36>
 850:	6398                	ld	a4,0(a5)
 852:	00e6e463          	bltu	a3,a4,85a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 856:	fee7eae3          	bltu	a5,a4,84a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 85a:	ff852583          	lw	a1,-8(a0)
 85e:	6390                	ld	a2,0(a5)
 860:	02059713          	slli	a4,a1,0x20
 864:	9301                	srli	a4,a4,0x20
 866:	0712                	slli	a4,a4,0x4
 868:	9736                	add	a4,a4,a3
 86a:	fae60ae3          	beq	a2,a4,81e <free+0x14>
    bp->s.ptr = p->s.ptr;
 86e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 872:	4790                	lw	a2,8(a5)
 874:	02061713          	slli	a4,a2,0x20
 878:	9301                	srli	a4,a4,0x20
 87a:	0712                	slli	a4,a4,0x4
 87c:	973e                	add	a4,a4,a5
 87e:	fae689e3          	beq	a3,a4,830 <free+0x26>
  } else
    p->s.ptr = bp;
 882:	e394                	sd	a3,0(a5)
  freep = p;
 884:	00000717          	auipc	a4,0x0
 888:	16f73623          	sd	a5,364(a4) # 9f0 <freep>
}
 88c:	6422                	ld	s0,8(sp)
 88e:	0141                	addi	sp,sp,16
 890:	8082                	ret

0000000000000892 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 892:	7139                	addi	sp,sp,-64
 894:	fc06                	sd	ra,56(sp)
 896:	f822                	sd	s0,48(sp)
 898:	f426                	sd	s1,40(sp)
 89a:	f04a                	sd	s2,32(sp)
 89c:	ec4e                	sd	s3,24(sp)
 89e:	e852                	sd	s4,16(sp)
 8a0:	e456                	sd	s5,8(sp)
 8a2:	e05a                	sd	s6,0(sp)
 8a4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a6:	02051493          	slli	s1,a0,0x20
 8aa:	9081                	srli	s1,s1,0x20
 8ac:	04bd                	addi	s1,s1,15
 8ae:	8091                	srli	s1,s1,0x4
 8b0:	0014899b          	addiw	s3,s1,1
 8b4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8b6:	00000517          	auipc	a0,0x0
 8ba:	13a53503          	ld	a0,314(a0) # 9f0 <freep>
 8be:	c515                	beqz	a0,8ea <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c2:	4798                	lw	a4,8(a5)
 8c4:	02977f63          	bgeu	a4,s1,902 <malloc+0x70>
 8c8:	8a4e                	mv	s4,s3
 8ca:	0009871b          	sext.w	a4,s3
 8ce:	6685                	lui	a3,0x1
 8d0:	00d77363          	bgeu	a4,a3,8d6 <malloc+0x44>
 8d4:	6a05                	lui	s4,0x1
 8d6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8da:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8de:	00000917          	auipc	s2,0x0
 8e2:	11290913          	addi	s2,s2,274 # 9f0 <freep>
  if(p == (char*)-1)
 8e6:	5afd                	li	s5,-1
 8e8:	a88d                	j	95a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 8ea:	00000797          	auipc	a5,0x0
 8ee:	30e78793          	addi	a5,a5,782 # bf8 <base>
 8f2:	00000717          	auipc	a4,0x0
 8f6:	0ef73f23          	sd	a5,254(a4) # 9f0 <freep>
 8fa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8fc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 900:	b7e1                	j	8c8 <malloc+0x36>
      if(p->s.size == nunits)
 902:	02e48b63          	beq	s1,a4,938 <malloc+0xa6>
        p->s.size -= nunits;
 906:	4137073b          	subw	a4,a4,s3
 90a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 90c:	1702                	slli	a4,a4,0x20
 90e:	9301                	srli	a4,a4,0x20
 910:	0712                	slli	a4,a4,0x4
 912:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 914:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 918:	00000717          	auipc	a4,0x0
 91c:	0ca73c23          	sd	a0,216(a4) # 9f0 <freep>
      return (void*)(p + 1);
 920:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 924:	70e2                	ld	ra,56(sp)
 926:	7442                	ld	s0,48(sp)
 928:	74a2                	ld	s1,40(sp)
 92a:	7902                	ld	s2,32(sp)
 92c:	69e2                	ld	s3,24(sp)
 92e:	6a42                	ld	s4,16(sp)
 930:	6aa2                	ld	s5,8(sp)
 932:	6b02                	ld	s6,0(sp)
 934:	6121                	addi	sp,sp,64
 936:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 938:	6398                	ld	a4,0(a5)
 93a:	e118                	sd	a4,0(a0)
 93c:	bff1                	j	918 <malloc+0x86>
  hp->s.size = nu;
 93e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 942:	0541                	addi	a0,a0,16
 944:	00000097          	auipc	ra,0x0
 948:	ec6080e7          	jalr	-314(ra) # 80a <free>
  return freep;
 94c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 950:	d971                	beqz	a0,924 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 952:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 954:	4798                	lw	a4,8(a5)
 956:	fa9776e3          	bgeu	a4,s1,902 <malloc+0x70>
    if(p == freep)
 95a:	00093703          	ld	a4,0(s2)
 95e:	853e                	mv	a0,a5
 960:	fef719e3          	bne	a4,a5,952 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 964:	8552                	mv	a0,s4
 966:	00000097          	auipc	ra,0x0
 96a:	b66080e7          	jalr	-1178(ra) # 4cc <sbrk>
  if(p == (char*)-1)
 96e:	fd5518e3          	bne	a0,s5,93e <malloc+0xac>
        return 0;
 972:	4501                	li	a0,0
 974:	bf45                	j	924 <malloc+0x92>
