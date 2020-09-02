!!enter system!!
!!enter project!!
!!let projectName=@target!!
!!leave!!
----!!@projectName!!.dsp
!!** platform dependend parameter!!
!!let am_platform="WINDOWS"!!
!!let am_compiler="MSVC"!!
!!let am_exe_suffix=".exe"!!
!!let am_lib_suffix=".lib"!!
!!let am_dll_suffix=".dll"!!
!!let am_obj_suffix=".obj"!!
!!let am_dir_convertfrom="/"!!
!!let am_dir_convertto="\\"!!
!!let am_debug_multithread_cppflags="-nologo -GX -MTd -Od -Yd -Gm -ZI -FD -Zm200"!!
!!let am_debug_singlethread_cppflags="-nologo -GX -MLd -Od -Yd -Gm -ZI -FD -Zm200"!!
!!let am_release_multithread_cppflags="-nologo -GX -MT -O2 -GF -FD"!!
!!let am_release_singlethread_cppflags="-nologo -GX -ML -O2 -GF -FD"!!
!!let am_output_ldindicate="-out:"!!
!!let am_implib_ldindicate="-implib:"!!
!!let am_libs="kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib wsock32.lib"!!
!!let am_basic_exe_ldflags="-nologo /FIXED:NO"!!
!!let am_basic_lib_ldflags="-nologo "!!
!!let am_basic_dll_ldflags="-nologo /dll"!!
!!let am_debug_ldflags="/DEBUG"!!
!!let am_map_ldflags="/MAP /MAPINFO:EXPORTS /MAPINFO:FIXUPS /MAPINFO:LINES"!!
!!let am_profile_ldflags="/PROFILE"!!
!!let am_exit_make="exit /b 1"!!
!!let am_warning0_cppflags="-W0"!!
!!let am_warning1_cppflags="-W1"!!
!!let am_warning2_cppflags="-W3"!!
!!let am_warning3_cppflags="-W4"!!
!!let am_warning0_ldflags="/WARN:0"!!
!!let am_warning1_ldflags="/WARN:1"!!
!!let am_warning2_ldflags="/WARN:2"!!
!!let am_warning3_ldflags="/WARN:3"!!
!!** *****************************************define all compile and link flags!!
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
!!let am_debug_define="-DDEBUG -DDEBUG_LOG"!!
!!if !strcmp(@multithread,"yes")!!
	!!let am_release_append_cppflags=@am_release_multithread_cppflags!!
	!!let am_debug_append_cppflags=@am_debug_multithread_cppflags!!
!!else!!
	!!let am_release_append_cppflags=@am_release_singlethread_cppflags!!
	!!let am_debug_append_cppflags=@am_debug_singlethread_cppflags!!
!!endif!!
!!if !strcmp(@hasprofile,"yes")!!
	!!let am_profile_cppflags=@am_profile_cppflags!!
!!else!!
	!!let am_profile_cppflags=" "!!
!!endif!!
!!if atoi(@warninglevel)==0!!
	!!let am_warning_cppflags=@am_warning0_cppflags!!
!!elseif atoi(@warninglevel)==1!!
	!!let am_warning_cppflags=@am_warning1_cppflags!!
!!elseif atoi(@warninglevel)==2!!
	!!let am_warning_cppflags=@am_warning2_cppflags!!
!!elseif atoi(@warninglevel)==3!!
	!!let am_warning_cppflags=@am_warning3_cppflags!!
!!else!!
	!!let am_warning_cppflags=" "!!
!!endif!!
!!** ***********************************************define for include directories!!
!!let am_include_dir=" "!!
!!enter system!!
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
	!!let am_include_dir=multiaddstring(5,@am_include_dir," -I",@am_basedir,@am_dir_convertto,@am_packageincludedir)!!
	!!if valid_name("libfile")!!
	!!travel libfile!! !!let am_packagelibs=multiaddstring(4," ",@name,@am_lib_suffix,@am_packagelibs)!! !!next!!
	!!let am_packagelibs=multiaddstring(3," /libpath:",@am_basedir,@am_packagelibs)!!
	!!endif!!
!!next!!
!!leave!!
!!let am_all_libs=multiaddstring(5,@am_libs," ",@libs," ",@am_packagelibs)!!
!!if !strcmp(@hasmap,"yes")!!
	!!let am_map_ldflags=@am_map_ldflags!!
