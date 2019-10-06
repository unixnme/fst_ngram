set -e

ngramread --ARPA ../test.arpa | fstarcsort --sort_type=ilabel - G.fst
fstprint --save_isymbols=osyms.txt G.fst > /dev/null
python ../create_lex.py ../corpus.txt | fstcompile --isymbols=ascii.syms --osymbols=osyms.txt --keep_isymbols --keep_osymbols - | fstarcsort --sort_type=olabel - L.fst
fstcompose L.fst G.fst | fstproject - | fstdeterminize - LG.fst

fstdraw --portrait G.fst | dot -Tpdf > G.pdf
fstdraw --portrait L.fst | dot -Tpdf > L.pdf
fstdraw --portrait LG.fst | dot -Tpdf > LG.pdf
