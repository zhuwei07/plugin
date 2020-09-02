/* database.h */

typedef struct
{
char user_name[80];
char password[80];
int user_id;
int group_id;
}	user_record_type;
typedef struct
{
char group_name[80];
int group_id;
}	group_record_type;

int add_user(user_record_type *p_user);
int add_group(group_record_type *p_group);
