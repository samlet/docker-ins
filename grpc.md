grpc
==========
# init procs
> name=t.grpc enter.sh ubuntu
> cp -r /works/grpc/1.0.0 ./

# packages
apt-get -y install build-essential openjdk-8-jdk maven gradle cmake ruby vim sudo git wget
apt-get -y install autoconf automake libtool curl make g++ unzip pkg-config
apt-get -y install python python-pip
apt-get -y install golang

# grpc
https://github.com/grpc/grpc/blob/master/INSTALL.md
$ git clone -b $(curl -L http://grpc.io/release) https://github.com/grpc/grpc
$ cd grpc
$ git submodule update --init
$ make
$ [sudo] make install

# Install Protocol Buffers v3

While not mandatory, gRPC usually leverages Protocol Buffers v3 for service definitions and data serialization. If you don’t already have it installed on your system, you can install the version cloned alongside gRPC:

$ git clone -b v1.0.0 https://github.com/grpc/grpc
$ cd grpc/third_party/protobuf
$ make
$ sudo make install

# c++
$ cd examples/cpp/helloworld/
$ make
$ ./greeter_server &
$ ./greeter_client

# ruby
http://www.grpc.io/docs/quickstart/ruby.html
gem install grpc
gem install grpc-tools

$ # Clone the repository to get the example code:
$ git clone https://github.com/grpc/grpc
$ # Navigate to the "hello, world" Ruby example:
$ cd grpc/examples/ruby

From the examples/ruby directory:
Run the server
$ ruby greeter_server.rb
In another terminal, run the client
$ ruby greeter_client.rb

# node.js
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get install -y nodejs

$ # Clone the repository to get the example code
$ git clone -b v1.0.0 https://github.com/grpc/grpc
$ # Navigate to the dynamic codegen "hello, world" Node example:
$ cd grpc/examples/node/dynamic_codegen
$ # Install the example's dependencies
$ npm install

$ node greeter_server.js
$ node greeter_client.js

# python
http://www.grpc.io/docs/quickstart/python.html
Ensure you have pip version 8 or higher:
$ python -m pip install --upgrade pip

Install gRPC:
$ python -m pip install grpcio

To install gRPC tools, run:
$ python -m pip install grpcio-tools

$ # Navigate to the "hello, world" Python example:
$ cd grpc/examples/python/helloworld
From the examples/python/helloworld directory:
Run the server
$ python greeter_server.py
In another terminal, run the client
$ python greeter_client.py

# java
http://www.grpc.io/docs/quickstart/java.html
$ # Clone the repository at the latest release to get the example code:
$ git clone -b v1.0.0-pre2 https://github.com/grpc/grpc-java
$ # Navigate to the Java examples:
$ cd grpc-java/examples

Compile the client and server
$ ./gradlew installDist
Run the server
$ ./build/install/examples/bin/hello-world-server
In another terminal, run the client
$ ./build/install/examples/bin/hello-world-client

# golang
http://www.grpc.io/docs/quickstart/go.html
gRPC works with Go 1.5 or higher.
$ go version

The compiler plugin, protoc-gen-go, will be installed in $GOBIN, defaulting to $GOPATH/bin. It must be in your $PATH for the protocol compiler, protoc, to find it. 增加以下内容到.bashrc中:

	export GOPATH=/root/go
	export PATH=$PATH:$GOPATH/bin

Use the following command to install gRPC.
$ go get google.golang.org/grpc

install the protoc plugin for Go
$ go get -u github.com/golang/protobuf/{proto,protoc-gen-go}

The grpc code that was fetched with go get google.golang.org/grpc also contains the examples. They can be found under the examples dir: $GOPATH/src/google.golang.org/grpc/examples.

Change to the example directory
$ cd $GOPATH/src/google.golang.org/grpc/examples/helloworld

$ go run greeter_server/main.go
$ go run greeter_client/main.go

# .net core
https://www.microsoft.com/net/core#ubuntu

> sudo sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list'
> sudo apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893
> sudo apt-get update

Before you start, please remove any previous versions of .NET Core from your system by using this script.
> wget -c https://raw.githubusercontent.com/dotnet/cli/rel/1.0.0/scripts/obtain/uninstall/dotnet-uninstall-debian-packages.sh

To .NET Core on Ubuntu or Linux Mint, simply use apt-get.

> sudo apt-get install dotnet-dev-1.0.0-preview2-003121

Let's initialize a sample Hello World application!

> mkdir hwapp
> cd hwapp
> dotnet new
> dotnet restore
> dotnet run

http://www.grpc.io/docs/quickstart/csharp.html
Using the .NET Core SDK on Windows, OS X, or Linux, you’ll need:

1.	The .NET Core SDK command line tools.
2.	The .NET framework 4.5 (for OS X and Linux, the open source .NET Framework implementation, “Mono”, at version 4+, is suitable)
3.	A NuGet executable (to download the Grpc.Tools package that contains protoc and protobuf binaries for code generation)
4.	Git (to download the sample code)

> apt-get -y install mono-devel

A .NET Core SDK version of the hello world examples are in the directory, examples/csharp/helloworld-from-cli.
From the examples/csharp/helloworld-from-cli directory:

> dotnet restore
> dotnet build **/project.json

Run the server
> cd GreeterServer
> dotnet run
In another terminal, run the client (使用docker exec -it)
> cd GreeterClient
> dotnet run





