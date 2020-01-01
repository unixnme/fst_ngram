from functools import cmp_to_key

chars = "_ABCDEFGHIJKLMNOPQRSTUVWXYZ'-"
blank = "_"
space = '-'
epsilon = '<epsilon>'

class Arc(object):
    def __init__(self, src:int, dst:int, ilabel:str, olabel:str):
        self.src = src
        self.dst = dst
        self.ilabel = ilabel.replace(space, '<space>').replace(blank, '<blk>')
        self.olabel = olabel.replace(space, '<space>').replace(blank, '<blk>')

    def __str__(self):
        return '%d %d %s %s' % (self.src, self.dst, self.ilabel, self.olabel)

    def __lt__(self, other):
        if self.src != other.src:
            return self.src < other.src
        if self.dst != other.dst:
            return self.dst < other.dst
        if self.ilabel != other.ilabel:
            return self.ilabel < other.ilabel
        return self.olabel < other.olabel

    def __eq__(self, other):
        return self.src == other.src \
            and self.dst == other.dst \
            and self.ilabel == other.ilabel \
            and self.olabel == other.olabel



def create_states(chars:str, blank:str):
    labels = chars.replace(blank, '')
    nb_states = list(range(1, len(labels) + 1))
    b_states = [state + len(labels) for state in nb_states]

    return labels, nb_states, b_states


if __name__ == '__main__':
    arcs = []
    labels, nb_states, b_states = create_states(chars, blank)
    arcs.append(Arc(0, 0, blank, epsilon))
    for l1,src in zip(labels, nb_states):
        if l1 != space:
            arcs.append(Arc(0, src, l1, l1))
        else:
            arcs.append(Arc(0, 0, l1, epsilon))

        for ilabel,nbs, bs in zip(labels, nb_states, b_states):
            if l1 == ilabel:
                dst = src
                olabel = epsilon
            else:
                dst = nbs
                olabel = ilabel
            arcs.append(Arc(src, dst, ilabel, olabel))
            arcs.append(Arc(bs, src, l1, l1))

    for src,dst in zip(nb_states, b_states):
        arcs.append(Arc(src, dst, blank, epsilon))

    final_states = set([0] + b_states + nb_states)

    arcs.sort()

    with open('T.txt', 'w') as f:
        for arc in arcs:
            f.write(str(arc) + '\n')
        for state in final_states:
            f.write('%d\n' % state)

    with open('tokens.syms', 'w') as f:
        f.write('<epsilon> 0\n')
        for idx,c in enumerate(chars):
            c = c.replace(space, '<space>').replace(blank, '<blk>')
            f.write('%s %d\n' % (c, idx+1))

