set -e

fstcompile --isymbols=vocab.syms --osymbols=vocab.syms --keep_isymbols --keep_osymbols grammar.text | fstarcsort --sort_type=ilabel  - grammar.fst
fstdraw --portrait grammar.fst grammar.dot
dot -Tpdf grammar.dot > grammar.pdf

fstcompile --isymbols=ascii.syms --osymbols=vocab.syms --keep_isymbols --keep_osymbols lex.text | fstarcsort --sort_type=olabel - lex.fst
fstdraw --portrait lex.fst lex.dot
dot -Tpdf lex.dot > lex.pdf

fstcompose lex.fst grammar.fst lex_grammar.fst
fstdraw --portrait lex_grammar.fst lex_grammar.dot
dot -Tpdf lex_grammar.dot > lex_grammar.pdf

ngramread --ARPA ../test.arpa | fstarcsort --sort_type=ilabel - G.fst
fstprint --save_isymbols=osyms.txt G.fst > /dev/null
python ../create_lex.py ../corpus.txt | fstcompile --isymbols=ascii.syms --osymbols=osyms.txt --keep_isymbols --keep_osymbols - | fstarcsort --sort_type=olabel - L.fst
fstcompose L.fst G.fst LG.fst

fstdraw --portrait G.fst | dot -Tpdf > G.pdf
fstdraw --portrait L.fst | dot -Tpdf > L.pdf
fstdraw --portrait LG.fst | dot -Tpdf > LG.pdf
