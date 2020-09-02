/* sgml.h */

#ifndef SGML_H
#define SGML_H

#include <stdio.h>
#include <ctype.h>
#include "vector.h"

enum
{
	START_TAG,
	END_TAG,
	LITERAL,
	COMMENT
};

typedef struct
{
	int	type;
	char * name;
	char character;
	char * comment;
	vector_type *properties;
}	sgml_type;

typedef struct
{
	char * name;
	char * value;
}	sgml_property_type;

void set_source(FILE *input);
sgml_type *create_sgml(void);
sgml_type *create_empty_sgml(void);
void delete_sgml(sgml_type *p_sgml);
int get_sgml_type(sgml_type *p_sgml);
void set_sgml_type(sgml_type *p_sgml,int type);
char *get_sgml_name(sgml_type *p_sgml);
void set_sgml_name(sgml_type *p_sgml,char *name);
int get_property_length(sgml_type *p_sgml);
char *get_property_name(sgml_type *p_sgml,int index);
char *get_property_value(sgml_type *p_sgml,int index);
char *get_property(sgml_type *p_sgml,const char *name);
void set_property_value(sgml_type *p_sgml,char *name,char *value);
void print_sgml (sgml_type *p_sgml);

#endif

