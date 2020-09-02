/* pump.h */

#ifndef PUMP_H
#define PUMP_H

extern int use_pump_command;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

void set_value(const char *name,const char *value);
int length(const char * name);
void enter(const char * name);
void enter_set(const char * name,int index);
void enter_son_id(int index);
void leave(void);
void display_name(const char * name);
char *to_string(int value);
int valid_name(const char * name);
void display_string(const char * string);
void display_value(int value);
void display_char(char ch);
void error (void);
char * get_string(const char * name);
void set_line_no(int line_no);
void set_file_name(const char * file_name);

/* string functions */
char *replace(const char *src,const char *from, const char *to);
char *substr(const char *src, int from, int to);
char *addstring(const char *string1,const char *string2);
char *multiaddstring(int n,...);

#endif
