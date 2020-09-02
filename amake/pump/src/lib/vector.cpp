#include <stdio.h>
#include "vector.h"

vector_type * new_vector(void)
{
	vector_type *	p;
	void		**	c;
	int				i;

	c	= (void **) alloc_mem (INCREASE_LENGTH * sizeof(void *));
	if (c == NULL)
		return NULL;
	p	= (vector_type *) alloc_mem (sizeof(vector_type));
	if (p == NULL)
		return NULL;

	p -> alloc_size = INCREASE_LENGTH;
	p -> length		= 0;
	p -> content	= c;

	for (i=0; i<INCREASE_LENGTH; i++)
		c[i] = NULL;

	return p;
}

void delete_vector (vector_type * p_vector)
{
	free_mem (p_vector -> content);
	free_mem (p_vector);
}

static vector_type * ensure_capacity (vector_type * p_vector, int new_length)
{
	while (new_length >= p_vector -> alloc_size)
	{
		void **	c;

		c = (void **) realloc_mem (p_vector -> content, (p_vector -> alloc_size + INCREASE_LENGTH) * sizeof (void *), (p_vector->alloc_size)*sizeof(void *));
		if (c == NULL)
			return NULL;
		p_vector -> content		=  c;
		p_vector -> alloc_size	+= INCREASE_LENGTH;
	}

	return p_vector;
}

/*
	append the content at the end of vector,
	if failed, return -1; else return 0;
*/

int vector_append (vector_type * p_vector, void * p_content)
{
	p_vector = ensure_capacity (p_vector, p_vector -> length + 1);
	if (p_vector == NULL)
		return -1;
	p_vector -> content [p_vector -> length++]	= p_content;

	return 0;
}

/*
	insert the content at the position 'index' of vector,
	if failed
		return -1: cannot malloc nessesary memory;
		return -2: the 'index' is not valid
	else return 0;
*/

int vector_insert (vector_type *p_vector, void *p_content, int index)
{
	int	i;

	if (index == -1)
		return vector_append (p_vector, p_content);

	if (index > p_vector -> length || index < -1)
		return -2;	/* not valid */

	p_vector = ensure_capacity (p_vector, p_vector -> length + 1);
	if (p_vector == NULL)
		return -1;

	for (i = p_vector -> length - 1; i >= index; i--)
		p_vector -> content[i+1] = p_vector -> content[i];
	p_vector -> content[index]	 = p_content;
	p_vector -> length ++;

	return 0;
}

void * vector_content (vector_type *p_vector, int index)
{
	if (index > p_vector -> length - 1 || index < 0)
		return NULL;

	return p_vector -> content[index];
}

/*
	delete the specified content
	if failed, return -1; else return 0;
*/

int vector_delete_content (vector_type *p_vector, void *p_content)
{
	int	i;

	for (i=0; i < p_vector -> length; i++)
		if (p_vector -> content[i] == p_content)
			break;
	if (i == p_vector -> length)
		return -1;	/* not found */
	for (; i < p_vector -> length - 1; i++)
		p_vector -> content[i] = p_vector -> content[i+1];
	p_vector -> length--;

	/* we can decrease the 'alloc_size' here. */
	return 0;
}

/*
	delete the content at the specified 'index'
	if failed, return -1; else return 0;
*/

int vector_delete_index(vector_type *p_vector, int index)
{
	int	i;

	if (index > p_vector -> length - 1 || index < 0)
		return -1;

	for (i=index; i < p_vector -> length - 1; i++)
		p_vector -> content[i] = p_vector -> content[i+1];
	p_vector -> length--;

	/* we can decrease the 'alloc_size' here. */
	return 0;
}

void vector_pack (vector_type * p_vector)
{
	int	size	= ((p_vector -> length + INCREASE_LENGTH - 1) / INCREASE_LENGTH) * INCREASE_LENGTH;
	void ** c;
	
	if (p_vector -> alloc_size == size)
		return;

	c = (void **) realloc_mem (p_vector -> content, size * sizeof (void *), size*sizeof(void *));
	if (c == NULL)
		return;

	p_vector -> alloc_size	= size;
	p_vector -> content		= c;
}
