#!/bin/bash
cd ~/IdeaProjects/NileUi
gradle clean
cd ~/IdeaProjects
echo "compress ..."
tar czf nileui.tar.gz NileUi
echo "copy ..."
cp nileui.tar.gz "$HOME/快盘/backups/"
rm nileui.tar.gz

cd ~/Projects/HdfsProcs
gradle clean
cd ~/Projects
echo "compress ..."
tar czf HdfsProcs.tar.gz HdfsProcs
echo "copy ..."
cp HdfsProcs.tar.gz "$HOME/快盘/backups/"
rm HdfsProcs.tar.gz

echo "done."


