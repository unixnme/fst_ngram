from tqdm import tqdm
import sys
from collections import defaultdict
from multiprocessing import Pool

p = Pool(5)
corpus_file = sys.argv[1]
word2class_file = sys.argv[2]

with open(corpus_file, 'r') as f:
    lines = f.readlines()

w2c = defaultdict(str)
with open(word2class_file, 'r') as f:
    for line in f:
        word, id, _ = line.split()
        w2c[word] = id

def replace(line):
    return ' '.join([w2c[token] for token in line.split()])

if __name__ == '__main__':
    for line in tqdm(lines):
        print(replace(line))
