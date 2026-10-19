@echo off
setlocal
set CM=c:\Program Files\CMake\bin\cmake.exe
set APP=grpc
set MY_PWD0=%~sdp0
set MY_PWD=%MY_PWD0:~0,-1%
set PLATFORM=x64

if "%~1" == "" (
  echo Must specify 1st argument - Workspace DIRECTORY for build
  goto usage
)
if not exist "%~1" (
  echo Specified directory '%1' does not exist
  exit /b 1
)

rmdir /s /q "%~1\build\%APP%-%PLATFORM%"
md "%~1\build\%APP%-%PLATFORM%" || goto err
cd /d "%~1\build\%APP%-%PLATFORM%" || goto err
@echo on
"%CM%" ^
   -G "Visual Studio 16 2019" ^
   -A %PLATFORM% ^
   -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF -DBUILD_SHARED_LIBS=OFF ^
   -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX=c:\libs\grpc ^
   "%MY_PWD%\grpc" || goto err
"%CM%" --build . --config Release --target install  -j %NUMBER_OF_PROCESSORS% || goto err
exit /b 0

:usage
echo Usage: %0 BUILD_WORKSPACE
echo For example, run: %0 c:\TEMP
exit /b 1

:err
exit /b %ERRORLEVEL%