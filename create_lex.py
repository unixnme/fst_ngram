import argparse

def Transition(istate:int, ostate:int, ilabel:str, olabel:str) -> str:
    return ('%d\t%d\t%s\t%s\n' % (istate, ostate, ilabel, olabel))

def ExitState(state:int) -> str:
    return ('%d\n' % state)


def main():
    parser = argparse.ArgumentParser('Create lexicon FST')
    parser.add_argument('--vocab', type=str, default='/dev/stdin',
                        help='''path to vocab file; if not provided, read from stdin
                            Words should be separated by white space
                            ''')
    parser.add_argument('--output_prefix', type=str, default='lexicon',
                        help='output prefix to write its txt and syms files')
    args = parser.parse_args()

    eps = '<epsilon>'
    space = '<space>'
    phi = '<phi>'
    unk = '<unk>'

    vocab = open(args.vocab).read().split()
    with open(args.output_prefix + '.txt', 'w') as f:
        start = 0
        f.write(ExitState(start))
        current = 0
        for word in vocab:
            for i,char in enumerate(word):
                if i == 0:
                    f.write(Transition(start, current + 1, char, word))
                else:
                    f.write(Transition(current, current + 1, char, eps))
                current += 1
            f.write(Transition(current, start, space, eps))
        # any repetitive space shall be ignored
        f.write(Transition(start, start, space, eps))

    with open(args.output_prefix + '.syms', 'w') as f:
        for i,word in enumerate([eps, phi, unk] + vocab):
            f.write('%s\t%d\n' % (word, i))


if __name__ == '__main__':
    main()