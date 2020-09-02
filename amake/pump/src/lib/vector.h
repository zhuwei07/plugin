/* vector.h */

#ifndef VECTOR_H
#define VECTOR_H

#include "pumpsys.h"

typedef struct
{
	int alloc_size;
	int length;
	void **content;
}	vector_type;

#define INCREASE_LENGTH 4

vector_type *new_vector(void);
void delete_vector(vector_type *p_vector);
int	 vector_append(vector_type *p_vector,void *p_content);
int	 vector_insert(vector_type *p_vector,void *p_content,int index);
void *vector_content(vector_type *p_vector,int index);
int  vector_delete_content(vector_type *p_vector,void *p_content);
int  vector_delete_index(vector_type *p_vector,int index);
void vector_pack (vector_type * p_vector);

#endif

