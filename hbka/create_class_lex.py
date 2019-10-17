import sys

def add_vocab(word:str, id:str, weight:float, last_state:int):
    lines = []
    for idx,c in enumerate(word):
        if idx == 0:
            st = 0
            osym = id
            w = weight
        else:
            st = last_state
            osym = '<epsilon>'
            w = 0
        tokens = [str(st), str(last_state + 1), c, osym, str(w)]
        lines.append(' '.join(tokens))
        last_state += 1
    lines.append('%d %d %s %s' % (last_state, 0, '<space>', '<epsilon>'))
    return last_state, lines


if __name__ == '__main__':
    w2c_file = sys.argv[1]
    with open(w2c_file, 'r') as f:
        vocabs = [line.split() for line in f]

    last_state = 0
    buffer = []
    for word, id, log_p in vocabs:
        last_state, lines = add_vocab(word, id, -float(log_p), last_state)
        buffer.extend(lines)
    buffer.append('0')
    buffer.append('0 %d <unk> <unk>' % (last_state + 1))
    buffer.append('%d 0 <space> <epsilon>' % (last_state + 1))

    print('\n'.join(buffer))

