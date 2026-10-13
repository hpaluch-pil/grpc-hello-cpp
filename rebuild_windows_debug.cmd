@echo off
setlocal
set WS=c:\TEMP\build\grpc-hello-Debug
del /q /s %WS%  || goto err
"c:\Program Files\CMake\bin\cmake.exe" ^
    -B %WS% -DCMAKE_PREFIX_PATH=c:\libs\grpc-Debug || goto err

"c:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" ^
    /t:Rebuild /p:Platform=x64 /p:Configuration=Debug ^
    %WS%\HelloWorld.sln || goto err

:ok
echo OK
echo OK: Build finished in %WS%
echo OK
exit /b 0
:err
echo ERROR:
echo ERROR: Build FAILED
echo ERROR:
exit /b 1
