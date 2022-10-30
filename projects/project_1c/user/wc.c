/**
 * @file wc.c
 * @author (modifier) Patrick Demers (netid: demers)
 *
 * modifications:
 * 2022-08-29: modified to print out vowel count as fourth value.
 */
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

char buf[512];

void wc(int fd, char *name)
{
  int i, n;
  int l, w, c, v, inword;

  l = w = c = v = 0;
  inword = 0;
  while ((n = read(fd, buf, sizeof(buf))) > 0)
  {
    for (i = 0; i < n; i++)
    {
      c++;
      if (buf[i] == '\n')
        l++;

      // addition: count occurences of vowels
      if (strchr("aeiouAEIOU", buf[i]))
      {
        v++;
      }
      if (strchr(" \r\t\n\v", buf[i]))
        inword = 0;
      else if (!inword)
      {
        w++;
        inword = 1;
      }
    }
  }
  if (n < 0)
  {
    printf("wc: read error\n");
    exit(1);
  }

  // modification: print vowel count before file name
  printf("%d %d %d %d %s\n", l, w, c, v, name);
}

int main(int argc, char *argv[])
{
  int fd, i;

  if (argc <= 1)
  {
    wc(0, "");
    exit(0);
  }

  for (i = 1; i < argc; i++)
  {
    if ((fd = open(argv[i], 0)) < 0)
    {
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
    close(fd);
  }
  exit(0);
}
