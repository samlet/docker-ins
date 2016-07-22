#!/bin/bash
echo "start test ..."
time dd if=/dev/zero of=test.dat bs=1024 count=100000
