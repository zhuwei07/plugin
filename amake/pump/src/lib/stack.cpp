#include <stdio.h>
#include "vector.h"
#include "stack.h"

vector_type	* new_stack ()
{
	return new_vector ();
}
void push_stack (vector_type * p_stack, void *item)
{
	vector_append (p_stack, item);
}

void * pop_stack (vector_type * p_stack)
{
	void * item	= vector_content (p_stack, p_stack -> length - 1);

	if (item == NULL)
		return NULL;

	vector_delete_index (p_stack, p_stack -> length - 1);

	return item;
}

int	is_empty (vector_type * p_stack)
{
	return (p_stack -> length == 0);
}

