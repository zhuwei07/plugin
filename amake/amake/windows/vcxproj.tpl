!!enter system!!
!!enter project!!
!!let projectName=@target!!
!!leave!!
!!** platform dependend parameter!!
!!let am_platform="WINDOWS"!!
!!let am_compiler="MSVC"!!
!!let am_exe_suffix=".exe"!!
!!let am_lib_suffix=".lib"!!
!!let am_dll_suffix=".dll"!!
!!let am_obj_suffix=".obj"!!
!!let am_dir_convertfrom="/"!!
!!let am_dir_convertto="\\"!!
!!let am_debug_multithread_cppflags="-nologo -EHsc -MTd -Od -Gm -ZI -FD"!!
!!let am_debug_singlethread_cppflags="-nologo -EHsc -MLd -Od -Gm -ZI -FD"!!
!!let am_release_multithread_cppflags="-nologo -EHsc -MT -GF -FD -GL-"!!
!!let am_release_singlethread_cppflags="-nologo -EHsc -ML -GF -FD -GL-"!!
!!let am_output_ldindicate="-out:"!!
!!let am_implib_ldindicate="-implib:"!!
!!let am_libs="kernel32.lib;user32.lib;gdi32.lib;winspool.lib;comdlg32.lib;advapi32.lib;shell32.lib;ole32.lib;oleaut32.lib;uuid.lib;odbc32.lib;odbccp32.lib;wsock32.lib;ws2_32.lib;"!!
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
!!let am_packagelibpaths=" "!!

!!travel package!!
	!!let am_packagecppflags=addstring(@am_packagecppflags,addstring(" ",@cppflags))!!
	!!let am_packageldflags=addstring(@am_packageldflags,addstring(" ",@ldflags))!!
	!!let am_packagearflags=addstring(@am_packagearflags,addstring(" ",@arflags))!!
	!!let am_packagelibs=addstring(@am_packagelibs,addstring(" ",@libs))!!
!!next!!
!!let am_packageworkdir=""!!
!!enter project!!
!!if valid_name("workdir")!!
	!!let am_packageworkdir=@workdir!!
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
	!!let am_include_dir=multiaddstring(5,@am_include_dir,@am_basedir,@am_dir_convertto,@am_packageincludedir,";")!!
	!!if valid_name("libfile")!!
	!!travel libfile!! 
		!!let am_packagelibs=multiaddstring(4,@am_packagelibs,@name,@am_lib_suffix,";")!!  		
	!!next!!
	!!let am_packagelibpaths=multiaddstring(3,@am_packagelibpaths,@am_basedir,";")!!
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
	!!let am_release_flags=multiaddstring(7,@am_packagearflags," ",@am_basic_lib_ldflags," ",@am_map_ldflags," ",@am_profile_ldflags)!!
	!!let am_debug_flags=multiaddstring(9,@am_packagearflags," ",@am_basic_lib_ldflags," ",@am_map_ldflags," ",@am_debug_ldflags," ",@am_profile_ldflags)!!	
	!!let am_configuration_type="StaticLibrary"!!
!!elseif !strcmp(@targettype,"exe")!!
	!!let am_islib="N"!!
	!!let am_defines=multiaddstring(4,"-D",@am_platform," -D",@am_compiler)!!
	!!let am_target=multiaddstring(2,@target,@am_exe_suffix)!!
	!!let am_release_flags=multiaddstring(9,@am_packageldflags," ",@am_basic_exe_ldflags," ",@am_map_ldflags," ",@am_profile_ldflags," ",@am_warning_ldflags)!!
	!!let am_debug_flags=multiaddstring(11,@am_packageldflags," ",@am_basic_exe_ldflags," ",@am_map_ldflags," ",@am_profile_ldflags," ",@am_debug_ldflags," ",@am_warning_ldflags)!!
	!!let am_configuration_type="Application"!!
