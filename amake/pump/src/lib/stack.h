/* stack.h */

#ifndef STACK_H
#define STACK_H

#include "vector.h"

vector_type	* new_stack ();
void push_stack (vector_type * p_stack, void *item);
void * pop_stack (vector_type * p_stack);
int	is_empty (vector_type * p_stack);

#endif
