!!** ************************************************************!!
!!** the remain part should same for all the system and compilers!!
!!** ************************************************************!!
!!enter system!!
!!** check pakcage consistent!!
!!travel package!!
	!!let am_packagename=@name!!
	!!enter system!!
		!!let am_findpackage="no"!!
		!!travel project!!
			!!if !strcmp(@name,@am_packagename)!!
				!!if !strcmp(@am_findpackage,"yes")!!
					!!error printf("duplicate package definition for '%s' in project file\n",@name)!!
				!!else!!
					!!let am_findpackage="yes"!!
				!!endif!!
			!!endif!!
		!!next!!
		!!if !strcmp(@am_findpackage,"no")!!
			!!error printf("can not find package definition for '%s' in project file\n",@am_packagename)!!
		!!endif!!
	!!leave!!
!!next!!
!!travel project!!
	!!let am_packagename=@name!!
	!!enter system!!
		!!let am_findpackage="no"!!
		!!travel package!!
			!!if !strcmp(@name,@am_packagename)!!
				!!if !strcmp(@am_findpackage,"yes")!!
					!!error printf("duplicate package definition for '%s' in package file\n",@name)!!
				!!else!!
					!!let am_findpackage="yes"!!
				!!endif!!
			!!endif!!
		!!next!!
		!!if !strcmp(@am_findpackage,"no")!!
			!!error printf("can not find package definition for '%s' in package file\n",@am_packagename)!!
		!!endif!!
	!!leave!!
!!next!!
!!** check version!!
!!travel package!!
	!!let am_packagename=@name!!
	!!travel depend!!
		!!let am_dependname=@name!!
		!!let am_dependversion=@version!!
		!!let am_found="no"!!
		!!enter system!!
			!!travel package!!
				!!if !strcmp(@name,@am_dependname)&&(atoi(@version)>=atoi(@am_dependversion))!!
					!!let am_found="yes"!!
				!!endif!!
			!!next!!
			!!if !strcmp(@am_found,"no")!!
				!!error printf("can not find package '%s.%s' which is required for '%s'\n",@am_dependname,@am_dependversion,@am_packagename)!!
			!!endif!!
		!!leave!!
	!!next!!
!!next!!
!!** check package type!!
!!travel package!!
	!!if strcmp(@type,"cpp")!!
		!!error printf("package type '%s' in pakcage '%s' not supported\n",@type,@name)!!
	!!endif!!
!!next!!
!!** check platform!!
!!travel package!!
	!!if strcmp(@platform,"all")!!
		!!if !strstr(@platform,@am_platform)!!
			!!error printf("package '%s' can not support %s platform\n",@name,@am_platform)!!
		!!endif!!
	!!endif!!
!!next!!
!!** check parameter!!
!!travel project!!
	!!let am_packagename=@name!!
	!!travel self!!
		!!let am_parametername=@name!!
		!!enter system!!
		!!travel package!!
			!!if !strcmp(@am_packagename,@name)!!
				!!let am_found="no"!!
				!!travel parameter!!
					!!if !strcmp(@am_parametername,@name)!!
						!!let am_found="yes"!!
					!!endif!!
				!!next!!
				!!if !strcmp(@am_found,"no")!!
					!!error printf("unknown parameter '%s' in package '%s'\n",@am_parametername,@am_packagename)!!
				!!endif!!
			!!endif!!
		!!next!!
		!!leave!!
	!!next!!
!!next!!
!!travel package!!
	!!let am_packagename=@name!!
	!!travel parameter!!
		!!let am_parametername=@name!!
		!!enter system!!
		!!travel project!!
			!!if !strcmp(@am_packagename,@name)!!
				!!let am_found="no"!!
				!!travel self!!
					!!if !strcmp(@am_parametername,@name)!!
						!!let am_found="yes"!!
					!!endif!!
				!!next!!
				!!if !strcmp(@am_found,"no")!!
					!!error printf("parameter '%s' in package '%s' not defined\n",@am_parametername,@am_packagename)!!
				!!endif!!
			!!endif!!
		!!next!!
		!!leave!!
	!!next!!
