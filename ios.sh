#!/bin/bash

set -e
if [ $# -lt 1 ]; then	
	echo "assign a command"
	exit -1
fi

CMD=$1
case "$CMD" in
	"run.objc")		
		if [ $# -gt 1 ]; then	
			program=$2
			clang -framework Foundation $program.m -o $program
			./$program
		fi
		;;

	"run.test")
		# for objc
		# run with: ios.sh run.test objective_sugar.m
		if [ $# -gt 1 ]; then	
			echo "build and run test with cocoapods ..."
			top_dir=$HOME/works/ios/practice
			program=$2
			cp $program $top_dir/cocoapods/app_tester/app_testerTests/app_testerTests.m
			cd $top_dir/cocoapods/app_tester
			bash ./run-tests.sh
		fi
		;;

	"swift.launcher")
		# run with: ios.sh swift.launcher objective_sugar.swift
		if [ $# -gt 1 ]; then	
			echo "build and run test with carthage ..."
			top_dir=$HOME/works/swift/practice
			program=$2
			cp $program $top_dir/swift_launcher/swift_launcherTests/swift_launcherTests.swift
			cd $top_dir/swift_launcher
			bash ./test.sh
		fi
		;;
		
	"pods.launcher")
		# for swift
		# run with: ios.sh pods.launcher objective_sugar.swift
		if [ $# -gt 1 ]; then	
			echo "build and run test with pods ..."
			top_dir=$HOME/works/swift/practice
			program=$2
			cp $program $top_dir/cocoapods/pods_launcher/pods_launcherTests/pods_launcherTests.swift
			cd $top_dir/cocoapods/pods_launcher
			bash ./run-tests.sh
		fi
		;;

	# for ios project
	"build")
		if [ $# -gt 1 ]; then	
			proj=$2
			xcodebuild -scheme $proj build
		fi
		;;	
	"targets")
		if [ $# -gt 1 ]; then	
			projfile=$2
			xcodebuild -list -project $projfile
		fi
		;;
	"release")
		if [ $# -gt 1 ]; then	
			proj=$2
			xcodebuild -scheme $proj DSTROOT="$HOME/ReleaseLocation" archive
		fi
		;;

	"test")
		if [ $# -gt 1 ]; then	
			proj=$2
			xcodebuild test -scheme $proj -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.0'
		fi
		;;

	"test.workspace")
		if [ $# -gt 1 ]; then	
			proj=$2
			xcodebuild test -workspace $proj.xcworkspace -scheme $proj -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.0'
		fi
		;;

	"test.out")		
		# preprend ~~ to your log message, for example:
		# 	NSLog(@"~~ welcome.");
		if [ $# -gt 1 ]; then	
			proj=$2
			echo "build and run test for project $proj ..."
			xcodebuild test -scheme $proj -destination 'platform=iOS Simulator,name=iPhone 7,OS=10.0' 2>&1 | grep ~~
		fi
		;;

	# end for

	"backup")
		if [ $# -gt 2 ]; then	
			echo "backup ..."
		else
			echo "use: volumes backup container-name volumn-folder-name"
		fi
		;;
	*)
		# docker volume ls
		;;
esac
