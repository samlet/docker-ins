grpc-macos.md
==================
https://github.com/grpc/grpc/blob/master/INSTALL.md
For a Mac system, git is not available by default. You will first need to install Xcode from the Mac AppStore and then run the following command from a terminal:

 $ [sudo] xcode-select --install

# Protoc

By default gRPC uses protocol buffers, you will need the protoc compiler to generate stub server and client code.

If you compile gRPC from source, as described below, the Makefile will automatically try and compile the protoc in third_party if you cloned the repository recursively and it detects that you don't already have it installed.


# Build from Source

For developers who are interested to contribute, here is how to compile the gRPC C Core library.

 $ git clone -b $(curl -L http://grpc.io/release) https://github.com/grpc/grpc
 $ cd grpc
 $ git submodule update --init
 $ make
 $ make install

# Install Protocol Buffers v3
* http://www.grpc.io/docs/quickstart/cpp.html#install-protocol-buffers-v3

While not mandatory, gRPC usually leverages Protocol Buffers v3 for service definitions and data serialization. If you don’t already have it installed on your system, you can install the version cloned alongside gRPC:

$ cd grpc/third_party/protobuf
$ make
$ sudo make install

# Build the example

Always assuming you have gRPC properly installed, go into the example’s directory:

$ cd examples/cpp/helloworld/
Let’s build the example client and server: sh $ make

需要修改一下Makefile, 删除: -Wl,--no-as-needed -Wl,--as-needed
修改后如下:

	LDFLAGS += -L/usr/local/lib `pkg-config --libs grpc++ grpc`       \
           -lgrpc++_reflection \
           -lprotobuf -lpthread -ldl

# Try it!

From the examples/cpp/helloworld directory, run the server, which will listen on port 50051: sh $ ./greeter_server

From a different terminal, run the client: sh $ ./greeter_client

If things go smoothly, you will see the Greeter received: Hello world in the client side output.




