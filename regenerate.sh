#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

cd modules || exit
for a_directory in `ls -d */`
do
  (
  cd $a_directory || exit
  if [ ! -f "README.md" ]; then
    touch README.md
  fi
  # echo $a_directory
  dir_name=`echo $a_directory | sed 's:/*$::'`
  # echo $dir_name
  # terraform validate &> /dev/null
  # RESULT=$?
  # if [ $RESULT -eq 0 ]; then
  #   rm -fr graphs/*
  #   terraform get
  #   terraform graph > graphs/overview.dot
  #   dot -Tpng -o graphs/overview.png graphs/overview.dot
  #   echo "$dir_name: graph regenerated"
  # else
  #   printf "$RED $dir_name: terraform validate failed. Skipping graph generation. $NC \n"
  # fi
  terraform-docs md "`pwd`" > "`pwd`"/params.md
  echo "$dir_name: params regenerated"
  )
done
