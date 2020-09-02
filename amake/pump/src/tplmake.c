/* tplmake.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>

#define MAX_LINE 8192
#define MAX_DEPTH 30

#ifdef WINDOWS
#define DIR '\\'
#define ENV_SPLIT ";"
#endif

#ifdef UNIX
#define DIR '/'
#define ENV_SPLIT ":"
#endif

int output_depth=0;
int pump_depth=0;
int comment_level=0;
int isFunction=0;

typedef struct
{
	FILE *input;
	char *inputFileName;
	char *inputDisplayFileName;
	int lineNo;
}	TInputRef;

void do_generation(TInputRef *pInputRef);

void error(const char *format,...)
{
	char buffer[MAX_LINE*2];
	va_list v;
	va_start(v,format);
	vsprintf(buffer,format,v);
	va_end(v);
	fprintf(stderr,"%s\n",buffer);
	exit(1);
}

typedef struct
{
	char *stringBuffer;
	int stringBufferLength;
	int stringBufferSize;
}	TLongStringBuffer;

#define BUFFER_INC_SIZE 1000000

TLongStringBuffer generateBuffer, functionBuffer;

void initStringBuffer(TLongStringBuffer *pBuffer)
{
	pBuffer->stringBuffer=(char *)malloc(BUFFER_INC_SIZE);
	if (pBuffer->stringBuffer==NULL)
	{
	}
	pBuffer->stringBufferLength=0;
	pBuffer->stringBufferSize=BUFFER_INC_SIZE;
}

void append(TLongStringBuffer *pBuffer,const char *info)
{
	while (pBuffer->stringBufferLength+strlen(info)>=pBuffer->stringBufferSize)
	{
		pBuffer->stringBuffer=(char *)realloc(pBuffer->stringBuffer,
			pBuffer->stringBufferSize+BUFFER_INC_SIZE);
		if (pBuffer->stringBuffer==NULL)
		{
			error("not sufficient memory");
		}
		pBuffer->stringBufferSize+=BUFFER_INC_SIZE;
	}
	strcpy(pBuffer->stringBuffer+pBuffer->stringBufferLength,info);
	pBuffer->stringBufferLength+=strlen(info);
}

void writeOutput(TLongStringBuffer *pBuffer,FILE *output)
{
	fprintf(output,"%s",pBuffer->stringBuffer);
}

void generation_error(TInputRef *pInputRef,const char *msg)
{
	error("%s in file %s line %d",msg,pInputRef->inputFileName, pInputRef->lineNo);
}

void display(TInputRef *pInputRef, const char *format,...)
{
	char buffer[MAX_LINE*2];
	int i;
	va_list v;
	if (comment_level>0)
		return;
	sprintf(buffer,"#line %d \"%s\"\n",pInputRef->lineNo,pInputRef->inputDisplayFileName);
	append(&generateBuffer,buffer);
	for (i=0;i<output_depth;i++)
		append(&generateBuffer,"\t");
	va_start(v,format);
	vsprintf(buffer,format,v);
	va_end(v);
	strcat(buffer,"\n");
	append(&generateBuffer,buffer);
}

void displayGenerateHead(void)
{
	char buffer[MAX_LINE*2];
	append(&generateBuffer,"void pump(void)\n");
	append(&generateBuffer,"{\n");
	output_depth++;
	sprintf(buffer,"\tint tmp_value[%d];\n",MAX_DEPTH);
	append(&generateBuffer,buffer);
}

void displayGenerateTail(void)
{
	output_depth--;
	append(&generateBuffer,"}\n");
}

void displayFunctionHead(void)
{
	append(&functionBuffer,"/* generated file, do not change it */\n");
	append(&functionBuffer,"\n");
	append(&functionBuffer,"#include \"pump.h\"\n");
	append(&functionBuffer,"\n");
}

void displayFunctionTail(void)
{
}

void make_effect_filename(char *dest, char *src);

