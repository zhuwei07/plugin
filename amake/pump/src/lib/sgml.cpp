#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "pumpsys.h"
#include "sgml.h"

static FILE * finput = NULL;
/* static int saved	 = -2; */

typedef struct
{
	const char *	str;
	char	c;
}	translate;

#define	TRANS_TABLE_SIZE	4
translate	trans_table[TRANS_TABLE_SIZE] =
{
	{"lt",		'<'},
	{"gt",		'>'},
	{"amp",		'&'},
	{"quot",	'\"'},
};

static char * lower_string (char *src)
{
	char *	psrc	= src;

	while (*psrc)
	{
		*psrc	= tolower (*psrc);
		psrc ++;
	}

	return src;
}

static char * translate_to_normal (char * src)
{
	char	dest[BUFFERSIZE], * pdest, * psrc, * ret;
	char	trans[BUFFERSIZE], * ptrans, transch;
	int		j;

	pdest	= dest;
	psrc	= src;

	while (*psrc)
	{
		if (*psrc != '&')
		{
			*pdest++ = *psrc++;
			continue;
		}
		transch	= ' ';
		psrc ++;
		ptrans	= trans;
		while (*psrc)
		{
			transch	= *psrc ++;
			if (transch == ';' || transch == ' ' || transch == '&')
				break;
			*ptrans++	= transch;
		}
		if (transch != ';' && *psrc != '\0')
			psrc--;
		*ptrans	= '\0';
		if (ptrans != trans && trans[0] == '#')
		{
			transch	= atoi (trans + 1);
			if (transch != 0)
				*pdest++ = transch;	
			continue;
		}
		for (j=0; j < TRANS_TABLE_SIZE; j++)
		{
			lower_string (trans);
			if (!strcmp(trans, trans_table[j].str))
			{
				*pdest++ = trans_table[j].c;
				break;
			}
		}
		if (j < TRANS_TABLE_SIZE)
			continue;
		if (transch == ';')
			psrc --;
		*pdest++	= '&';
		for (ptrans = trans; *ptrans != '\0'; ptrans++)
			*pdest ++ = *ptrans;
	}
	*pdest	= '\0';

	ret		= (char *) alloc_mem (strlen(dest) + 1);
	strcpy (ret, dest);

	return ret;
}

/*
static int get_char()	
{
	int	c = saved;

	if (c != -2)
	{
		saved	= -2;
		return c;
	}

	c = fgetc(finput);
	if (c == '\\')
		return fgetc(finput);

	while (c != EOF && c == '!')
	{
		c	= fgetc (finput);
		while (c != EOF && c != '\r' && c != '\n')
			c	= fgetc (finput);
		while ((c != EOF) && (c == ' ' || c == '\t' || c == '\n' || c == '\r'))
			c	= fgetc (finput);
	}
}
*/

static int get_char(void)
{
	return fgetc(finput);
}

static int jump_space ()
{
	int	c = get_char();

	while ((c != EOF) && (c == ' ' || c == '\t' || c == '\n' || c == '\r'))
		c = get_char();

	return c;
}

static int is_stop_character (int c)
{
	return (c == ' ' || c == '\t' || c == '\n' || c == '=' || c == '>' || c == EOF || c == '\r' || c == '/');
}

static char * parse_token ()
{
	char buf[BUFFERSIZE], * p = buf;
	int	c = jump_space ();

	if (c == EOF)
		return NULL;
	while (!is_stop_character(c))
	{
		if (c == '\"')
		{
			c	= get_char ();
			if (c == EOF)
				return NULL;
			while (c != '\"')
			{
				*p++	= c;
				c	= get_char ();
				if (c == EOF)
					return NULL;
			}
		}
		else
			*p++	= c;
		c	= get_char ();
	}
	
	ungetc(c,finput);
	if (p == buf)
		return NULL;

	*p		= '\0';
	
	return translate_to_normal(buf);
}

void set_source (FILE *input)
{
	finput	= input;
}

sgml_type * my_create_sgml (void)
{
	char				ch, * next_token;
	sgml_type *			s;
	sgml_property_type *sp;
	
	if (finput == NULL)
		return NULL;

	ch	= jump_space ();
	if (ch == EOF)
		return NULL;

	s	= (sgml_type *) alloc_mem (sizeof(sgml_type));
	if (s == NULL)
		return NULL;
	
	if (ch != '<')		/* literal */
	{
		s -> type		= LITERAL;
		s -> character	= ch;
		s -> properties	= NULL;

		return s;
	}
	
	ch	= get_char ();
	if (ch == EOF)
		return NULL;	/* error   */
	if ((ch == '!')||(ch=='?'))		/* comment */
	{
		char	buf[BUFFERSIZE], *p = buf;

		ch	= get_char ();
		while (ch != EOF && ch != '>')
		{
			*p++	= ch;
			ch		= get_char ();
		}
		if (ch == EOF)
			return NULL;
		*p	= '\0';
		s -> type		= COMMENT;
		s -> comment	= translate_to_normal (buf);
		s -> properties	= NULL;

		return s;
	}

	if (ch == '/')		/* end tag */
	{
		next_token	= parse_token ();
		if (next_token == NULL)
			return NULL;	/* error  */
		if (jump_space () != '>')
			return NULL;	/* error  */
		s -> type		= END_TAG;
		s -> name		= next_token;
		s -> properties	= NULL;
		
		return s;
	}

	ungetc(ch,finput);
	next_token	= parse_token ();

	s -> type	= START_TAG;
	s -> name	= next_token;
	s -> properties	= NULL;

	while ((next_token=parse_token())!=NULL)
	{
		int next_ch;
		sp	= (sgml_property_type *) alloc_mem (sizeof (sgml_property_type));
		sp -> name	= next_token;
		if ((next_ch=get_char()) == '=')
		{
			next_token	= parse_token ();
			if (next_token == NULL)
				sp -> value	=(char *)"";
			else
				sp -> value = next_token;
		}
		else
		{
			sp -> value	= sp -> name;
			ungetc(next_ch,finput);
		}

		if (s -> properties == NULL)
			s -> properties = new_vector ();
		vector_append (s -> properties, (void *)sp);
	}
	ch=jump_space();
	if (ch!='>')
		ungetc(ch,finput);

	return s;
}

