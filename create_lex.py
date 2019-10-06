import sys

def add_vocab(word:str, last_state:int):
    lines = []
    for idx,c in enumerate(word):
        if idx == 0:
            st = 0
            osym = word
        else:
            st = last_state
            osym = '<epsilon>'
        tokens = [str(st), str(last_state + 1), c, osym]
        lines.append(' '.join(tokens))
        last_state += 1
    lines.append('%d %d %s %s' % (last_state, 0, '<epsilon>', '<epsilon>'))
    return last_state, lines


if __name__ == '__main__':
    corpus_file = sys.argv[1]
    with open(corpus_file, 'r') as f:
        vocabs = set(f.read().split())

    last_state = 0
    buffer = []
    for word in sorted(vocabs):
        last_state, lines = add_vocab(word, last_state)
        buffer.extend(lines)
    buffer.append('0')
    print('\n'.join(buffer))

