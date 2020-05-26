set -e
set -x

lmplz_dir=$1
echo "be an app pa" | python ../create_lex.py
echo "a b e n p" | python ../create_t.py

echo -e "0\t0\t<phi>\t<phi>\n" >> lexicon.txt # to compose with G's backoff ilabel
$lmplz_dir/lmplz --order 3 --discount_fallback -S 10%  < ../corpus.txt > 3gram.arpa
ngramread --ARPA --symbols=lexicon.syms 3gram.arpa | fstarcsort --sort_type=ilabel - G.fst
fstcompile --isymbols=tokens.syms --osymbols=lexicon.syms --keep_isymbols --keep_osymbols lexicon.txt | fstarcsort --sort_type=olabel - L.fst

fstcompile --isymbols=tokens.syms --osymbols=tokens.syms --keep_isymbols --keep_osymbols tokens.txt tokens.fst
fstcompile --isymbols=tokens.syms --osymbols=tokens.syms --keep_isymbols --keep_osymbols tokens_self.txt tokens_self.fst
fstarcsort tokens.fst | fstphicompose 1 tokens_self.fst - | fstrmepsilon | fstdeterminize | fstminimize - | fstarcsort --sort_type=olabel - T.fst

echo "0 1" > relabel.txt
fstrelabel --relabel_ipairs=relabel.txt G.fst G.fst
fsttablecompose L.fst G.fst | fstdeterminizestar --use-log=true | fstminimizeencoded - LG.fst
echo "1 0" > relabel.txt
fstrelabel --relabel_ipairs=relabel.txt LG.fst | fstarcsort - LG.fst

fsttablecompose T.fst LG.fst | fstminimizeencoded - TLG.fst

fstdraw --portrait G.fst | dot -Tpdf > G.pdf
fstdraw --portrait L.fst | dot -Tpdf > L.pdf
fstdraw --portrait T.fst | dot -Tpdf > T.pdf
fstdraw --portrait LG.fst | dot -Tpdf > LG.pdf
fstdraw --portrait TLG.fst | dot -Tpdf > TLG.pdf

set +x