int findIncludeFile(char *name, TInputRef *pInputRef, TInputRef *pLastInputRef)
{
	char fileNameBuffer[200];
	char displayFileNameBuffer[200];
	FILE *input=NULL;
	char *p;

	///寻找包含文件的位置，首先是根据当前的位置，寻找相应的文件
	strcpy(fileNameBuffer,pLastInputRef->inputFileName);
	p=fileNameBuffer+strlen(fileNameBuffer)-1;
	while (p>=fileNameBuffer)
	{
		if (*p==DIR)
		{
			break;
		}
		p--;
	}
	p++;
	strcpy(p,name);
	input=fopen(fileNameBuffer,"rt");
	
	if (input==NULL)
	{
		///再根据环境变量TPLINC来寻找合适的文件
		char *pEnv;
		char envStringAll[1000];
		char *pathToken;
		
		pEnv=getenv("tplinc");
		if (pEnv!=NULL)
		{
			strcpy(envStringAll,pEnv);
		}
		else
		{
			*envStringAll='\0';
		}
		pathToken=strtok(envStringAll,ENV_SPLIT);
		while (pathToken!=NULL)
		{
			sprintf(fileNameBuffer,"%s%c%s",pathToken,DIR,name);
			input=fopen(fileNameBuffer,"rt");
			if (input!=NULL)
			{
				break;
			}
			pathToken=strtok(NULL,ENV_SPLIT);
		}
		if (input==NULL)
		{
			return 0;
		}
	}
	
	make_effect_filename(displayFileNameBuffer,fileNameBuffer);

	pInputRef->input=input;
	pInputRef->inputFileName=strdup(fileNameBuffer);
	pInputRef->inputDisplayFileName=strdup(displayFileNameBuffer);
	return 1;
}

