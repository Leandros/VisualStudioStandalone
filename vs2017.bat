:: Setup.
@echo off
setlocal ENABLEEXTENSIONS
setlocal EnableDelayedExpansion

:: Arguments.
if %1.==. goto err0

:GETOPTS
if /I "%1"=="/?" goto err0
if /I "%1"=="/libconc" set WITH_LIBCONC=TRUE & shift
if /I "%1"=="/libucrt" set WITH_LIBUCRT=TRUE & shift
if /I "%1"=="/tools" set WITH_TOOLS=TRUE & shift
if /I "%1"=="/x86" set WITH_X86=TRUE & shift
if /I "%1"=="--" shift & goto start
if "%1:~0,1%"=="/" goto GETOPTS
if "%1:~0,2%"=="--" shift


:start
set "ARG0=%1"

:: Registry keys.
set VS_KEY="HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\SxS\VS7"
set VS_VAL="15.0"
set WIN_SDK_KEY="SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots"
set WIN_SDK_VAL="KitsRoot10"

:: Find out where Visual Studio is installed.
FOR /F "usebackq skip=2 tokens=1-2*" %%A IN (`REG QUERY %VS_KEY% /v %VS_VAL% 2^>nul`) DO (
    set VS_INSTALL_DIR=%%C
)
if not defined VS_INSTALL_DIR (
    echo No Visual Studio installation found!
    exit /B 1
)
echo Visual Studio installation found at %VS_INSTALL_DIR%

:: Get current Visual Studio version.
set VS_TOOLS="%VS_INSTALL_DIR%\VC\Auxiliary\Build\Microsoft.VCToolsVersion.default.txt"
set /p VS_TOOLS_VERSION=<%VS_TOOLS%
set VS_TOOLS_VERSION=%VS_TOOLS_VERSION: =%
echo Using tools version %VS_TOOLS_VERSION%
if %1.==. goto err2

:: Create target directory, error out if it already exists.
if exist %ARG0% goto err1
md %ARG0%

:: Create required directory structure and copy over files.
set "SRC=%VS_INSTALL_DIR%\VC\Tools\MSVC\%VS_TOOLS_VERSION%"
set "DST=%ARG0%\%VS_TOOLS_VERSION%"
md "%DST%\bin\HostX64\x64"
md "%DST%\bin\HostX64\x86"

:: Create include files
xcopy "%SRC%\include" "%DST%\include" /SEYI

:: Create libraries
md "%DST%\lib\x64"
md "%DST%\lib\x86"
xcopy "%SRC%\lib\x64" "%DST%\lib\x64" /Y
xcopy "%SRC%\lib\x86" "%DST%\lib\x86" /Y

:: Removing ConcRT
if "%WITH_LIBCONC%"=="" (
    del "%DST%\lib\x64\libconc*.*" "%DST%\lib\x64\conc*.*"
    del "%DST%\lib\x86\libconc*.*" "%DST%\lib\x86\conc*.*"
)

:: Removing Universal RunTime
if "%WITH_LIBUCRT%"=="" (
    del "%DST%\lib\x64\msvcurt*.*"
    del "%DST%\lib\x86\msvcurt*.*"
)

:: Create HOSTX64 toolchain.
set TOOLCHAIN=bin\HostX64\x64
xcopy "%SRC%\%TOOLCHAIN%\1033\clui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
xcopy "%SRC%\%TOOLCHAIN%\1033\cvtresui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
xcopy "%SRC%\%TOOLCHAIN%\1033\linkui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
xcopy "%SRC%\%TOOLCHAIN%\c1.dll" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\c2.dll" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\c1xx.dll" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\cl.exe" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\lib.exe" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\link.exe" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\ml64.exe" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\cvtres.exe" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\undname.exe" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\d3dcompiler_47.dll" "%DST%\%TOOLCHAIN%"
:: Required .dll's
xcopy "%SRC%\%TOOLCHAIN%\mspdb140.dll" "%DST%\%TOOLCHAIN%"

:: Extra tools
if "%WITH_TOOLS%"=="TRUE" (
    xcopy "%SRC%\%TOOLCHAIN%\nmake.exe" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\dumpbin.exe" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\editbin.exe" "%DST%\%TOOLCHAIN%"
)

