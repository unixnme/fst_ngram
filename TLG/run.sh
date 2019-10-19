fstcompile --isymbols=T.syms --osymbols=T.syms --keep_osymbols --keep_isymbols T.txt T.fst
fstcompile --isymbols=T.syms --osymbols=V.syms --keep_osymbols --keep_isymbols L.txt L.fst
fstarcsort --sort_type=olabel T.fst | fstcompose - L.fst TL.fst
fstrmepsilon TL.fst | fstdeterminize - | fstminimize - TL.fst.rmeps.det.min
fstdraw --portrait TL.fst.rmeps.det.min | dot -Tpdf > TL.pdf
open -a Preview TL.pdf