void process_command(TInputRef *pInputRef, char **ppInput)
{
	char command[80];
	char tail[MAX_LINE];
	char *p_command,*p_tail;
	int checking_name,checked_name;
	char *check_start;

	char *p_input=*ppInput;

	display(pInputRef,"use_pump_command=1;");

	/* step 1: seperate the whole command into command and tail */
	command[0]='\0';
	tail[0]='\0';
	while ((*p_input)&&(isspace(*p_input)))
		p_input++;
	if (*p_input=='@')
	{
		strcpy(command,"@");
		p_input++;
	}
	else
	{
		p_command=command;
		while ((*p_input)&&(isalnum(*p_input)||strchr("_+*-",*p_input)))
		{
			*p_command++=*p_input;
			*p_command='\0';
			p_input++;
		}
	}
	p_tail=tail;
	checking_name=0;
	checked_name=0;
	while ((*p_input)&&(isspace(*p_input)))
		p_input++;
	while (*p_input)
	{
		switch (*p_input)
		{
			case '@':
				check_start=p_tail;
				strcpy(p_tail,"get_string(\"");
				p_tail=tail+strlen(tail);
				checking_name++;
				checked_name=1;
				p_input++;
				continue;
			case '!':
				p_input++;
				if (*p_input=='!')
				{
					p_input++;
					break;
				}
				p_input--;
			default:
				if ((!isalnum(*p_input))&&(*p_input!='.')&&
					(*p_input!='[')&&(*p_input!=']')&&(*p_input!='_')&&
					(checking_name))
				{
					strcpy(p_tail,"\")");
					p_tail=tail+strlen(tail);
					checking_name--;
					if (!strcmp(check_start,"get_string(\"pumpid\")"))
					{
						sprintf(check_start,"tmp_value[%d]",pump_depth-1);
						p_tail=check_start+strlen(check_start);
					}
				}
				*p_tail++=*p_input;
				*p_tail='\0';
				p_input++;
				continue;
		}
		while (checking_name>0)
		{
			strcpy(p_tail,"\")");
			p_tail=tail+strlen(tail);
			checking_name=0;
			if (!strcmp(check_start,"get_string(\"pumpid\")"))
			{
				sprintf(check_start,"tmp_value[%d]",pump_depth-1);
				p_tail=check_start+strlen(check_start);
			}
			checking_name--;
		}
		break;
	}
	p_tail=tail+strlen(tail)-1;
	while ((p_tail>=tail)&&(isspace(*p_tail)))
		p_tail--;
	*(++p_tail)='\0';
	*ppInput=p_input;
	/* generate corresponding output according to the command */
	/* 如果目前在函数定义的情况 */
	if (isFunction)
	{
		if (!strcmp(command,"endfunction"))
		{
			isFunction=0;
			return;
		}
		generation_error(pInputRef,"invalid command inside function define");
	}
	/* 如果目前不在函数定义的情况 */
	if (!strcmp(command,"function"))
	{
		char lineBuffer[200];

		isFunction=1;
		sprintf(lineBuffer,"#line %d \"%s\"\n",pInputRef->lineNo,pInputRef->inputDisplayFileName);
		append(&functionBuffer,lineBuffer);
		return;
	}
	if (!strcmp(command,"if"))
	{
		display(pInputRef,"if (%s)",tail);
		display(pInputRef,"{");
		output_depth++;
		return;
	}
	if (!strcmp(command,"elseif"))
	{
		output_depth--;
		display(pInputRef,"}");
		display(pInputRef,"else if (%s)",tail);
		display(pInputRef,"{");
		output_depth++;
		return;
	}
	if (!strcmp(command,"error"))
	{
		if (*tail)
		{
			display(pInputRef,"%s;",tail);
			display(pInputRef,"printf(\"\\n\");");
		}
		display(pInputRef,"error();");
		return;
	}
	if (!strcmp(command,"command"))
	{
		if (*tail)
		{
			display(pInputRef,"%s;",tail);
		}
		return;
	}
	if (!strcmp(command,"show_string"))
	{
		display(pInputRef,"display_string(%s);",tail);
		return;
	}
	if (!strcmp(command,"show_value"))
	{
		display(pInputRef,"display_value(%s);",tail);
		return;
	}
	if (!strcmp(command,"show_char"))
	{
		display(pInputRef,"display_char(%s);",tail);
		return;
	}
	if (!strcmp(command,"comment")||!strcmp(command,"**"))
	{
		return;
	}
	if (!strcmp(command,"startcomment")||!strcmp(command,"++"))
	{
		comment_level++;
		return;
	}
	if (!strcmp(command,"endcomment")||!strcmp(command,"--"))
	{
		if (comment_level>0)
			comment_level--;
		return;
	}
	if (!strcmp(command,"loop"))
	{
		const char *from_value,*to_value;
		int step_value;
		char *token;
		char direct;
		token=strtok(tail,"; ");
		if (token==NULL)
			from_value="0";
		else
			from_value=token;
		token=strtok(NULL,"; ");
		if (token==NULL)
			to_value="0";
		else
			to_value=token;
		token=strtok(NULL,"; ");
		if (token==NULL)
			step_value=1;
		else
			step_value=atoi(token);
		if (step_value>0)
			direct='<';
		else if (step_value<0)
			direct='>';
		else
			generation_error(pInputRef,"Invalid step value");
		if (output_depth>=MAX_DEPTH)
			generation_error(pInputRef,"Depth too high(Adjust the MAX_DEPTH "
				"macro in tplmake.c)");
		display(pInputRef,"for (tmp_value[%d]=%s;tmp_value[%d]%c=%s;"
			"tmp_value[%d]+=%d)",pump_depth,from_value,pump_depth,direct,
			to_value,pump_depth,step_value);
		display(pInputRef,"{");
		output_depth++;
		pump_depth++;
		return;
	}
	if (!strcmp(command,"let"))
	{
		char *name,*value;
		name=strtok(tail,"=");
		value=strtok(NULL,"");
		if (name==NULL)
			generation_error(pInputRef,"Invalid Null let command");
		if (value!=NULL)
			display(pInputRef,"set_value(\"%s\",%s);",name,value);
		else
			display(pInputRef,"set_value(\"%s\",NULL);",name);
		return;
	}
	if (!strcmp(command,"travel_expr"))
	{
		if (output_depth>=MAX_DEPTH)
			generation_error(pInputRef,"Depth too high(Adjust the MAX_DEPTH "
				"macro in tplmake.c)");
		display(pInputRef,"for (tmp_value[%d]=0;tmp_value[%d]<length(%s);"
			"tmp_value[%d]++)",pump_depth,pump_depth,
			tail,pump_depth);
		display(pInputRef,"{");
		output_depth++;
		pump_depth++;
		display(pInputRef,"enter_set(%s,tmp_value[%d]);",tail,pump_depth-1);
		return;
	}
	if (!strcmp(command,"enter_son_id"))
	{
		display(pInputRef,"enter_son_id(%s);",tail);
		return;
	}
	if (!strcmp(command,"enter_expr"))
	{
		display(pInputRef,"enter(%s);",tail);
		return;
	}
	if (checked_name)
	{
		generation_error(pInputRef,"Illegal usage of @");
	}
	if (!strcmp(command,"travel"))
	{
		if (output_depth>=MAX_DEPTH)
			generation_error(pInputRef,"Depth too high(Adjust the MAX_DEPTH "
				"macro in tplmake.c)");
		display(pInputRef,"for (tmp_value[%d]=0;tmp_value[%d]<length(\"%s\");"
			"tmp_value[%d]++)",pump_depth,pump_depth,
			tail,pump_depth);
		display(pInputRef,"{");
		output_depth++;
		pump_depth++;
		display(pInputRef,"enter_set(\"%s\",tmp_value[%d]);",tail,pump_depth-1);
		return;
	}
	if (!strcmp(command,"@"))
	{
		if (strcmp(tail,"pumpid"))
			display(pInputRef,"display_name(\"%s\");",tail);
		else
			display(pInputRef,"display_value(tmp_value[%d]);",pump_depth-1);
		return;
	}
	if (!strcmp(command,"enter"))
	{
		display(pInputRef,"enter(\"%s\");",tail);
		return;
	}
	if (!strcmp(command,"include"))
	{
		TInputRef includeRef;
		if (!findIncludeFile(tail,&includeRef,pInputRef))
		{
			generation_error(pInputRef,"can not find include file");
		}
		do_generation(&includeRef);
		display(pInputRef,"use_pump_command=1;");
		return;
	}
	/*
	if (tail[0]!='\0')
	{
		generation_error(pInputRef,"Syntax error\n");
	}
	*/
	if (!strcmp(command,"next"))
	{
		display(pInputRef,"leave();");
		output_depth--;
		pump_depth--;
		display(pInputRef,"}");
		return;
	}
	if (!strcmp(command,"endloop"))
	{
		output_depth--;
		pump_depth--;
		display(pInputRef,"}");
		return;
	}
	if (!strcmp(command,"else"))
	{
		output_depth--;
		display(pInputRef,"}");
		display(pInputRef,"else");
		display(pInputRef,"{");
		output_depth++;
		return;
	}
	if (!strcmp(command,"endif"))
	{
		output_depth--;
		display(pInputRef,"}");
		return;
	}
	if (!strcmp(command,"leave"))
	{
		display(pInputRef,"leave();");
		return;
	}
	if (command[0]!='\0')
		generation_error(pInputRef,"Unknown command");
	else
		generation_error(pInputRef,"Empty command");
}

