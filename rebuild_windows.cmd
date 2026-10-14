@echo off
setlocal
set CM=c:\Program Files\CMake\bin\cmake.exe
set MSB=c:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe
set GRPC_LIBDIR=c:\libs\grpc
set CONFIGURATION=Release
set WS=c:\TEMP\build\grpc-hello

del /q /s %WS%  || goto err
@echo on
"%CM%" -B %WS% -DCMAKE_PREFIX_PATH="%GRPC_LIBDIR%" || goto err
"%CM%" --build %WS% --config %CONFIGURATION% -j %NUMBER_OF_PROCESSORS% || goto err
@echo off
:ok
@echo off
echo OK
echo OK: Build finished in c:\temp\build\grpc-hello
echo OK
exit /b 0
:err
@echo off
echo ERROR:
echo ERROR: Build FAILED
echo ERROR:
exit /b 1
