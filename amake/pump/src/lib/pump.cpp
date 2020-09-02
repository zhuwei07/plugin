/* pump.cpp */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>
#include "pumpsys.h"
#include "pump.h"
#include "env.h"
#include "stack.h"

env_type *p_env;
FILE *output;
env_type *p_node;
vector_type *p_stack;
int line_no;
char *file_name;
int use_pump_command=0;

#define MAX_VAR 200

typedef struct
{
	char *name,*value;
}	var_type;

var_type vars[MAX_VAR];
int var_count=0;

void pump(void);

void my_error(const char *format,...)
{
	static char buffer[200];
	va_list v;
	va_start(v,format);
	vsprintf(buffer,format,v);
	va_end(v);
	fprintf(stderr,"%s at %d of %s\n",buffer,line_no,file_name);
	exit(1);
}

void set_value(const char *name,const char *value)
{
	int i;
	/*
	if ((value!=NULL)&&(*value=='\0'))
		value=NULL;
	*/
	if ((value!=NULL)&&(var_count>=MAX_VAR))
		my_error("Too many variable");
	for (i=0;i<var_count;i++)
	{
		if (!strcmp(name,vars[i].name))
		{
			if (value!=NULL)
				vars[i].value=strdup(value);
			else
				vars[i].value=NULL;
			return;
		}
	}
	if (value==NULL)
		return;
	vars[var_count].name=strdup(name);
	vars[var_count].value=strdup(value);
	var_count++;
}

static char *get_value(const char *name)
{
	int i;
	for (i=0;i<var_count;i++)
	{
		if (!strcmp(name,vars[i].name))
			return vars[i].value;
	}
	return NULL;
}

int resolve_name(env_type *p_this_node,const char *name,env_type **p_result_node,char **remain_name)
{
	char *p_dot=(char *)strchr(name,'.');
	if (p_dot!=NULL)
	{
		char buffer[40];
		int i;
		env_type *this_son;
		strncpy(buffer,name,p_dot-name);
		buffer[p_dot-name]='\0';
		this_son=find_son(p_this_node,buffer);
		if (this_son==NULL)
			return 0;
		return resolve_name(this_son,p_dot+1,p_result_node,remain_name);
	}
	else
	{
		sgml_type *p_sgml;
		env_type *this_son;
		env_type *this_ancestor;
		p_sgml=get_sgml(p_this_node);
		if (!strcmp(name,"son_size")||!strcmp(name,"property_size")||get_property(p_sgml,name))
		{
			*p_result_node=p_this_node;
			*remain_name=(char *)name;
			return 1;
		}
		if (get_value(name))
		{
			*p_result_node=p_this_node;
			*remain_name=(char *)name;
			return 1;
		}
		if (!strcmp(name,"self"))
		{
			*p_result_node=p_this_node;
			*remain_name=NULL;
			return 1;
		}
		this_son=find_son(p_this_node,name);
		if (this_son!=NULL)
		{
			*p_result_node=this_son;
			*remain_name=NULL;
			return 1;
		}
		this_ancestor=p_this_node;
		for (;;)
		{
			char *group_name;
			this_ancestor=find_father(this_ancestor);
			if (this_ancestor==NULL)
				break;
			p_sgml=get_sgml(this_ancestor);
			if (get_property(p_sgml,name)!=NULL)
			{
				*p_result_node=this_ancestor;
				*remain_name=(char *)name;
				return 1;
			}
			group_name=get_property(p_sgml,"name");
			if ((group_name!=NULL)&&(!strcmp(group_name,name)))
			{
				*p_result_node=this_ancestor;
				*remain_name=NULL;
				return 1;
			}
		}
		*p_result_node=NULL;
		*remain_name=NULL;
		return 0;
	}
}

env_type *p_result_env;
char *remain_name;

void do_resolve_name(const char *name)
{
	if (!resolve_name(p_env,name,&p_result_env,&remain_name))
		my_error("Can not resolve name '%s'",name);
}

int valid_name(const char *name)
{
	if (!resolve_name(p_env,name,&p_result_env,&remain_name))
		return 0;
	return 1;
}

void expect_group(const char *name)
{
	do_resolve_name(name);
	if (remain_name!=NULL)
		my_error("Can not resolve name '%s' to group name",name);
}

void expect_string(const char *name)
{
	do_resolve_name(name);
	/*
	if (remain_name==NULL)
		my_error("Can not resolve name '%s' to string name",name);
	*/
}

int length(const char * name)
{
	expect_group(name);
	return get_son_number(p_result_env);
}

void enter(const char * name)
{
	expect_group(name);
	push_stack(p_stack,p_env);
	p_env=p_result_env;
}

void enter_set(const char * name,int index)
{
	env_type *p_this_son;
	expect_group(name);
	p_this_son=get_son(p_result_env,index);
	if (p_this_son==NULL)
		my_error("Can not find the %dth son of %s", index,name);
	push_stack(p_stack,p_env);
	p_env=p_this_son;
}

