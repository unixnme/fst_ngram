import numpy as np


repeatable_symbols = [c for c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ\'']
# repeatable_symbols = [c for c in 'ABC']
non_repeatable_symbols = ['<space>']
blank_symbol = '<blk>'
epsilon_symbol = '<epsilon>'


class Arc(object):
    def __init__(self, src:int, dst:int, ilabel:str, olabel:str):
        self.src = src
        self.dst = dst
        self.ilabel = ilabel
        self.olabel = olabel

    def __str__(self):
        return '%d %d %s %s' % (self.src, self.dst, self.ilabel, self.olabel)

    def __lt__(self, other:'Arc'):
        if self.src != other.src:
            return self.src < other.src
        if self.dst != other.dst:
            return self.dst < other.dst
        if self.ilabel < other.ilabel:
            return self.ilabel < other.ilabel
        return self.olabel < other.olabel

    def __eq__(self, other:'Arc'):
        return self.src == other.src and \
                self.dst == other.dst and \
                self.ilabel == other.ilabel and \
                self.olabel == other.olabel


def create_states(n:int):
    global num_state
    states = np.arange(n, dtype=int) + num_state
    num_state += len(states)
    return states.tolist()


if __name__ == '__main__':
    num_state = 1 # start state = 0
    start = 0
    arcs = [Arc(start, start, blank_symbol, epsilon_symbol)]

    # repeatable symbols:
    # nb and b states for each repeatable symbols where
    nb_states = create_states(len(repeatable_symbols))
    b_states = create_states(len(repeatable_symbols))

    # non-repeatable symbols:
    # just a single state
    nr_states = create_states(len(non_repeatable_symbols))

    all_symbols = repeatable_symbols + non_repeatable_symbols
    initial_states = nb_states + nr_states

    # transition from start to initial states
    for dst, label in zip(initial_states, all_symbols):
        arcs.append(Arc(start, dst, label, label))

    # for each repeatable symbols, create blank transition
    for src, dst in zip(nb_states, b_states):
        arcs.append(Arc(src, dst, blank_symbol, epsilon_symbol))
        arcs.append(Arc(dst, dst, blank_symbol, epsilon_symbol))

    # for each non-repeatable symbols, create blank transition as a self-loop
    arcs.extend([Arc(s, s, blank_symbol, epsilon_symbol) for s in nr_states])

    # transition from initial state
    for src, state_label in zip(initial_states, all_symbols):
        for dst, ilabel in zip(initial_states, all_symbols):
            olabel = ilabel if state_label != ilabel else epsilon_symbol
            arcs.append(Arc(src, dst, ilabel, olabel))

    # transition from b_states
    for src in b_states:
        for dst, label in zip(initial_states, all_symbols):
            arcs.append(Arc(src, dst, label, label))

    with open('T.txt', 'w') as f:
        for arc in arcs:
            f.write(str(arc) + '\n')
        for state in range(num_state):
            f.write('%d\n' % state)

    with open('tokens.syms', 'w') as f:
        for idx, label in enumerate([epsilon_symbol] + [blank_symbol] + repeatable_symbols + non_repeatable_symbols):
            f.write('%s %d\n' % (label, idx))