#!/bin/bash

LABELS=$(grep -h ':' src/*.asm generated/*.asm | grep -v ';.*:' | grep -v '^@' | sed 's/://g' | sort)

echo "Count: Label"

RED='\033[0;31m'
NC='\033[0m' # No Color

for m in $LABELS; do
  ADDR=$(grep -h -F ' '$m':' bin/main.lst 2>/dev/null | awk '{print $1}')
  COUNT=$(grep -h $m src/*.asm generated/*.asm | grep -vi ':' | grep -vF '.' | wc -l)
  if [ $COUNT -eq 0 ]; then echo -en $RED; fi
  echo -n "$COUNT: $ADDR: $m"
  if [ $COUNT -eq 0 ]; then echo -en $NC; fi
  echo
done
