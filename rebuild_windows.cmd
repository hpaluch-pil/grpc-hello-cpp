@echo off
del /q /s c:\TEMP\build\grpc-hello || goto err
"c:\Program Files\CMake\bin\cmake.exe" ^
    -B c:/temp/build/grpc-hello ^
    -DCMAKE_PREFIX_PATH=c:\libs\grpc || goto err

"c:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" ^
    /t:Rebuild /p:Platform=x64 /p:Configuration=Release ^
    c:\temp\build\grpc-hello\HelloWorld.sln || goto err

:ok
echo OK
echo OK: Build finished in c:\temp\build\grpc-hello
echo OK
exit /b 0
:err
echo ERROR:
echo ERROR: Build FAILED
echo ERROR:
exit /b 1
