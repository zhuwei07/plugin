/* clearemptylines.c */

#include <stdio.h>
#include <ctype.h>

int main(int argc,char *argv[])
{
	FILE *src,*dst;
	char buffer[500];
	if (argc!=3)
	{
		printf("%s <dest> <src>\n",argv[0]);
		return 1;
	}
	src=fopen(argv[2],"rt");
	if (src==NULL)
	{
		printf("Can not open %s\n",argv[2]);
		return 1;
	}
	dst=fopen(argv[1],"wt");
	if (dst==NULL)
	{
		printf("Can not write %s\n",argv[1]);
		return 1;
	}
	while (fgets(buffer,500,src)!=NULL)
	{
		char *p=buffer;
		while ((*p)&&isspace(*p))
			p++;
		if (*p)
			fprintf(dst,"%s",buffer);
	}
	fclose(dst);
	fclose(src);
	return 0;
}

