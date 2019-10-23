set -e
set -x

arpa=$1
cat $1 | sed 's/<UNK>/<unk>/g' | ngramread --ARPA - | fstarcsort --sort_type=ilabel - G.fst
fstprint --save_isymbols=osyms.txt G.fst | ../eps2disambig.pl > G.txt
label=`wc < osyms.txt | awk '{print $1}'`
echo "<backoff> $label" >> osyms.txt
cat osyms.txt | awk '{print $1}' | grep -v '<.*>' > vocab.txt
python ../create_lex.py vocab.txt > L.txt
fstcompile --isymbols=ascii.syms --osymbols=osyms.txt --keep_isymbols --keep_osymbols L.txt | fstarcsort --sort_type=olabel - L.fst
fstcompile --isymbols=osyms.txt --osymbols=osyms.txt --keep_osymbols --keep_isymbols G.txt | fstarcsort --sort_type=ilabel - | fstphicompose $label L.fst - | fstproject - | fstdeterminize - | fstminimize - | fstrmepsilon - | fstdeterminize - | fstminimize - | fstarcsort - LG.fst

#fstcompile --isymbols=ascii.syms --osymbols=ascii.syms --keep_isymbols --keep_osymbols T.txt | fstarcsort --sort_type=olabel - T.fst
#fstcompose T.fst LG.fst TLG.fst
#fstrmepslocal TLG.fst | fstarcsort --sort_type=ilabel - TLG.fst.rmeps

#fstdraw --portrait G.fst | dot -Tpdf > G.pdf
#fstdraw --portrait L.fst | dot -Tpdf > L.pdf
#fstdraw --portrait LG.fst | dot -Tpdf > LG.pdf

set +x
