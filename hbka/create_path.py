import numpy as np
import sys
from collections import defaultdict, OrderedDict
import json

count_sum = defaultdict(int)
word2class = dict()

with open(sys.argv[1], 'r') as f:
    for line in f:
        id, word, count = line.split()
        count_sum[id] += int(count)
        word2class[word] = (id, int(count))

w2c = OrderedDict()
for word,(id, count) in sorted(word2class.items()):
    w2c[word] = (id, np.log10(count) - np.log10(count_sum[id]))

print(json.dumps(w2c, indent=4))
