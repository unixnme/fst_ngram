set -e
set -x

lmplz_dir=$1
echo "be an app" | python ../create_lex.py
echo "a b e n p" | python ../create_t.py

$lmplz_dir/lmplz --order 3 --discount_fallback < ../corpus.txt > 3gram.arpa
ngramread --ARPA --symbols=lexicon.syms 3gram.arpa | fstarcsort --sort_type=ilabel - G.fst
fstcompile --isymbols=tokens.syms --osymbols=lexicon.syms --keep_isymbols --keep_osymbols lexicon.txt | fstarcsort --sort_type=olabel - L.fst

fstcompile --isymbols=tokens.syms --osymbols=tokens.syms --keep_isymbols --keep_osymbols tokens.txt tokens.fst
fstcompile --isymbols=tokens.syms --osymbols=tokens.syms --keep_isymbols --keep_osymbols tokens_self.txt tokens_self.fst
fstarcsort tokens.fst | fstphicompose 1 tokens_self.fst - | fstrmepsilon | fstdeterminize | fstminimize - T.fst
fstarcsort L.fst | fstcompose T.fst - | fstrmepsilon | fstminimizeencoded - TL.fst

echo "0 1" > relabel.txt
fstrelabel --relabel_ipairs=relabel.txt G.fst G.fst
fstprint TL.fst TL.txt
echo -e "0\t0\t<phi>\t<phi>\n" >> TL.txt # to compose with G's backoff ilabel
fstcompile --isymbols=tokens.syms --osymbols=lexicon.syms --keep_isymbols --keep_osymbols TL.txt TL.fst

fstarcsort --sort_type=olabel TL.fst | fstcompose - G.fst | fstrmepsilon | fstdeterminize | fstminimize - TLG.fst

echo "1 0" > relabel.txt
fstrelabel --relabel_ipairs=relabel.txt TLG.fst TLG.fst

fstdraw --portrait G.fst | dot -Tpdf > G.pdf
fstdraw --portrait L.fst | dot -Tpdf > L.pdf
fstdraw --portrait T.fst | dot -Tpdf > T.pdf
fstdraw --portrait TL.fst | dot -Tpdf > TL.pdf
fstdraw --portrait TLG.fst | dot -Tpdf > TLG.pdf

set +x
