#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include "pumpsys.h"

void * alloc_mem(int size)
{
	void *p;
	p=malloc (size);
	if (p==NULL)
		error_msg("Can not malloc memory\n");
	return p;
}

void free_mem(void *p)
{
	free (p);
}

void * realloc_mem(void *p, int new_size,int old_size)
{
	void *result;
	result=realloc (p, new_size);
	if (result!=NULL)
		return result;
	result=malloc(new_size);
	if (result==NULL)
		error_msg("Can not realloc memory\n");
	memcpy(result,p,old_size);
	return result;
}

void error_msg (const char *format,...)
{
	va_list	v;
	char	buffer[BUFFERSIZE];

	va_start (v, format);
	vsprintf (buffer, format, v);
	va_end (v);
	fprintf (stderr,"%s\n",buffer);

	exit(1);
}