void outputString(TInputRef *pInputRef, char *buffer)
{
	if (!isFunction)
	{
		display(pInputRef,"display_string(\"%s\");",buffer);
	}
	else
	{
		append(&functionBuffer,buffer);
		append(&functionBuffer,"\n");
	}
}

void process_this_line(TInputRef *pInputRef, char *input_line)
{
	char output_buffer[MAX_LINE];
	char *p_output_buffer=output_buffer;
	char *p_input=input_line;
	
	if (isFunction)
	{
		display(pInputRef,"use_pump_command=1;");
	}
	output_buffer[0]='\0';
	while (*p_input)
	{
		switch (*p_input)
		{
			case '\"':
				if (!isFunction)
				{
					strcpy(p_output_buffer,"\\\"");
					p_output_buffer+=2;
				}
				else
				{
					*p_output_buffer++=*p_input;
					*p_output_buffer='\0';
				}
				break;
			case '\t':
				if (!isFunction)
				{
					strcpy(p_output_buffer,"\\t");
					p_output_buffer+=2;
				}
				else
				{
					*p_output_buffer++=*p_input;
					*p_output_buffer='\0';
				}
				break;
			case '\\':
				if (!isFunction)
				{
					strcpy(p_output_buffer,"\\\\");
					p_output_buffer+=2;
				}
				else
				{
					*p_output_buffer++=*p_input;
					*p_output_buffer='\0';
				}
				break;
			case '!':
				p_input++;
				if (*p_input!='!')
				{
					p_input--;
				}
				else
				{
					p_input++;
					if (output_buffer[0]!='\0')
					{
						outputString(pInputRef,output_buffer);
						output_buffer[0]='\0';
						p_output_buffer=output_buffer;
					}
					process_command(pInputRef,&p_input);
					continue;
				}
			default:
				*p_output_buffer++=*p_input;
				*p_output_buffer='\0';
		}
		p_input++;
	}
	if ((output_buffer[0]!='\0')||isFunction)
	{
		outputString(pInputRef,output_buffer);
	}
}

