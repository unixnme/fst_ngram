import sys

def create_fst(word:str):
    buffer = []
    for idx,c in enumerate(word):
        if idx == 0:
            out = word
        else:
            out = '<epsilon>'
        tokens = [str(idx), str(idx+1), c, out]
        buffer.append(' '.join(tokens))
    buffer.append(str(idx+1))
    return '\n'.join(buffer)

if __name__ == '__main__':
    corpus_file = sys.argv[1]
    with open(corpus_file, 'r') as f:
        vocabs = set(f.read().split())
    print(vocabs)

    last_state = 0
    buffer = []
    for word in sorted(vocabs):
        with open(word + '.text', 'w') as f:
            f.write(create_fst(word))

