/* pumpsys.h */

#ifndef PUMPSYS_H
#define PUMPSYS_H

void *alloc_mem(int size);
void free_mem(void *p);
void *realloc_mem(void *p,int new_size,int old_size);
void error_msg(const char *format,...);

#define	BUFFERSIZE	8192

#endif