!!next!!
!!travel package!!
	!!let am_packagename=@name!!
	!!travel command!!
		!!travel self!!
			!!if !strcmp(@type,"parameter")!!
				!!let am_parametername=@value!!
				!!enter system!!
					!!travel package!!
						!!if !strcmp(@am_packagename,@name)!!
							!!let am_found="no"!!
							!!travel parameter!!
								!!if !strcmp(@name,@am_parametername)!!
									!!let am_found="yes"!!
								!!endif!!
							!!next!!
							!!if !strcmp(@am_found,"no")!!
								!!error printf("'%s' is not a parameter of package '%s'\n",@am_parametername,@am_packagename)!!
							!!endif!!
						!!endif!!
					!!next!!
				!!leave!!
			!!endif!!
		!!next!!
	!!next!!
!!next!!


!!** define all compile and link flags!!
!!let am_packagecppflags=" "!!
!!let am_packageldflags=" "!!
!!let am_packagearflags=" "!!
!!let am_packagelibs=" "!!
!!travel package!!
	!!let am_packagecppflags=addstring(@am_packagecppflags,addstring(" ",@cppflags))!!
	!!let am_packageldflags=addstring(@am_packageldflags,addstring(" ",@ldflags))!!
	!!let am_packagearflags=addstring(@am_packagearflags,addstring(" ",@arflags))!!
	!!let am_packagelibs=addstring(@am_packagelibs,addstring(" ",@libs))!!
!!next!!
!!let am_packageworkdir=""!!
!!enter project!!
!!if valid_name("workdir")!!
	!!let am_packageworkdir=multiaddstring(4,".",@am_dir_convertto,@workdir,@am_dir_convertto)!!
!!endif!!
!!if !strcmp(@targettype,"lib")!!
ISLIB=Y
DEFINES=-D!!@am_platform!! -D!!@am_compiler!! -DISLIB
	!!if !strncmp(@target,"lib",3)!!
target=!!@am_packageworkdir!!!!@target!!!!@am_lib_suffix!!
	!!else!!
target=!!@am_packageworkdir!!!!@am_lib_prefix!!!!@target!!!!@am_lib_suffix!!
	!!endif!!
!!elseif !strcmp(@targettype,"exe")!!
ISLIB=N
DEFINES=-D!!@am_platform!! -D!!@am_compiler!!
target=!!@am_packageworkdir!!!!@target!!!!@am_exe_suffix!!
!!elseif !strcmp(@targettype,"dll")!!
ISLIB=Y
DEFINES=-D!!@am_platform!! -D!!@am_compiler!! -DISLIB
	!!if !strncmp(@target,"lib",3)!!
target=!!@am_packageworkdir!!!!@target!!!!@am_dll_suffix!!
	!!else!!
target=!!@am_packageworkdir!!!!@am_lib_prefix!!!!@target!!!!@am_dll_suffix!!
	!!endif!!
!!else!!
!!error printf("unknown target type:%s",@targettype)!!
!!endif!!

!!if !strcmp(@hasdebug,"yes")!!
DEBUG_DEFINE=-DDEBUG -DDEBUG_LOG
!!else!!
DEBUG_DEFINE=
!!endif!!

!!if !strcmp(@hasdebug,"yes")&&!strcmp(@multithread,"yes")!!
APPEND_CPPFLAGS=!!@am_debug_multithread_cppflags!!
!!elseif !strcmp(@hasdebug,"yes")&&!strcmp(@multithread,"no")!!
APPEND_CPPFLAGS=!!@am_debug_singlethread_cppflags!!
!!elseif !strcmp(@hasdebug,"no")&&!strcmp(@multithread,"yes")!!
APPEND_CPPFLAGS=!!@am_release_multithread_cppflags!!
!!elseif !strcmp(@hasdebug,"no")&&!strcmp(@multithread,"no")!!
APPEND_CPPFLAGS=!!@am_release_singlethread_cppflags!!
!!endif!!