!!elseif !strcmp(@targettype,"dll")!!
	!!let am_islib="Y"!!
	!!let am_defines=multiaddstring(5,"-D",@am_platform," -D",@am_compiler," -DISLIB")!!
	!!let am_target=multiaddstring(2,@target,@am_dll_suffix)!!
	!!let am_release_flags=multiaddstring(7,@am_packagearflags," ",@am_basic_dll_ldflags," ",@am_map_ldflags," ",@am_profile_ldflags)!!
	!!let am_debug_flags=multiaddstring(7,@am_packagearflags," ",@am_basic_dll_ldflags," ",@am_map_ldflags," ",@am_debug_ldflags," ",@am_profile_ldflags)!!
	!!let am_implib=multiaddstring(2,@target,@am_lib_suffix)!!
	!!let am_configuration_type="DynamicLibrary"!!	
!!else!!
	!!error printf("unknown target type:%s",@targettype)!!
!!endif!!
!!let am_release_cppflags=multiaddstring(11,@cppflags," ",@am_packagecppflags," ",@am_release_append_cppflags," ",@am_profile_cppflags," ",@am_warning_cppflags," ",@am_defines)!!
!!let am_debug_cppflags=multiaddstring(13,@cppflags," ",@am_packagecppflags," ",@am_debug_append_cppflags," ",@am_profile_cppflags," ",@am_warning_cppflags," ",@am_debug_define," ",@am_defines)!!
!!leave!!
----!!@projectName!!.vcxproj
<?xml version="1.0" encoding="utf-8"?>
<Project DefaultTargets="Build" ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup Label="ProjectConfigurations">
    <ProjectConfiguration Include="Debug|Win32">
      <Configuration>Debug</Configuration>
      <Platform>Win32</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include="Release|Win32">
      <Configuration>Release</Configuration>
      <Platform>Win32</Platform>
    </ProjectConfiguration>
  </ItemGroup>
  <PropertyGroup Label="Globals">
    <SccProjectName />
    <SccLocalPath />
  </PropertyGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.Default.props" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'" Label="Configuration">
    <ConfigurationType>!!@am_configuration_type!!</ConfigurationType>
    <UseDebugLibraries>true</UseDebugLibraries>
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'" Label="Configuration">
    <ConfigurationType>!!@am_configuration_type!!</ConfigurationType>
    <UseDebugLibraries>false</UseDebugLibraries>
    <WholeProgramOptimization>true</WholeProgramOptimization>
  </PropertyGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.props" />
  <ImportGroup Label="ExtensionSettings">
  </ImportGroup>
  <ImportGroup Label="PropertySheets" Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
    <Import Project="$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props" Condition="exists('$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props')" Label="LocalAppDataPlatform" />
  </ImportGroup>
  <ImportGroup Label="PropertySheets" Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
    <Import Project="$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props" Condition="exists('$(UserRootDir)\Microsoft.Cpp.$(Platform).user.props')" Label="LocalAppDataPlatform" />
  </ImportGroup>
  <PropertyGroup Label="UserMacros" />
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
    <OutDir>!!@am_packageworkdir!!</OutDir>
    <IntDir>.\Debug\</IntDir>
	<LinkIncremental>true</LinkIncremental>
    <LocalDebuggerWorkingDirectory>!!@am_packageworkdir!!</LocalDebuggerWorkingDirectory>
    <DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>	
  </PropertyGroup>
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
    <OutDir>!!@am_packageworkdir!!</OutDir>
    <IntDir>.\Release\</IntDir>
	<LinkIncremental>false</LinkIncremental>
    <LocalDebuggerWorkingDirectory>!!@am_packageworkdir!!</LocalDebuggerWorkingDirectory>
    <DebuggerFlavor>WindowsLocalDebugger</DebuggerFlavor>	
  </PropertyGroup> 
  <PropertyGroup Label="UserMacros" /> 
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">
    <ClCompile>
      <RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>
      <InlineFunctionExpansion>Default</InlineFunctionExpansion>
      <FunctionLevelLinking>false</FunctionLevelLinking>	  
      <PrecompiledHeader></PrecompiledHeader>
      <WarningLevel>Level3</WarningLevel>
      <Optimization>Disabled</Optimization>
      <PreprocessorDefinitions>DEBUG;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <AdditionalIncludeDirectories>
		!!@am_include_dir!!%(AdditionalIncludeDirectories)
	  </AdditionalIncludeDirectories>	  
    </ClCompile>
    <Link>
      <SubSystem>Console</SubSystem>
	  <AdditionalLibraryDirectories>!!@am_packagelibpaths!!%(AdditionalLibraryDirectories) </AdditionalLibraryDirectories>	
	  <AdditionalDependencies>!!@am_all_libs!!%(AdditionalDependencies)</AdditionalDependencies>
      <GenerateDebugInformation>true</GenerateDebugInformation>
    </Link>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <PrecompiledHeader>
      </PrecompiledHeader>
      <Optimization>MaxSpeed</Optimization>
      <FunctionLevelLinking>true</FunctionLevelLinking>
      <IntrinsicFunctions>true</IntrinsicFunctions>
      <PreprocessorDefinitions>NDEBUG;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <AdditionalIncludeDirectories>!!@am_include_dir!!%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
	  </ClCompile>
    <Link>
      <SubSystem>Console</SubSystem>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <EnableCOMDATFolding>true</EnableCOMDATFolding>
	  <AdditionalLibraryDirectories>!!@am_packagelibpaths!!%(AdditionalLibraryDirectories) </AdditionalLibraryDirectories>
	  <AdditionalDependencies>!!@am_all_libs!!%(AdditionalDependencies)</AdditionalDependencies>
      <OptimizeReferences>true</OptimizeReferences>
    </Link>	
  </ItemDefinitionGroup>    
  <ItemGroup>
