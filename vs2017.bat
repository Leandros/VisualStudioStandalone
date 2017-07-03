:: Setup.
@echo off
setlocal ENABLEEXTENSIONS
setlocal EnableDelayedExpansion

:: Arguments.
if %1.==. goto err0
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
set SRC=%VS_INSTALL_DIR%\VC\Tools\MSVC\%VS_TOOLS_VERSION%
set DST=%ARG0%\%VS_TOOLS_VERSION%
md %DST%\bin\HostX86\x64
md %DST%\bin\HostX86\x86
xcopy "%SRC%\include" "%DST%\include" /SEYI
xcopy "%SRC%\lib" "%DST%\lib" /SEYI

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

:: Uncomment to create X64 toolchain.
:::: Create HOSTX64 toolchain.
::md %ARG0%\%VS_TOOLS_VERSION%\bin\HostX64\x64\1033
::md %ARG0%\%VS_TOOLS_VERSION%\bin\HostX64\x86\1033

::set TOOLCHAIN=bin\HostX64\x64
::xcopy "%SRC%\%TOOLCHAIN%\1033\clui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
::xcopy "%SRC%\%TOOLCHAIN%\1033\cvtresui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
::xcopy "%SRC%\%TOOLCHAIN%\1033\linkui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
::xcopy "%SRC%\%TOOLCHAIN%\c1.dll" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\c2.dll" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\c1xx.dll" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\cl.exe" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\lib.exe" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\link.exe" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\ml64.exe" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\cvtres.exe" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\undname.exe" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\d3dcompiler_47.dll" "%DST%\%TOOLCHAIN%"
:::: Required .dll's
::xcopy "%SRC%\%TOOLCHAIN%\mspdb140.dll" "%DST%\%TOOLCHAIN%"

::set TOOLCHAIN=bin\HostX64\x86
::xcopy "%SRC%\%TOOLCHAIN%\1033\clui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
::xcopy "%SRC%\%TOOLCHAIN%\1033\linkui.dll" "%DST%\%TOOLCHAIN%\1033\" /I
::xcopy "%SRC%\%TOOLCHAIN%\c1.dll" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\c2.dll" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\c1xx.dll" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\cl.exe" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\lib.exe" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\link.exe" "%DST%\%TOOLCHAIN%"
::xcopy "%SRC%\%TOOLCHAIN%\ml.exe" "%DST%\%TOOLCHAIN%"
:::: Required .dll's.
::xcopy "%SRC%\bin\HostX64\x64\mspdb140.dll" "%DST%\%TOOLCHAIN%"

:: Exit with success.
exit /B 0

:: Errors.
:err0
echo Missing arguments.
echo.
echo Usage: vs2017.bat DIRECTORY
exit /B 1

:err1
echo Directory %ARG0% already exists. Exiting.
exit /B 1

:err2
echo Visual Studio version could not be found. Exiting.
exit /B 1