!!if !strcmp(@hasprofile,"yes")!!
PROFILE_CPPFLAGS=!!@am_profile_cppflags!!
!!else!!
PROFILE_CPPFLAGS=
!!endif!!

!!if atoi(@warninglevel)==0!!
WARNING_CPPFLAGS=!!@am_warning0_cppflags!!
!!elseif atoi(@warninglevel)==1!!
WARNING_CPPFLAGS=!!@am_warning1_cppflags!!
!!elseif atoi(@warninglevel)==2!!
WARNING_CPPFLAGS=!!@am_warning2_cppflags!!
!!elseif atoi(@warninglevel)==3!!
WARNING_CPPFLAGS=!!@am_warning3_cppflags!!
!!else!!
WARNING_CPPFLAGS=
!!endif!!

CPPFLAGS= !!@cppflags!! !!@am_packagecppflags!! $(APPEND_CPPFLAGS) $(PROFILE_CPPFLAGS) $(WARNING_CPPFLAGS) $(DEBUG_DEFINE) $(DEFINES)

LIBS= !!@am_libs!! !!@libs!! !!@am_packagelibs!!

!!if !strcmp(@hasdebug,"yes")!!
DEBUG_LDFLAGS=!!@am_debug_ldflags!!
!!else!!
DEBUG_LDFLAGS=
!!endif!!

!!if !strcmp(@hasmap,"yes")!!
MAP_LDFLAGS=!!@am_map_ldflags!!
!!else!!
MAP_LDFLAGS=
!!endif!!

!!if !strcmp(@hasprofile,"yes")!!
PROFILE_LDFLAGS=!!@am_profile_ldflags!!
!!else!!
PROFILE_LDFLAGS=
!!endif!!

!!if atoi(@warninglevel)==0!!
WARNING_LDFLAGS=!!@am_warning0_ldflags!!
!!elseif atoi(@warninglevel)==1!!
WARNING_LDFLAGS=!!@am_warning1_ldflags!!
!!elseif atoi(@warninglevel)==2!!
WARNING_LDFLAGS=!!@am_warning2_ldflags!!
!!elseif atoi(@warninglevel)==3!!
WARNING_LDFLAGS=!!@am_warning3_ldflags!!
!!else!!
WARNING_LDFLAGS=
!!endif!!

LDFLAGS=!!@ldflags!! !!@am_packageldflags!! !!@am_basic_exe_ldflags!! $(MAP_LDFLAGS) $(DEBUG_LDFLAGS) $(PROFILE_LDFLAGS) $(WARNING_LDFLAGS)

LIBARFLAGS=!!@arflags!! !!@am_packagearflags!! !!@am_basic_lib_ldflags!! $(MAP_LDFLAGS) $(DEBUG_LDFLAGS) $(PROFILE_LDFLAGS)

DLLARFLAGS=!!@arflags!! !!@am_packagearflags!! !!@am_basic_dll_ldflags!! $(MAP_LDFLAGS) $(DEBUG_LDFLAGS) $(PROFILE_LDFLAGS)

!!leave!!

!!** high level dependencies!!
all: code

code: clearoutput $(target)

clearoutput:
	@$(ECHO) Compiling... > output

!!** defines for all packages!!
!!travel package!!
!!let am_packagename=@name!!
!!let am_packageincludedir=replace(@includedir,@am_dir_convertfrom,@am_dir_convertto)!!
!!enter system!!
	!!travel project!!
		!!if !strcmp(@am_packagename,@name)!!
			!!let am_basedir=replace(@dir,@am_dir_convertfrom,@am_dir_convertto)!!
		!!endif!!
	!!next!!
