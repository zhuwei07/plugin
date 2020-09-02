/* pump.c */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdarg.h>
#include <process.h>
#include <io.h>

char *output_file="";

void my_exit(int status)
{
	_unlink("pumptmp.cpp");
	_unlink("pumptmp.exe");
	_unlink("pumptmp.obj");
	if (status!=0)
		_unlink(output_file);
	exit(status);
}

#define MAX_ARG 30

void run_command(char *format,...)
{
	static char buffer[200];
	int result,status;
	va_list v;
	char *arg_list[MAX_ARG];
	char *args[MAX_ARG];
	int i;
	static char command_buffer[200];
	va_start(v,format);
	vsprintf(buffer,format,v);
	va_end(v);
	/* printf("%s\n",buffer); */
	strcpy(command_buffer,buffer);
	for (i=0;i<MAX_ARG;i++)
	{
		char *this_token;
		if (i==0)
			this_token=strtok(buffer," \t\n");
		else
			this_token=strtok(NULL," \t\n");
		args[i]=this_token;
		if (this_token==NULL)
			break;
	}
/*	for (i=0;args[i]!=NULL;i++)
		printf("args[%d]=%s\n",i,args[i]);*/
	result=_spawnvp(_P_WAIT,args[0],args);
	status=result;
	if (status==0)
		return;
	printf("Failed in running command below:\n\t%s\n",command_buffer);
	my_exit(1);
}

int main(int argc,char *argv[])
{
	char command_buffer[300];
	int i;

	output_file=argv[1];
	if (argc<4)
	{
		fprintf(stderr,"%s <output file> <template file> <enviroment files>\n",argv[0]);
		return 1;
	}
	run_command("tplmake pumptmp.cpp %s",argv[2]);
	run_command("cl -EHsc -nologo pumptmp.cpp pump.lib /link /out:pumptmp.exe");
	sprintf(command_buffer,"pumptmp %s",argv[1]);
	for (i=3;i<argc;i++)
	{
		sprintf(command_buffer+strlen(command_buffer)," %s",argv[i]);
	}	
	//run_command("pumptmp %s %s",argv[1],argv[3]);
	run_command(command_buffer);
	my_exit(0);
	return 0;
}