sgml_type * create_sgml (void)
{
	sgml_type *p_sgml;
	for (;;)
	{
		p_sgml=my_create_sgml();
		if (p_sgml==NULL)
			break;
		if (p_sgml->type==START_TAG)
			break;
		if (p_sgml->type==END_TAG)
			break;
	}
	return p_sgml;
}

sgml_type * create_empty_sgml (void)
{
	sgml_type	* s;

	s	= (sgml_type *) alloc_mem (sizeof(sgml_type));
	if (s == NULL)
		return NULL;
	s -> type		= LITERAL;
	s -> character	= '\0';
	s -> properties	= NULL;

	return s;
}

void print_sgml (sgml_type *p_sgml)
{
	if (p_sgml == NULL)
	{
		printf ("<NULL>\n");
		return;
	}

	switch (p_sgml -> type)
	{
	case END_TAG:
		printf ("</%s>\n", p_sgml -> name);
		break;
	case LITERAL:
		printf ("%c", p_sgml -> character);
		break;
	case COMMENT:
		printf ("<! %s >\n", p_sgml -> comment);
		break;
	case START_TAG:
		{
			int	i;

			printf ("<%s", p_sgml -> name);
			for (i = 0; i < get_property_length(p_sgml); i++)
			{
				sgml_property_type	* sp;
				sp	= (sgml_property_type *)vector_content(p_sgml -> properties, i);
				printf (" %s=%s", sp -> name, sp -> value);
			}
			printf (">\n");
		}
		break;
	default:
		printf("<Unknown>\n");
	}
	fflush(stdout);
}

void delete_sgml (sgml_type *p_sgml)
{
	if (p_sgml == NULL)
		return;

	if (p_sgml -> properties != NULL)
		delete_vector (p_sgml -> properties);
	free_mem (p_sgml);
}

int get_sgml_type (sgml_type *p_sgml)
{
	return p_sgml -> type;
}

void set_sgml_type (sgml_type *p_sgml, int type)
{
	p_sgml -> type	= type;
}

char * get_sgml_name(sgml_type *p_sgml)
{
	return	p_sgml -> name;
}

void set_sgml_name(sgml_type *p_sgml,char *name)
{
	p_sgml -> name	= name;
}

int get_property_length(sgml_type *p_sgml)
{
	if (p_sgml -> properties == NULL)
		return 0;
	
	return p_sgml -> properties -> length;
}

char *get_property_name(sgml_type *p_sgml,int index)
{
	sgml_property_type	*sp;

	sp	= (sgml_property_type *)vector_content(p_sgml -> properties, index);
	return sp -> name;
}

char *get_property_value(sgml_type *p_sgml,int index)
{
	sgml_property_type	*sp;

	sp	= (sgml_property_type *)vector_content(p_sgml -> properties, index);
	return sp -> value;
}

char *get_property (sgml_type *p_sgml,const char *name)
{
	int	i;

	for (i=0; i < get_property_length(p_sgml); i++)
	{
		/* printf("%d of %d\n",i,get_property_length(p_sgml)); */
		if (!strcmp(get_property_name(p_sgml, i), name))
			return get_property_value(p_sgml, i);
	}
	
	if (!strcmp(name,"name"))
		return get_sgml_name(p_sgml);	

	return NULL;
}

void set_property_value(sgml_type *p_sgml,char *name,char *value)
{
	int	i;
	sgml_property_type	*sp;

	for (i=0; i < get_property_length(p_sgml); i++)
		if (!strcmp(get_property_name(p_sgml, i), name))
			break;
	
	if (i == get_property_length(p_sgml))
		return;

	sp	= (sgml_property_type *)vector_content(p_sgml -> properties, i);
	sp -> value	= value;
}

/*
void main (int argc, char **argv)
{
	FILE	*fp;

	sgml_type	*st1;
	int sgml_no=1;

	if ((fp = fopen ("tables.env", "r")) == NULL)
		exit (1);
	set_source (fp);
	st1	= create_sgml ();
	
	while (st1 != NULL)
	{
		printf("%4d: ",sgml_no++);
		print_sgml (st1);
		printf("\n");
		if (sgml_no==100)
			break;
		delete_sgml (st1);
		st1	= create_sgml ();
	}

	fclose (fp);
}

*/