!!leave!!
!!@name!!_obj=!!travel cppfile!! !!@am_basedir!!!!@am_dir_convertto!!!!show_string replace(@name,".cpp",@am_obj_suffix)!! !!next!!
!!if valid_name("libfile")!!
!!@name!!_lib=!!@am_libpath!!!!@am_basedir!!!!@am_dir_convertto!!!!travel libfile!! !!@am_libinclude!!!!@name!!!!@am_lib_include_suffix!!!!next!!
!!endif!!
!!@name!!_include=!!travel headfile!! !!@am_basedir!!!!@am_dir_convertto!!!!@name!! !!next!!
!!@name!!_includedir=-I!!@am_basedir!!!!@am_dir_convertto!!!!@am_packageincludedir!!
!!next!!

!!** defines for whole project!!
all_objs=!!travel project!! $(!!@name!!_obj) !!next!!
all_libs=!!travel project!! $(!!@name!!_lib) !!next!!
INCLUDEDIR=!!travel project!! $(!!@name!!_includedir) !!next!!

!!** all obj dependencies!!
!!travel package!!
	!!let am_packagename=@name!!
	!!enter system!!
		!!travel project!!
			!!if !strcmp(@am_packagename,@name)!!
				!!let am_basedir=replace(@dir,@am_dir_convertfrom,@am_dir_convertto)!!
			!!endif!!
		!!next!!
	!!leave!!
	!!let am_dependinclude=" "!!
	!!travel depend!!
	!!let am_dependinclude=addstring(@am_dependinclude,addstring(" $(",addstring(@name,"_include)")))!!
	!!next!!
	!!travel cppfile!!
!!@am_basedir!!!!@am_dir_convertto!!!!show_string replace(@name,".cpp",@am_obj_suffix)!!: !!@am_basedir!!!!@am_dir_convertto!!!!@name!! $(!!@am_packagename!!_include) !!@am_dependinclude!!
	!!next!!
!!next!!

!!** all custom dependencies!!
!!let am_copytargetall=" "!!
!!let am_pumptargetall=" "!!
!!travel package!!
	!!let am_packagename=@name!!
	!!travel command!!
		!!let am_command=@name!!
		!!if !strcmp(@name,"copy")!!
			!!let am_copysource="notdefined"!!
			!!let am_copytarget="notdefined"!!
		!!elseif !strcmp(@name,"pump")!!
			!!let am_pumptarget="notdefined"!!
			!!let am_pumptpl="notdefined"!!
			!!let am_pumpenv="notdefined"!!
		!!else!!
			!!error printf("unknown command '%s' in package '%s'\n",@name,@am_packagename)!!
		!!endif!!
		!!travel self!!
			!!if !strcmp(@type,"parameter")!!
				!!let am_parametername=@value!!
				!!enter system!!
				!!travel project!!
					!!if !strcmp(@name,@am_packagename)!!
						!!travel self!!
							!!if !strcmp(@name,@am_parametername)!!
								!!let am_argumentvalue=replace(@value,@am_dir_convertfrom,@am_dir_convertto)!!
							!!endif!!
						!!next!!
					!!endif!!
				!!next!!
				!!leave!!
			!!elseif !strcmp(@type,"file")!!
				!!let am_filename=replace(@value,@am_dir_convertfrom,@am_dir_convertto)!!
				!!enter system!!
				!!travel project!!
					!!if !strcmp(@name,@am_packagename)!!
						!!let am_argumentvalue=multiaddstring(3,replace(@dir,@am_dir_convertfrom,@am_dir_convertto),@am_dir_convertto,@am_filename)!!
					!!endif!!
				!!next!!
				!!leave!!
			!!else!!
				!!error printf("unknown type '%s' in package '%s'\n",@type,@am_packagename)!!
			!!endif!!
			!!let am_argumentvalue=replace(@am_argumentvalue,@am_dir_convertfrom,@am_dir_convertto)!!
			!!if !strcmp(@am_command,"copy")!!
				!!if !strcmp(@name,"source")!!
					!!let am_copysource=@am_argumentvalue!!
				!!elseif !strcmp(@name,"target")!!
					!!let am_copytarget=@am_argumentvalue!!
				!!else!!
					!!error printf("'%s' is not an argument of command 'copy' in package '%s'\n",@name,@am_packagename)!!
				!!endif!!
			!!elseif !strcmp(@am_command,"pump")!!
				!!if !strcmp(@name,"target")!!
					!!let am_pumptarget=@am_argumentvalue!!
				!!elseif !strcmp(@name,"template")!!
					!!let am_pumptpl=@am_argumentvalue!!
				!!elseif !strcmp(@name,"env")!!
					!!let am_pumpenv=@am_argumentvalue!!
				!!else!!
					!!error printf("'%s' is not an argument of command 'pump' in package '%s'\n",@name,@am_packagename)!!
				!!endif!!
			!!endif!!
		!!next!!
		!!if !strcmp(@am_command,"copy")!!
			!!if !strcmp(@am_copysource,"notdefined")!!
				!!error printf("source not defined for copy command in package '%s'",@am_packagename)!!
			!!elseif !strcmp(@am_copytarget,"notdefined")!!
				!!error printf("target not defined for copy command in package '%s'",@am_packagename)!!
			!!endif!!
			!!let am_copytargetall=addstring(@am_copytargetall,addstring(" ",@am_copytarget))!!
