!!** suffixes definition!!
.SUFFIXES:  .c .cpp .o .obj .a .lib

!!** platform depend command definition!!
CPP=g++ -fpic
LINK=g++
LIB32=ar -ru
PREP=g++ -E -P
PUMP=pump
COPY=cp
DEL=rm
MAKE=make
ECHO=echo

.cpp.o:
	$(CPP) $(CPPFLAGS) $(INCLUDEDIR) -c $< -o $@ 2>> output

!!** platform dependend parameter!!
!!enter system!!
!!enter project!!
!!let am_platform="HP_UX"!!
!!let am_compiler="GCC"!!
!!let am_exe_suffix=""!!
!!let am_lib_suffix=".a"!!
!!let am_dll_suffix=".so"!!
!!let am_obj_suffix=".o"!!
!!let am_dir_convertfrom="\\"!!
!!let am_dir_convertto="/"!!
!!let am_debug_multithread_cppflags="-O3 -pthread -m64"!!
!!let am_debug_singlethread_cppflags="-O3 -m64"!!
!!let am_release_multithread_cppflags="-O3 -pthread -m64"!!
!!let am_release_singlethread_cppflags="-O3 -m64"!!
!!let am_profile_cppflags="-p"!!
!!let am_output_ldindicate="-o "!!
!!let am_implib_ldindicate="-Xlinker -out-implib="!!
!!let am_libs="-lpthread"!!
!!let am_basic_exe_ldflags=""!!
!!let am_basic_lib_ldflags="-static"!!
!!let am_basic_dll_ldflags="-shared  -Wl,-Bsymbolic"!!
!!let am_debug_ldflags="-O3 -m64"!!
!!let am_map_ldflags=multiaddstring(3,"-Xlinker map=",@target,".map")!!
!!let am_profile_ldflags="-p"!!
!!let am_exit_make="exit 1"!!
!!let am_warning0_cppflags="-w"!!
!!let am_warning1_cppflags=""!!
!!let am_warning2_cppflags="-Wall -Wno-sign-compare"!!
!!let am_warning3_cppflags="-Wall -W -Wfloat-equal -Wcast-qual -Wcast-align -Wconversion -Waggregate-return -Wpacked -Wredundant-decls -Wunreachable-code -Winline"!!
!!let am_warning0_ldflags=@am_warning0_cppflags!!
!!let am_warning1_ldflags=@am_warning1_cppflags!!
!!let am_warning2_ldflags=@am_warning2_cppflags!!
!!let am_warning3_ldflags=@am_warning3_cppflags!!
!!let am_libpath="-L"!!
!!let am_libinclude="-l"!!
!!let am_lib_include_suffix=""!!
!!leave!!
!!leave!!

!!include ../makefile.tpl!!
