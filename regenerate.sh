#!/bin/bash

cd modules || exit
for a_directory in $(ls -d */)
do
  (
  cd "$a_directory" || exit
  if [ ! -f "README.md" ]; then
    touch README.md
  fi
  dir_name=$(echo "$a_directory" | sed 's:/*$::')
  terraform-docs md "$(pwd)" > "$(pwd)"/params.md
  echo "$dir_name: params regenerated"
  )
done