void enter_son_id(int index)
{
	env_type *p_this_son;
	p_this_son=get_son(p_env,index);
	if (p_this_son==NULL)
		my_error("Can not find the %dth son",index);
	push_stack(p_stack,p_env);
	p_env=p_this_son;
}

void leave(void)
{
	p_env=(env_type *)pop_stack(p_stack);
	if (p_env==NULL)
		my_error("Can not leave");
}

void display_name(const char * name)
{
	display_string(get_string(name));
}


/* #define DIRECT_OUTPUT */

static int is_empty_line(char *line)
{
	char *p_line=line;
	while (*p_line)
	{
		if (!isspace(*p_line)&&(*p_line!='\r'))
			return 0;
		p_line++;
	}
	return 1;
}

void display_string(const char * string)
{
#ifdef DIRECT_OUTPUT
	fprintf(output,"%s",string);
	/* printf("%s",string);
	fflush(stdout); */
#else
	/* For any empty line, if there are any pump command in this line, this line will be ignored */
	static char remain_buffer[5000]="";
	char *p_return;
	if (strlen(remain_buffer)+strlen(string)>=5000)
	{
		my_error("Too long output line, please adjust the size of remain_buffer"
			" in function display_string in file pump.c\n");
	}
	strcat(remain_buffer,string);
	p_return=strchr(remain_buffer,'\n');
	if (p_return!=NULL)
	{
		*p_return='\0';
		if (!is_empty_line(remain_buffer)||!use_pump_command)
		{
			fprintf(output,"%s\n",remain_buffer);
		}
		strcpy(remain_buffer,p_return+1);
		use_pump_command=0;
	}
#endif
}

void display_value(int value)
{
	char buffer[20];
	sprintf(buffer,"%d",value);
	display_string(buffer);
}

void display_char(char ch)
{
	char buffer[2];
	buffer[0]=ch;
	buffer[1]='\0';
	display_string(buffer);
}

void error (void)
{
	my_error("user error");
}

char *to_string(int value)
{
	char *buffer;
	buffer=(char *)alloc_mem(20);
	sprintf(buffer,"%d",value);
	return buffer;
}

char * get_string(const char * name)
{
	sgml_type *p_sgml;
	char *value;
	expect_string(name);
	p_sgml=get_sgml(p_result_env);
	if (remain_name==NULL)
		return get_property(p_sgml,"name");
	if (!strcmp(remain_name,"property_size"))
		return to_string(get_property_length(p_sgml));
	if (!strcmp(remain_name,"son_size"))
		return to_string(get_son_number(p_result_env));
	value=get_value(remain_name);
	if (value!=NULL)
		return value;
	return get_property(p_sgml,remain_name);
}

void set_line_no (int lno)
{
	line_no=lno;
}

void set_file_name(const char *  fname)
{
	file_name=(char *)fname;
}

char *replace(const char *src,const char *from, const char *to)
{
	char buffer[10240];
	char *occur;
	char *start,*target;

	start=(char *)src;
	target=buffer;
	for (;;)
	{
		occur=strstr(start,from);
		if (occur==NULL)
		{
			strcpy(target,start);
			break;
		}
		strncpy(target,start,occur-start);
		target+=occur-start;
		strcpy(target,to);
		target+=strlen(to);
		start=occur+strlen(from);
	}
	return strdup(buffer);
}

char *substr(const char *src, int from, int to)
{
	char buffer[10240];
	strncpy(buffer,src+from,to-from);
	buffer[to-from]='\0';
	return strdup(buffer);
}

char *addstring(const char *string1, const char *string2)
{
	char buffer[10240];
	strcpy(buffer,string1);
	strcat(buffer,string2);
	return strdup(buffer);
}

char *multiaddstring(int n,...)
{
	va_list v;
	char *result=(char *)"";
	char *this_string;
	int i;
	va_start(v,n);
	for (i=0;i<n;i++)
	{
		this_string=va_arg(v,char *);
		result=addstring(result,this_string);
	}
	va_end(v);
	return result;
}

int main(int argc,char *argv[])
{
	env_type *p_this_env;
	int i;
	if (argc<3)
	{
		printf("%s <output file> <env files>\n",argv[0]);
		return 1;
	}
	for (i=2;i<argc;i++)
	{
		p_this_env=create_env(argv[i]);
		if (p_this_env==NULL)
		{
			printf("error in enviroment file %s\n",argv[i]);
			return 1;
		}
		if (i==2)
		{
			p_env=trans_env(p_this_env);
		}
		else
		{
			vector_append(p_env->sons,do_trans_env(p_this_env,p_env));
		}
	}
	output=fopen(argv[1],"wt");
	if (output==NULL)
	{
		printf("Can not open output file %s\n",argv[1]);
		return 1;
	}
	p_node=p_env;
	p_stack=new_stack();
	file_name=(char *)"unknown file";
	line_no=1;
	pump();
	return 0;
}

