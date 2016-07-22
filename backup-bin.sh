#!/bin/sh
export TARGET=xiaofeiwu@apps:/home/xiaofeiwu/docker
export SOURCE_ROOT=$HOME/bin
#export SOURCE=$SOURCE_ROOT/Assets
export SOURCE=$SOURCE_ROOT
#export SETTINGS=$SOURCE_ROOT/ProjectSettings

# rsync -a --chmod=ugo=rwX --exclude='.svn/' --exclude="*.shadow.unity" --progress --delete $SOURCE $TARGET
rsync -avz --progress --exclude='.svn/' --exclude='.git/' --progress $SOURCE $TARGET
#rsync -avz --chmod=ugo=rwX --progress --delete $SETTINGS $TARGET

