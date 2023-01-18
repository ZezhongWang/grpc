@REM Set those variable before using this script
set UNREAL_ENGINE_PATH=D:\github\UnrealEngine
set CLANG_TOOL_CHAIN=C:\UnrealToolchains\v20_clang-13.0.1-centos7
set BUILD_TYPE=Release

rem [Note]:
set OPENSSL_ROOT_DIR=%UNREAL_ENGINE_PATH%\Engine\Source\ThirdParty\OpenSSL\1.1.1n
set OPENSSL_INC=%OPENSSL_ROOT_DIR%\include\Win64\VS2015
set OPENSSL_LIB=%OPENSSL_ROOT_DIR%\lib\Win64\VS2015\Release
set ZLIB_ROOT_DIR=%UNREAL_ENGINE_PATH%\Engine\Source\ThirdParty\zlib\v1.2.8
set ZLIB_INC=%ZLIB_ROOT_DIR%\include\Win64\VS2015
set ZLIB_LIB=%ZLIB_ROOT_DIR%\lib\Win64\VS2015\Release

echo %OPENSSL_INC%
echo %ZLIB_LIB%
echo Make sure you have set up pre-request tools to build grpc on windows
echo This script will not install those tools for you

echo Build grpc
cd ..
git clean -d -f -x
md .build
cd .build

rem Compiling for windows platform
@REM cmake .. --debug-output^
cmake .. -G "Visual Studio 16 2019" ^
      -DgRPC_INSTALL=ON ^
      -DCMAKE_BUILD_TYPE=%BUILD_TYPE% ^
      -DgRPC_ZLIB_PROVIDER:STRING=package ^
      -DZLIB_INCLUDE_DIR:STRING=%ZLIB_INC% ^
      -DZLIB_LIBRARY:STRING=%ZLIB_LIB% ^
      -DgRPC_SSL_PROVIDER:STRING=package ^
      -DOPENSSL_ROOT_DIR:STRING=%OPENSSL_LIB% ^
      -DOPENSSL_INCLUDE_DIR:STRING=%OPENSSL_INC% ^
      @REM -DOPENSSL_CRYPTO_LIBRARY:STRONG=%OPENSSL_LIB%/libcrypto.a

@REM echo build start...
cmake --build . --config %BUILD_TYPE%
md ..\installed
cmake --install . --prefix ..\installed\