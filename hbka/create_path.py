import numpy as np
import sys
from collections import defaultdict

count_sum = defaultdict(int)
word2class = dict()

with open(sys.argv[1], 'r') as f:
    for line in f:
        id, word, count = line.split()
        count_sum[id] += int(count)
        word2class[word] = (id, int(count))

for word,(id, count) in word2class.items():
    print('%s %s %f' % (word, id, np.log(count) - np.log(count_sum[id])))

