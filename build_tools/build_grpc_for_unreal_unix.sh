# We need to build grpc natively on linux platform since
# CMake doesn't have nice support for cross compiling on Windows
# platform targeting for Linux platform. (related to VS generator
# and its supporting platform)

# After cloning the grpc repo, we might need to do some minor modification
# to prevent linking errors with unreal. e.g.
#   undefined symbol: getentropy
# we need to comment following line in seed_material.cc:
# define ABSL_RANDOM_USE_GET_ENTROPY 1

UNREAL_ENGINE_PATH=$HOME/unrealengine/UnrealEngine

# [Note]:
OPENSSL_ROOT_DIR=$UNREAL_ENGINE_PATH/Engine/Source/ThirdParty/OpenSSL/1.1.1c
OPENSSL_INC=$OPENSSL_ROOT_DIR/include/Unix/x86_64-unknown-linux-gnu/
OPENSSL_LIB=$OPENSSL_ROOT_DIR/lib/Unix/x86_64-unknown-linux-gnu/
ZLIB_ROOT_DIR=$UNREAL_ENGINE_PATH/Engine/Source/ThirdParty/zlib/v1.2.8
ZLIB_INC=$ZLIB_ROOT_DIR/include/Unix/x86_64-unknown-linux-gnu/
ZLIB_LIB=$ZLIB_ROOT_DIR/lib/Unix/x86_64-unknown-linux-gnu/

echo $OPENSSL_LIB
echo $ZLIB_LIB

# 1. Setup
echo *************Step 1*************
echo Set install dir to $HOME/.grpc
export MY_INSTALL_DIR=$HOME/.grpc
mkdir -p $MY_INSTALL_DIR
export PATH="$MY_INSTALL_DIR/bin:$PATH"

# 2. Check required tools
echo *************Step 2*************
echo Check and install required tools
pkgs="cmake build-essential autoconf libtool pkg-config libc++-13-dev libc++abi-13-dev clang-13"
MISSING=$(dpkg --get-selections $pkgs 2>&1 | grep -v 'install$' | awk '{ print $6 }')
# Optional check here to skip bothering with apt-get if $MISSING is empty
sudo apt-get install $MISSING

export CXX=clang++-13
export CXXFLAGS="-stdlib=libc++ -std=c++11"
export LDXX="clang++-13 -stdlib=libc++"
export CC=clang-13

# 4. Build grpc
echo *************Step 3*************
echo Build grpc
cd grpc
mkdir -p cmake/build
pushd cmake/build
# Need to set openssl and zlib library path to unreal thirdparty path
cmake -DgRPC_INSTALL=ON \
      -DgRPC_BUILD_TESTS=OFF \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR \
      -DgRPC_ZLIB_PROVIDER:STRING=package \
      -DZLIB_ROOT:STRING=$ZLIB_LIB \
      -DZLIB_INCLUDE_DIR:STRING=$ZLIB_INC \
      -DZLIB_LIBRARIES:STRING=$ZLIB_LIB \
      -DgRPC_SSL_PROVIDER:STRING=package \
      -DOPENSSL_ROOT_DIR:STRING=$OPENSSL_LIB \
      -DOPENSSL_LIBRARIES:STRING=$OPENSSL_LIB \
      -DOPENSSL_INCLUDE_DIR:STRING=$OPENSSL_INC \
      ../..

echo make
make -j 4
cmake --install . --prefix $MY_INSTALL_DIR
popd

# [Option] Generate example proto
mkdir -p $MY_INSTALL_DIR/gen_proto
$MY_INSTALL_DIR/bin/protoc -I=examples/protos --cpp_out=$MY_INSTALL_DIR/gen_proto examples/protos/helloworld.proto
$MY_INSTALL_DIR/bin/protoc -I=examples/protos --grpc_out=$MY_INSTALL_DIR/gen_proto --plugin=protoc-gen-grpc="$MY_INSTALL_DIR/bin/grpc_cpp_plugin" examples/protos/helloworld.proto