!!else!!
	!!let am_map_ldflags=" "!!
!!endif!!
!!if !strcmp(@hasprofile,"yes")!!
	!!let am_profile_ldflags=@am_profile_ldflags!!
!!else!!
	!!let am_profile_ldflags=" "!!
!!endif!!
!!if atoi(@warninglevel)==0!!
	!!let am_warning_ldflags=@am_warning0_ldflags!!
!!elseif atoi(@warninglevel)==1!!
	!!let am_warning_ldflags=@am_warning1_ldflags!!
!!elseif atoi(@warninglevel)==2!!
	!!let am_warning_ldflags=@am_warning2_ldflags!!
!!elseif atoi(@warninglevel)==3!!
	!!let am_warning_ldflags=@am_warning3_ldflags!!
!!else!!
	!!let am_warning_ldflags=" "!!
!!endif!!
!!if !strcmp(@targettype,"lib")!!
	!!let am_islib="Y"!!
	!!let am_all_libs=""!!	
	!!let am_defines=multiaddstring(5,"-D",@am_platform," -D",@am_compiler," -DISLIB")!!
	!!let am_target=multiaddstring(2,@target,@am_lib_suffix)!!
	!!let am_release_ldflags=multiaddstring(7,@am_packagearflags," ",@am_basic_lib_ldflags," ",@am_map_ldflags," ",@am_profile_ldflags)!!
	!!let am_debug_ldflags=multiaddstring(9,@am_packagearflags," ",@am_basic_lib_ldflags," ",@am_map_ldflags," ",@am_debug_ldflags," ",@am_profile_ldflags)!!	
	!!let applicationtype="Static Library"!!
!!elseif !strcmp(@targettype,"exe")!!
	!!let am_islib="N"!!
	!!let am_defines=multiaddstring(4,"-D",@am_platform," -D",@am_compiler)!!
	!!let am_target=multiaddstring(2,@target,@am_exe_suffix)!!
	!!let am_release_ldflags=multiaddstring(9,@am_packageldflags," ",@am_basic_exe_ldflags," ",@am_map_ldflags," ",@am_profile_ldflags," ",@am_warning_ldflags)!!
	!!let am_debug_ldflags=multiaddstring(11,@am_packageldflags," ",@am_basic_exe_ldflags," ",@am_map_ldflags," ",@am_profile_ldflags," ",@am_debug_ldflags," ",@am_warning_ldflags)!!
	!!let applicationtype="Console Application"!!	
!!elseif !strcmp(@targettype,"dll")!!
	!!let am_islib="Y"!!
	!!let am_defines=multiaddstring(5,"-D",@am_platform," -D",@am_compiler," -DISLIB")!!
	!!let am_target=multiaddstring(2,@target,@am_dll_suffix)!!
	!!let am_release_ldflags=multiaddstring(7,@am_packagearflags," ",@am_basic_dll_ldflags," ",@am_map_ldflags," ",@am_profile_ldflags)!!
	!!let am_debug_ldflags=multiaddstring(7,@am_packagearflags," ",@am_basic_dll_ldflags," ",@am_map_ldflags," ",@am_debug_ldflags," ",@am_profile_ldflags)!!
	!!let am_implib=multiaddstring(2,@target,@am_lib_suffix)!!
	!!let applicationtype="Dynamic-Link Library"!!	
!!else!!
	!!error printf("unknown target type:%s",@targettype)!!
