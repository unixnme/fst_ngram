import numpy as np
import argparse

def Transition(istate:int, ostate:int, ilabel:str, olabel:str, weight:float=0) -> str:
    return ('%d\t%d\t%s\t%s\t%f\n' % (istate, ostate, ilabel, olabel, weight))

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
    parser.add_argument('--space_prob', type=float, default=0.5,
            help='probability that requires space after end of a word')
    args = parser.parse_args()

    eps = '<epsilon>'
    space = '<space>'
    phi = '<phi>'
    unk = '<unk>'

    weight_space = -np.log(args.space_prob)
    weight_nospace = -np.log(1 - args.space_prob)

    vocab = open(args.vocab).read().split()
    with open(args.output_prefix + '.txt', 'w') as f:
        start = 0
        f.write(ExitState(start))
        current = 0
        for word in vocab:
            for i,char in enumerate(word):
                if i == 0:
                    f.write(Transition(start, current + 1, char, word))
                elif i == len(word) - 1:
                    # last character can go back to start
                    f.write(Transition(current, start, char, eps, weight_nospace))
                    f.write(Transition(current, current + 1, char, eps, weight_space))
                else:
                    f.write(Transition(current, current + 1, char, eps))
                current += 1
            # back to start w/o space
            f.write(Transition(current, start, space, eps))
        # any repetitive space shall be ignored
        f.write(Transition(start, start, space, eps))

    with open(args.output_prefix + '.syms', 'w') as f:
        for i,word in enumerate([eps, phi, unk] + vocab):
            f.write('%s\t%d\n' % (word, i))


if __name__ == '__main__':
    main()
