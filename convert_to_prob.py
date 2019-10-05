import sys
import numpy as np

if __name__ == '__main__':
    with open(sys.argv[1], 'r') as f, open(sys.argv[1] + '.prob', 'w') as g:
        for line in f:
            tokens = line.split()
            if len(tokens) == 2 or len(tokens) == 5:
                tokens[-1] = str(np.exp(-float(tokens[-1])))
            g.write('\t'.join(tokens))
            g.write('\n')

