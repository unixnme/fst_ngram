
chars = "_ABCDEFGHIJKLMNOPQRSTUVWXYZ'-"
blank = "_"
space = '-'

def add_chars(chars:str):
    lines = []
    st = 1
    for c in chars:
        lines.append("0 %d %s %s" % (st, c, c))
        lines.append("%d %d %s <epsilon>" % (st, st, c))
        lines.append("%d 0 <epsilon> <epsilon>" % st)
        st += 1
    return lines


if __name__ == '__main__':
    lines = add_chars(chars[1:])
    lines.append("0 0 %s %s" % (blank, blank))
    lines.append("0")
    lines = '\n'.join(lines)
    print(lines.replace(space, "<space>"))