void do_generation(TInputRef *pInputRef)
{
	char input_line[MAX_LINE];
	pInputRef->lineNo=1;
	
	display(pInputRef,"set_file_name(\"%s\");",pInputRef->inputDisplayFileName);

	for (;;)
	{
		if (!fgets(input_line,MAX_LINE,pInputRef->input))
			break;
		if (strtok(input_line,"\n\r")==NULL)
		{
			/*
			line_no++;
			continue;
			*/
			input_line[0]='\0';
		}
		if (strlen(input_line)>=MAX_LINE)
		{
			generation_error(pInputRef,"Line too long(Adjust the MAX_LINE "
				"macro in tplmake.c)");
		}
		display(pInputRef,"set_line_no(%d);",pInputRef->lineNo);
		if (strncmp("#ident",input_line,6))
		{
			process_this_line(pInputRef,input_line);
		}
		display(pInputRef,"display_string(\"\\n\");");
		pInputRef->lineNo++;
	}
}

///将文件名变成C语言中的可以输出的字符串，实际功能是将所有的"\"变成"\\"
///@param	dest	目标字符串
///@param	src	源文件名
void make_effect_filename(char *dest, char *src)
{
	char *from, *to;
	from=src;
	to=dest;
	while (*from)
	{
		if (*from!='\\')
			*to=*from;
		else
		{
			*to++='\\';
			*to='\\';
		}
		from++;
		to++;
	}
	*to='\0';
}

int main(int argc,char *argv[])
{
	char *inputFileName, *outputFileName;
	FILE *input,*output;
	char effectInputFileName[200];
	
	TInputRef inputRef;

	if (argc<3)
	{
		printf("%s <target C file> <source template file>\n",argv[0]);
		return 1;
	}

	inputFileName=argv[2];
	outputFileName=argv[1];

	input=fopen(inputFileName,"rt");
	if (input==NULL)
	{
		error("Can not open source file %s",inputFileName);
	}
	output=fopen(outputFileName,"wt");
	if (output==NULL)
	{
		error("Can not open target file %s",outputFileName);
	}
	make_effect_filename(effectInputFileName,inputFileName);

	inputRef.input=input;
	inputRef.inputFileName=inputFileName;
	inputRef.inputDisplayFileName=effectInputFileName;

	initStringBuffer(&generateBuffer);
	initStringBuffer(&functionBuffer);

	displayGenerateHead();
	displayFunctionHead();

	do_generation(&inputRef);

	displayGenerateTail();
	displayFunctionTail();

	if (output_depth!=0)
		generation_error(&inputRef,"Unclosure control");

	writeOutput(&functionBuffer,output);
	writeOutput(&generateBuffer,output);

	fclose(output);
	fclose(input);

	return 0;
}
