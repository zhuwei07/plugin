/* database.h */

!!travel tables!!
typedef struct
{
!!travel fields!!
!!if !strcmp(@type,"character")!!
char !!@name!![!!@length!!];
!!elseif !strcmp(@type,"int")||!strcmp(@type,"integer")!!
int !!@name!!;
!!else!!
!!error!!
!!endif!!
!!next!!
}	!!@command!!_record_type;
!!next!!

!!travel tables!!
int add_!!@command!!(!!@command!!_record_type *p_!!@command!!);
!!next!!