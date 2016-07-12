def byte(b):
    return ".db ${:02x}".format(b)

def bytes(label, a):
    x = ' '.join(["{:02x}".format(b&0xFF) for b in a])
    return """{label}.size={size}
{label}:
HEX {x}
""".format(label=label,size=len(a),x=x)

def text(label, s):
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

    return bytes(label, [map_chr(c) for c in s])

def text_menu(label, *s):
    import textwrap
    out = ""
    for x in s:
        a = textwrap.wrap(x, 26)
        out = out + "* " + a[0] + "\n"
        for xx in a[1:]:
            out = out + "  " + xx + "\n"
    return text(label, out.strip())
