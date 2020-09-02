/* env.h */

#ifndef ENV_H
#define ENV_H

#include "sgml.h"

struct _env_type
{
	sgml_type			*me;
	sgml_type			*foot;
	struct _env_type	*father;
	vector_type			*sons;
};

#define	IS_GROUP	1
#define IS_ITEM		2

typedef struct
{
	int		flag;
	void *	item;
} env_item;

typedef struct _env_type	env_type;

env_type * create_env (char * filename);
void print_env (env_type * p_env);
env_type *trans_env(env_type *p_env);
env_type *do_trans_env(env_type *p_env,env_type *p_father);
env_type *find_father(env_type *p_env);
env_type *find_son(env_type *p_env,const char *name);
env_type *get_son(env_type *p_env,int index);
int get_son_number(env_type *p_env);
sgml_type *get_sgml(env_type *p_env);

#endif
