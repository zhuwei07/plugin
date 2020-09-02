#include <stdio.h>
#include <string.h>
#include "env.h"
#include "stack.h"

env_type * create_env (char * filename)
{
	FILE        *	fenv;
	sgml_type   *	p_sgml;
	vector_type *	p_stack;
	env_type    *	p_env;
	env_item    *	p_item, * p;
	
	if ((fenv = fopen (filename, "r")) == NULL)
		return NULL;

	set_source (fenv);
	p_stack	= new_stack ();
	p_sgml	= create_sgml ();

	while (p_sgml != NULL)
	{
		if (get_sgml_type(p_sgml) != END_TAG)
		{
			p_item	= (env_item *) alloc_mem (sizeof(env_item));
			if (p_item == NULL)
			{
				delete_sgml (p_sgml);
				delete_vector (p_stack);
				return NULL;
			}
			p_item -> flag	= IS_ITEM;
			p_item -> item	= (void *)p_sgml;

			push_stack (p_stack, (void *)p_item);
			p_sgml	= create_sgml ();
			continue;
		}
		
		p_env	= (env_type *) alloc_mem (sizeof(env_type));
		if (p_env == NULL)
		{
			delete_sgml (p_sgml);
			delete_vector (p_stack);
			return NULL;
		}
		p_env -> foot	= p_sgml;
		p_env -> father	= NULL;
		p_env -> sons	= new_vector ();

		while (1)
		{
			p	= (env_item *) pop_stack (p_stack);
			if (p == NULL)
				return NULL;
			if (p -> flag == IS_GROUP)
			{
				((env_type *)(p -> item)) -> father	= p_env;
				vector_insert (p_env -> sons, (void *)p, 0);
			}
			else
			{
				if (strcmp(get_sgml_name((sgml_type *)(p -> item)), get_sgml_name(p_sgml)))
					vector_insert (p_env -> sons, (void *)p, 0);
				else
				{
					p_env -> me	= (sgml_type *) p -> item;
					break;
				}
			}
		}
		vector_pack (p_stack);
		p_item	= (env_item *) alloc_mem (sizeof(env_item));
		p_item -> flag	= IS_GROUP;
		p_item -> item	= (void *) p_env;
		push_stack (p_stack, (void *)p_item);
		p_sgml	= create_sgml ();
	}

	p_item	= (env_item *) pop_stack (p_stack);
	if (!is_empty (p_stack) || p_item -> flag != IS_GROUP)
		return NULL;
	else
		return (env_type *)(p_item -> item);
}

static void print_leaf (sgml_type * p_sgml, int level)
{
	int	i;
	
	for (i=0; i<level; i++)
		printf ("\t");
	print_sgml (p_sgml);
}

static void print_node (env_type * p_env, int level)
{
	int	i;
	env_item *	p_item;

	for (i=0; i<level; i++)
		printf ("\t");
	print_sgml (p_env -> me);
	for (i=0; i<p_env -> sons -> length; i++)
	{
		p_item	= (env_item *)(vector_content(p_env -> sons, i));
		if (p_item -> flag == IS_ITEM)
			print_leaf ((sgml_type *)(p_item -> item), level + 1);
		else
			print_node ((env_type *)(p_item -> item), level + 1);
	}
	for (i=0; i<level; i++)
		printf ("\t");
	print_sgml (p_env -> foot);
}

env_type *do_trans_env(env_type *p_env,env_type *p_father)
{
	env_type *this_env;
	int i;
	this_env=(env_type *)alloc_mem(sizeof(env_type));
	this_env->me=p_env->me;
	this_env->father=p_father;
	this_env->sons=new_vector();
	for (i=0;i<p_env->sons->length;i++)
	{
		env_item *this_item=(env_item *)(vector_content(p_env->sons,i));
		env_type *tmp_env;
		if (this_item->flag==IS_ITEM)
		{
			tmp_env=(env_type *)alloc_mem(sizeof(env_type));
			tmp_env->me=(sgml_type *)this_item->item;
			tmp_env->father=this_env;
			tmp_env->sons=new_vector();
		}
		else
		{
			tmp_env=do_trans_env((env_type *)this_item->item,this_env);
		}
		vector_append(this_env->sons,tmp_env);
	}
	return this_env;
}

env_type *trans_env(env_type *source_env)
{
	env_type *p_env;
	p_env=(env_type *)alloc_mem(sizeof(env_type));
	p_env->me=create_empty_sgml();
	set_sgml_name(p_env->me,(char *)"PumpRoot");
	p_env->father=NULL;
	p_env->sons=new_vector();
	vector_append(p_env->sons,do_trans_env(source_env,p_env));
	return p_env;
}

void print_env (env_type * p_env)
{
	print_node (p_env, 0);
}

env_type *find_father(env_type *p_env)
{
	return p_env->father;
}

env_type *find_son(env_type *p_env,const char *name)
{
	int i;
	for (i=0;i<get_son_number(p_env);i++)
	{
		env_type *this_son;
		sgml_type *this_son_sgml;
		char *this_son_name;
		this_son=get_son(p_env,i);
		this_son_sgml=get_sgml(this_son);
		this_son_name=get_property(this_son_sgml,"name");
		if (this_son_name==NULL)
			continue;
		if (!strcmp(name,this_son_name))
		{
			return this_son;
		}
	}
	return NULL;
}

env_type *get_son(env_type *p_env,int index)
{
	return (env_type *)vector_content(p_env->sons,index);
}

int get_son_number(env_type *p_env)
{
	return p_env->sons->length;
}

sgml_type *get_sgml(env_type *p_env)
{
	return p_env->me;
}

/*
void main (void)
{
	env_type	* p_env;

	p_env	= create_env ("tables.env");

	if (p_env != NULL)
		print_env (p_env);
	else
		error_msg ("error in env file.\n");
}
*/

