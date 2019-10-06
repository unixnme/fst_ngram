set -e

fstcompile --isymbols=vocab.syms --osymbols=vocab.syms --keep_isymbols --keep_osymbols grammar.text | fstarcsort --sort_type=ilabel  - grammar.fst
fstdraw --portrait grammar.fst grammar.dot
dot -Tpdf grammar.dot > grammar.pdf

fstcompile --isymbols=ascii.syms --osymbols=vocab.syms --keep_isymbols --keep_osymbols lex.text | fstarcsort --sort_type=olabel - lex.fst
fstdraw --portrait lex.fst lex.dot
dot -Tpdf lex.dot > lex.pdf

fstcompose lex.fst grammar.fst LG.fst
fstdraw --portrait LG.fst LG.dot
dot -Tpdf LG.dot > LG.pdf