!!@am_copytarget!!:!!@am_copysource!!
	$(COPY) !!@am_copysource!! !!@am_copytarget!! >> output
		!!elseif !strcmp(@am_command,"pump")!!
			!!if !strcmp(@am_pumptarget,"notdefined")!!
				!!error printf("target not defined for pump command in package '%s'",@am_packagename)!!
			!!elseif !strcmp(@am_pumptpl,"notdefined")!!
				!!error printf("template not defined for pump command in package '%s'",@am_packagename)!!
			!!elseif !strcmp(@am_pumpenv,"notdefined")!!
				!!error printf("env not defined for pump command in package '%s'",@am_packagename)!!
			!!endif!!
			!!let am_pumptargetall=multiaddstring(3,@am_pumptargetall," ",@am_pumptarget)!!
!!@am_pumptarget!!:!!@am_pumptpl!! !!@am_pumpenv!!
	$(PUMP) !!@am_pumptarget!! !!@am_pumptpl!! !!@am_pumpenv!! >> output
		!!endif!!
	!!next!!
!!next!!
copytargetall=!!@am_copytargetall!!
pumptargetall=!!@am_pumptargetall!!

!!** link command!!
!!enter project!!
!!if !strcmp(@targettype,"dll")!!
	!!if !strcmp(@am_platform,"WINDOWS")!!
$(target): $(all_objs)
	$(LINK) $(DLLARFLAGS) !!@am_output_ldindicate!!$@ !!@am_implib_ldindicate!!!!@am_packageworkdir!!!!@target!!!!@am_lib_suffix!! $(all_objs) $(all_libs) $(LIBS) >> output	
	!!else!!
$(target): $(all_objs)
	$(LINK) $(DLLARFLAGS) !!@am_output_ldindicate!!$@ $(all_objs) $(all_libs) $(LIBS) >> output	
	!!endif!!
!!elseif !strcmp(@targettype,"exe")!!
$(target): $(all_objs)
	$(LINK) $(LDFLAGS) !!@am_output_ldindicate!!$@ $(all_objs) $(all_libs) $(LIBS) >> output
!!elseif !strcmp(@targettype,"lib")!!
$(target): $(all_objs)
	$(LIB32) $(LIBARFLAGS) !!@am_output_ldindicate!!$@ $(all_objs) >> output
!!endif!!

!!leave!!

!!** clean command!!
!!enter project!!
clean:
	!!travel self!!
	-$(DEL) $(!!@name!!_obj)
	!!next!!
	-$(DEL) $(copytargetall)
	-$(DEL) $(pumptargetall)
	-$(DEL) $(target)
	!!if !strcmp(@targettype,"dll")!!
	-$(DEL) !!@am_packageworkdir!!!!@target!!!!@am_lib_suffix!!
	!!endif!!
!!leave!!

!!** pump command!!
pump: $(pumptargetall)

!!leave!!
