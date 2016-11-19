#!/bin/bash

parent=${PWD##*/}

# http://alvinalexander.com/scala/how-to-create-sbt-project-directory-structure-scala
mkdir -p src/{main,test}/{java,resources,scala}
mkdir -p src/main/scala/$parent
mkdir lib project target

# create project files
read -d '' cnt <<EOF
addSbtPlugin("com.typesafe.sbt" % "sbt-native-packager" % "1.0.0-RC1")
addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.11.2")
EOF

echo "$cnt"> project/plugins.sbt

read -d '' cnt <<EOF
sbt.version=0.13.7
EOF

echo "$cnt"> project/build.properties

read -d '' cnt <<EOF
#!/bin/bash
# https://github.com/adamw/docker-spray-example
sbt assembly
EOF

echo "$cnt"> build.sh

read -d '' cnt <<EOF
#!/bin/bash
java -jar target/scala-2.11/${parent}-assembly-1.0.jar
EOF

echo "$cnt"> run.sh

read -d '' cnt <<EOF
#!/bin/bash
sbt publish-local
echo "... dist ..."
ls $HOME/.ivy2/local/${parent}/
EOF

echo "$cnt"> dist.sh

# create an initial build.sbt file
read -d '' cnt <<EOF
import NativePackagerHelper._
import sbtassembly.Plugin.AssemblyKeys._

lazy val root = (project in file(".")).
  settings(
    name := "${parent}",
    version := "1.0",
    scalaVersion := "2.11.8"
  )

libraryDependencies ++= Seq(
	"org.scala-lang.modules" % "scala-xml_2.11" % "1.0.5",
	"ch.qos.logback" % "logback-classic" % "1.1.7" % "runtime",

	"junit" % "junit" % "4.12" % "test"
	)  

mainClass in Compile := Some("${parent}.App")

assemblySettings

EOF

echo "$cnt"> build.sbt

read -d '' cnt <<EOF
// ${parent}_main.scala
package ${parent}

/**
 * Created by xiaofei.wu@gmail.com.
 */
object App {
  def main(args: Array[String]) {
    val hello = "Hello, Scala!"
    println(hello)
  }

}

EOF
echo "$cnt"> ./src/main/scala/$parent/App.scala

read -d '' cnt <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>

    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <target>System.out</target>
        <encoder>
            <pattern>%date{MM/dd HH:mm:ss.SSS} %-5level[%.15thread] %logger{1} - %msg%n</pattern>
        </encoder>
    </appender>

    <!-- <appender name="FILE" class="ch.qos.logback.core.FileAppender">
        <file>akka.log</file>
        <append>false</append>
        <encoder>
            <pattern>%date{MM/dd HH:mm:ss} %-5level[%thread] %logger{1} - %msg%n</pattern>
        </encoder>
    </appender> -->

    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
    </root>

</configuration>
EOF
echo "$cnt"> ./src/main/resources/logback.xml

### dockerfile

read -d '' cnt <<EOF
# VERSION 1.0

# the base image is a trusted ubuntu build with java 8 (https://index.docker.io/u/dockerfile/java/)
FROM java:8

# that's me!
MAINTAINER Samlet Wu, xiaofei.wu@gmail.com

# we need this because the workdir is modified in dockerfile/java
WORKDIR /app

# run the (java) server as the daemon user
# USER daemon

# copy the locally built fat-jar to the image
ADD target/scala-2.11/${parent}-assembly-1.0.jar /app/server.jar

# run the server when a container based on this image is being run
ENTRYPOINT [ "java", "-jar", "/app/server.jar" ]

# the server binds to 8080 - expose that port
# EXPOSE 8080

EOF

echo "$cnt"> Dockerfile