set TOOLCHAIN=bin\HostX64\x86
xcopy "%SRC%\%TOOLCHAIN%\1033\clui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
xcopy "%SRC%\%TOOLCHAIN%\1033\linkui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
xcopy "%SRC%\%TOOLCHAIN%\c1.dll" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\c2.dll" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\c1xx.dll" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\cl.exe" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\lib.exe" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\link.exe" "%DST%\%TOOLCHAIN%"
xcopy "%SRC%\%TOOLCHAIN%\ml.exe" "%DST%\%TOOLCHAIN%"
:: Required .dll's.
xcopy "%SRC%\bin\HostX64\x64\mspdb140.dll" "%DST%\%TOOLCHAIN%"

:: Extra tools
if "%WITH_TOOLS%"=="TRUE" (
    xcopy "%SRC%\%TOOLCHAIN%\dumpbin.exe" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\editbin.exe" "%DST%\%TOOLCHAIN%"
)


:: ----------------------------------------------------------------------------
:: Create X86 toolchain
:: ----------------------------------------------------------------------------

if "%WITH_X86%"=="TRUE" (
    md %ARG0%\%VS_TOOLS_VERSION%\bin\HostX86\x64\1033
    md %ARG0%\%VS_TOOLS_VERSION%\bin\HostX86\x86\1033

    set TOOLCHAIN=bin\HostX86\x64
    xcopy "%SRC%\%TOOLCHAIN%\1033\clui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
    xcopy "%SRC%\%TOOLCHAIN%\1033\linkui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
    xcopy "%SRC%\%TOOLCHAIN%\c1.dll" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\c2.dll" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\c1xx.dll" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\cl.exe" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\lib.exe" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\link.exe" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\ml64.exe" "%DST%\%TOOLCHAIN%"

    :: Required .dll's
    xcopy "%VS_INSTALL_DIR%\Common7\IDE\mspdb140.dll" "%DST%\%TOOLCHAIN%"

    :: Extra tools
    if "%WITH_TOOLS%"=="TRUE" (
        xcopy "%SRC%\%TOOLCHAIN%\dumpbin.exe" "%DST%\%TOOLCHAIN%"
        xcopy "%SRC%\%TOOLCHAIN%\editbin.exe" "%DST%\%TOOLCHAIN%"
    )


    set TOOLCHAIN=bin\HostX86\x86
    xcopy "%SRC%\%TOOLCHAIN%\1033\clui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
    xcopy "%SRC%\%TOOLCHAIN%\1033\cvtresui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
    xcopy "%SRC%\%TOOLCHAIN%\1033\linkui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
    xcopy "%SRC%\%TOOLCHAIN%\c1.dll" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\c2.dll" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\c1xx.dll" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\cl.exe" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\cvtres.exe" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\lib.exe" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\link.exe" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\ml.exe" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\undname.exe" "%DST%\%TOOLCHAIN%"
    xcopy "%SRC%\%TOOLCHAIN%\d3dcompiler_47.dll" "%DST%\%TOOLCHAIN%"

    :: Required .dll's.
    xcopy "%SRC%\%TOOLCHAIN%\mspdb140.dll" "%DST%\%TOOLCHAIN%"

    :: Extra tools
    if "%WITH_TOOLS%"=="TRUE" (
        xcopy "%SRC%\%TOOLCHAIN%\nmake.exe" "%DST%\%TOOLCHAIN%"
        xcopy "%SRC%\%TOOLCHAIN%\dumpbin.exe" "%DST%\%TOOLCHAIN%"
        xcopy "%SRC%\%TOOLCHAIN%\editbin.exe" "%DST%\%TOOLCHAIN%"
    )

)

:: Exit with success.
exit /B 0

:: Errors.
:err0
echo Missing arguments.
echo.
echo Usage: vs2017.bat DIRECTORY
echo.
echo Arguments:
echo.
echo    /libconc        Keep ConcRT
echo    /libucrt        Keep Universal Runtime
echo    /tools          Keep extended tools (like editbin.exe or dumpbin.exe)
echo    /x86            Create x86 toolchain, in addition to x64 toolchain
exit /B 1

:err1
echo Directory %ARG0% already exists. Exiting.
exit /B 1

:err2
echo Visual Studio version could not be found. Exiting.
exit /B 1

