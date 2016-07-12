#!/bin/bash

for file in src/*.asm generated/*.asm; do
  OUT=$(grep -i '^macro ' $file)
  if [ $? -eq 0 ]; then
    echo "*** $file ***"
    echo "$OUT" | sort
    echo
  fi
done
