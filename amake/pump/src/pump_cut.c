/* pump_cut.c */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

FILE *input_file;
FILE *output_file;
char buffer[10240];

int main(int argc,char *argv[])
{
	const char *dir;
	if (argc<2)
	{
		printf("%s <source_filename>\n",argv[0]);
		return 1;
	}
	if (argc>=3)
		dir=argv[2];
	else
		dir="";
	input_file=fopen(argv[1],"rt");
	if (input_file==NULL)
	{
		printf("can not open source file %s\n",argv[1]);
		return 1;
	}
	output_file=NULL;
	for (;;)
	{
		if (fgets(buffer,10240,input_file)==NULL)
		{
			break;
		}
		if (strncmp(buffer,"----",4))
		{
			if (output_file!=NULL)
				fprintf(output_file,"%s",buffer);
		}
		else
		{
			char *filename;
			char full_filename[100];
			if (output_file!=NULL)
				fclose(output_file);
			output_file=NULL;
			filename=strtok(buffer,"- \n\r");
			if (filename==NULL)
			{
				printf("can not find filename");
				return 1;
			}
			sprintf(full_filename,"%s%s",dir,filename);
			output_file=fopen(full_filename,"wt");
			if (output_file==NULL)
			{
				printf("can not write output file %s\n",filename);
				return 1;
			}
		}
	}
	fclose(input_file);
	if (output_file!=NULL)
		fclose(output_file);
	return 0;
}
