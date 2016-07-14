def bytes(label, a):
    out = """{label}.size={size}
{label}:""".format(size=len(a), label=label)

    for b in a:
        out += ".db {}\n".format(b)

    return out

def bytes_array(label, a):
    return '\n'.join([bytes("{}_{}".format(label,i), b) for i,b in enumerate(a)])

def text(s):
    def map_chr(c):
        if (c >= 'A' and c <= 'Z'):
            return ord(c)-ord('A')
        elif (c >= 'a' and c <= 'z'):
            return ord(c)-ord('a') + 26
        elif c == '.': return 52
        elif c == '!': return 53
        elif c == '?': return 54
        elif c == '*': return 55
        elif c == ' ': return 56
        elif c == '-': return 57
        elif c == '\'': return 58
        elif (c >= '0' and c <= '9'):
            return ord(c)-ord('0') + 59
        elif c == '\n': return 0xFF
        else:
            raise Exception("Unknown character: {}".format(c))
    return [map_chr(c) for c in s]

def xy_addr(x, y, nametable=0):
    return 0x2000 + nametable*0x400 + y*32 + x

def lookup_table_lo_hi(label_lo, label_hi, *longs):
    lo = '\n'.join([".db <({})".format(b) for b in longs])
    hi = '\n'.join([".db >({})".format(b) for b in longs])

    return """{label_lo}:
{lo}

{label_hi}:
{hi}
""".format(label_lo=label_lo, label_hi=label_hi, lo=lo, hi=hi)

def text_menu(s):
    import textwrap
    out = ""

    for x in s.split('\n'):
        a = textwrap.wrap(x, 26)
        out = out + "* " + a[0] + "\n"
        for xx in a[1:]:
            out = out + "  " + xx + "\n"
    out = out.strip()
    if out.count('\n') > 3:
        raise Exception("Text contains more than three lines: {}".format(s))
    return text(out)
