import argparse
from collections import OrderedDict


def Transition(istate:int, ostate:int, ilabel:str, olabel:str) -> str:
    return ('%d\t%d\t%s\t%s\n' % (istate, ostate, ilabel, olabel))

def ExitState(state:int) -> str:
    return ('%d\n' % state)


def main():
    parser = argparse.ArgumentParser('Create token FST')
    parser.add_argument('--tokens', type=str, default='/dev/stdin',
                        help='''path to token file; if not provided, read from stdin
                        Provide only regular tokens, separated by white space, such as "a b c"
                        Blank <blk> and space <space> tokens will be automatically added.
                        ''')
    parser.add_argument('--output_prefix', type=str, default='tokens',
                        help='output prefix to write its txt and syms files')
    args = parser.parse_args()

    tokens = open(args.tokens).read().split()
    if len(tokens) <= 1:
        raise Exception("must provided at least one non-blank symbol")

    token_map = OrderedDict()
    blk = '<blk>'
    space = '<space>'
    eps = '<epsilon>'
    phi = '<phi>' # backoff
    token_map[eps] = eps
    token_map[phi] = phi
    token_map[blk] = blk
    token_map[space] = space
    for token in tokens:
        token_map[token] = token
    tokens.append(space)

    with open(args.output_prefix + '.syms', 'w') as f:
        for idx,(k,v) in enumerate(token_map.items()):
            f.write('%s\t%d\n' % (v,idx))

    with open(args.output_prefix + '.txt', 'w') as f:
        # state 0 is the initial state but also an exist state
        start = 0
        f.write(ExitState(start))
        f.write(Transition(start, start, blk, eps))
        current = 1
        # any regular token will transition to its own nb state
        for token in tokens:
            f.write(Transition(start, current, token, token))
            # each repetitive token will output nothing
            f.write(Transition(current, current, token, eps))
            # any other token will be need to backoff to start
            f.write(Transition(current, start, phi, eps))
            f.write(ExitState(current))
            current += 1

    with open(args.output_prefix + '_self.txt', 'w') as f:
        for idx,(k,v) in enumerate(token_map.items()):
            if idx <= 1: continue
            f.write(Transition(0, 0, v, v))
        f.write('0\n')


if __name__ == '__main__':
    main()