!!endif!!
!!let am_release_cppflags=multiaddstring(11,@cppflags," ",@am_packagecppflags," ",@am_release_append_cppflags," ",@am_profile_cppflags," ",@am_warning_cppflags," ",@am_defines)!!
!!let am_debug_cppflags=multiaddstring(13,@cppflags," ",@am_packagecppflags," ",@am_debug_append_cppflags," ",@am_profile_cppflags," ",@am_warning_cppflags," ",@am_debug_define," ",@am_defines)!!
!!leave!!
# Microsoft Developer Studio Project File - Name="!!@projectName!!" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=!!@projectName!! - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "!!@projectName!!.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "!!@projectName!!.mak" CFG="!!@projectName!! - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "!!@projectName!! - Win32 Release" (based on "Win32 (x86) !!@applicationtype!!")
!MESSAGE "!!@projectName!! - Win32 Debug" (based on "Win32 (x86) !!@applicationtype!!")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "!!@projectName!! - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP !!@am_release_cppflags!! /c
# ADD CPP !!@am_release_cppflags!! !!@am_include_dir!! /c
# ADD BASE RSC /l 0x804 /d "NDEBUG"
# ADD RSC /l 0x804 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
!!enter project!!
!!if !strcmp(@targettype,"lib")!!
LIB32=lib.exe
# ADD BASE LIB32 !!@am_release_ldflags!!
# ADD LIB32 !!@am_release_ldflags!! /out:"!!@am_packageworkdir!!!!@am_target!!"
!!elseif !strcmp(@targettype,"exe")!!
LINK32=link.exe
# ADD BASE LINK32 !!@am_all_libs!! !!@am_release_ldflags!!
# ADD LINK32 !!@am_release_ldflags!! !!@am_all_libs!! /out:"!!@am_packageworkdir!!!!@am_target!!"
!!elseif !strcmp(@targettype,"dll")!!
LINK32=link.exe
# ADD BASE LINK32 !!@am_all_libs!! !!@am_release_ldflags!!
# ADD LINK32 !!@am_release_ldflags!! !!@am_all_libs!! /out:"!!@am_packageworkdir!!!!@am_target!!"  /implib:"!!@am_packageworkdir!!!!@am_implib!!"
!!else!!
	!!error printf("unknown target type:%s",@targettype)!!
!!endif!!
!!leave!!

!ELSEIF  "$(CFG)" == "!!@projectName!! - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP !!@am_debug_cppflags!!  /c
# ADD CPP !!@am_debug_cppflags!! !!@am_include_dir!! /c
# ADD BASE RSC /l 0x804 /d "_DEBUG"
# ADD RSC /l 0x804 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
!!enter project!!
!!if !strcmp(@targettype,"lib")!!
LIB32=lib.exe
# ADD BASE LIB32 !!@am_debug_ldflags!!
# ADD LIB32 !!@am_debug_ldflags!! /out:"!!@am_packageworkdir!!!!@am_target!!"
!!elseif !strcmp(@targettype,"exe")!!
LINK32=link.exe
# ADD BASE LINK32 !!@am_all_libs!! !!@am_debug_ldflags!!
# ADD LINK32 !!@am_debug_ldflags!! !!@am_all_libs!! /out:"!!@am_packageworkdir!!!!@am_target!!"
!!elseif !strcmp(@targettype,"dll")!!
LINK32=link.exe
# ADD BASE LINK32 !!@am_all_libs!! !!@am_debug_ldflags!!
# ADD LINK32 !!@am_debug_ldflags!! !!@am_all_libs!! /out:"!!@am_packageworkdir!!!!@am_target!!"  /implib:"!!@am_packageworkdir!!!!@am_implib!!"
!!else!!
	!!error printf("unknown target type:%s",@targettype)!!
!!endif!!
!!leave!!

!ENDIF 

# Begin Target

# Name "!!@projectName!! - Win32 Release"
# Name "!!@projectName!! - Win32 Debug"

!!travel package!!
!!let am_packagename=@name!!
!!enter system!!
	!!travel project!!
		!!if !strcmp(@am_packagename,@name)!!
			!!let am_basedir=replace(@dir,@am_dir_convertfrom,@am_dir_convertto)!!
		!!endif!!
	!!next!!
!!leave!!
# Begin Group "!!@name!!"

# PROP Default_Filter ""
!!travel cppfile!!
# Begin Source File

SOURCE=!!@am_basedir!!!!@am_dir_convertto!!!!@name!!
# End Source File
!!next!!
!!travel headfile!!
# Begin Source File

SOURCE=!!@am_basedir!!!!@am_dir_convertto!!!!@name!!
# End Source File
!!next!!
# End Group

!!next!!
# End Target
# End Project

----!!@projectName!!.dsw
Microsoft Developer Studio Workspace File, Format Version 6.00
# WARNING: DO NOT EDIT OR DELETE THIS WORKSPACE FILE!

###############################################################################

Project: "!!@projectName!!"=".\!!@projectName!!.dsp" - Package Owner=<4>

Package=<5>
{{{
}}}

Package=<4>
{{{
}}}

###############################################################################

Global:

Package=<5>
{{{
}}}

Package=<3>
{{{
}}}

###############################################################################
!!leave!!