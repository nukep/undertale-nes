#!/usr/bin/env python3

# Parse anything inside curly braces as a Python expression.
# Take the expression value and spit it out as assembler output

import sys
import re
import transform_asm_globals

def include(s):
    with open("src/{}".format(s), 'r') as f:
        contents = f.read()
    return transform(contents)

g = transform_asm_globals.__dict__
g["include"] = include

def transform(input):
    def expression(match):
        s=match.group(1).strip()
        return str(eval(s, transform_asm_globals.__dict__))

    def include(match):
        s=match.group(1)
        with open("src/{}".format(s), 'r') as f:
            contents = f.read()
        return transform(contents)

    # Strip comments
    o = re.sub(r';.*', '', input)
    # Transform includes
    # o = re.sub(r'include "(.*)"', o, input)
    # Evaluate expresions
    o = re.sub(r'{(.*?)}', expression, o, flags=re.S)
    return o

buf = sys.stdin.read()
print(transform(buf))
