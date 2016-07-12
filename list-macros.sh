#!/bin/bash

MACROS=$(grep -i '^macro ' src/*.asm generated/*.asm | awk '{print $2}' | sort)

echo "Count: Macro"

RED='\033[0;31m'
NC='\033[0m' # No Color

for m in $MACROS; do
  COUNT=$(grep -i $m src/*.asm generated/*.asm | grep -vi 'macro ' | wc -l)
  if [ $COUNT -eq 0 ]; then echo -en $RED; fi
  echo -n "$COUNT: $m"
  if [ $COUNT -eq 0 ]; then echo -en $NC; fi
  echo
done