!!travel package!!
!!let am_packagename=@name!!
!!enter system!!
	!!travel project!!
		!!if !strcmp(@am_packagename,@name)!!
			!!let am_basedir=replace(@dir,@am_dir_convertfrom,@am_dir_convertto)!!
		!!endif!!
	!!next!!
!!leave!!
!!travel cppfile!!
    <ClCompile Include="!!@am_basedir!!!!@am_dir_convertto!!!!@name!!" >
	<AdditionalOptions Condition="'$(Configuration)|$(Platform)'=='Debug|Win32'">!!@am_release_cppflags!!</AdditionalOptions>
	<AdditionalOptions Condition="'$(Configuration)|$(Platform)'=='Release|Win32'">!!@am_release_cppflags!!</AdditionalOptions>
	</ClCompile>
!!next!!
!!next!!
 </ItemGroup>
  <ItemGroup>
!!travel package!!
!!let am_packagename=@name!!
!!enter system!!
	!!travel project!!
		!!if !strcmp(@am_packagename,@name)!!
			!!let am_basedir=replace(@dir,@am_dir_convertfrom,@am_dir_convertto)!!
		!!endif!!
	!!next!!
!!leave!!
!!travel headfile!!
    <ClInclude Include="!!@am_basedir!!!!@am_dir_convertto!!!!@name!!" />
!!next!!
!!next!!
 </ItemGroup>
  <Import Project="$(VCTargetsPath)\Microsoft.Cpp.targets" />
  <ImportGroup Label="ExtensionTargets">
  </ImportGroup>
</Project>

----!!@projectName!!.vcxproj.filters
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ItemGroup> 
!!travel project!!
	<Filter Include="!!@name!!"></Filter>
!!next!!
  </ItemGroup>
  
  <ItemGroup> 
!!travel package!!
!!let am_packagename=@name!!
!!enter system!!
	!!travel project!!
		!!if !strcmp(@am_packagename,@name)!!
			!!let am_basedir=replace(@dir,@am_dir_convertfrom,@am_dir_convertto)!!
		!!endif!!
	!!next!!
!!leave!!
!!travel cppfile!!
    <ClCompile Include="!!@am_basedir!!!!@am_dir_convertto!!!!@name!!" >
      <Filter>!!@am_packagename!!</Filter>
	</ClCompile>
!!next!!
!!next!!
  </ItemGroup>
  
  <ItemGroup> 
!!travel package!!
!!let am_packagename=@name!!
!!enter system!!
	!!travel project!!
		!!if !strcmp(@am_packagename,@name)!!
			!!let am_basedir=replace(@dir,@am_dir_convertfrom,@am_dir_convertto)!!
		!!endif!!
	!!next!!
!!leave!!
!!travel headfile!!
    <ClInclude Include="!!@am_basedir!!!!@am_dir_convertto!!!!@name!!" >
      <Filter>!!@am_packagename!!</Filter>
	</ClInclude>
!!next!!
!!next!!
  </ItemGroup>
</Project>