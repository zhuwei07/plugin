!!** suffixes definition!!
.SUFFIXES:  .c .cpp .o .obj .a .lib

!!** platform depend command definition!!
CPP=cl
LINK=link
LIB32=lib 
PREP=cl -nologo -EP
PUMP=pump
COPY=copy /y
DEL=rm
MAKE=nmake
ECHO=echo

.cpp.obj:
	$(CPP) $(CPPFLAGS) $(INCLUDEDIR) -c $< >> output
	move $(@F) $(@D)
!!** platform dependend parameter!!
!!enter system!!
!!enter project!!
!!let am_platform="WINDOWS"!!
!!let am_compiler="MSVC"!!
!!let am_exe_suffix=".exe"!!
!!let am_lib_suffix=".lib"!!
!!let am_dll_suffix=".dll"!!
!!let am_lib_prefix=""!!
!!let am_obj_suffix=".obj"!!
!!let am_dir_convertfrom="/"!!
!!let am_dir_convertto="\\"!!
!!let am_debug_multithread_cppflags="-nologo -EHsc -MTd -Od -Gm -ZI -FD -Zm200"!!
!!let am_debug_singlethread_cppflags="-nologo -EHsc -MLd -Od -Gm -ZI -FD -Zm200"!!
!!let am_release_multithread_cppflags="-nologo -EHsc -MT -O2 -GF -FD"!!
!!let am_release_singlethread_cppflags="-nologo -EHsc -ML -O2 -GF -FD"!!
!!let am_output_ldindicate="-out:"!!
!!let am_implib_ldindicate="-implib:"!!
!!let am_libs="kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib wsock32.lib"!!
!!let am_basic_exe_ldflags="-nologo /FIXED:NO"!!
!!let am_basic_lib_ldflags="-nologo"!!
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
!!let am_libpath="/libpath:"!!
!!let am_libinclude=""!!
!!let am_lib_include_suffix=".lib"!!
!!leave!!
!!leave!!
!!include ../makefile.tpl!!