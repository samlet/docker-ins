#!/bin/bash

parent=${PWD##*/}

read -d '' cnt <<EOF
// Apply the java plugin to add support for Java
apply plugin: 'java'

apply plugin: "idea"
apply plugin: 'application'

version = '1.0'
sourceCompatibility = 1.8
targetCompatibility = 1.8
compileJava.options.encoding = 'UTF-8'

mainClassName="exec.Main"

//create a single Jar with all dependencies
task fatJar(type: Jar) {
    manifest {
        attributes 'Implementation-Title': 'Gradle Jar File', 
            'Implementation-Version': version,
            'Main-Class': mainClassName
    }
    baseName = project.name + '-all'
    from { configurations.compile.collect { it.isDirectory() ? it : zipTree(it) } }
    with jar
}

// In this section you declare where to find the dependencies of your project
repositories {
    // Use 'jcenter' for resolving your dependencies.
    // You can declare any Maven/Ivy/file repository here.
    jcenter()
    mavenCentral()
}

// In this section you declare the dependencies for your production and test code
dependencies {
    // The production code uses the SLF4J logging API at compile time
    compile 'org.slf4j:slf4j-api:1.7.21'
    compile 'ch.qos.logback:logback-classic:1.1.3'
    compile 'redis.clients:jedis:2.8.0'

    // Declare the dependency for your favourite test framework you want to use in your tests.
    // TestNG is also supported by the Gradle Test task. Just change the
    // testCompile dependency to testCompile 'org.testng:testng:6.8.1' and add
    // 'test.useTestNG()' to your build script.
    testCompile 'junit:junit:4.12'
}
EOF

echo "$cnt"> build.gradle

# build
read -d '' cnt <<EOF
#!/bin/bash
gradle fatJar
EOF

echo "$cnt"> build.sh

dist_jar="build/libs/${parent}-all-1.0.jar"
# dockerfile
read -d '' cnt <<EOF
FROM nile/java-dev

WORKDIR /app
ADD ${dist_jar} /app/app.jar

CMD ["/usr/bin/java", "-jar", "./app.jar"]
EOF

echo "$cnt"> run.dockerfile

# run
read -d '' cnt <<EOF
#!/bin/bash
java -jar ${dist_jar}
EOF

echo "$cnt"> run.sh

source_folder="src/main/java/exec"
mkdir -p $source_folder

read -d '' cnt <<EOF
package exec;

import java.util.Date;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Main{
	
	private static final Logger logger = LoggerFactory.getLogger(Main.class);
	
	public static void main(String[] args) {		
		logger.debug("[.] Current Date : {}", getCurrentDate());
		System.out.println(getCurrentDate());
	}
	
	private static Date getCurrentDate(){		
		return new Date();
		
	}
	
}

EOF
echo "$cnt"> ${source_folder}/Main.java

# create logger resources
res_folder="src/main/resources"
mkdir -p $res_folder
read -d '' cnt <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>

	<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
		<encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
	    	<pattern>%msg%n</pattern>
	  	</encoder>
	</appender>

	<root level="debug">
		<appender-ref ref="STDOUT" />
	</root>

</configuration>
EOF
echo "$cnt"> ${res_folder}/logback.xml


