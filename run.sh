set -e

ngramread --ARPA $1 binary.fst
fstprint --save_isymbols=isyms.txt --save_osymbols=osyms.txt binary.fst text.fst
python ../convert_to_log10.py text.fst
fstcompile --isymbols=isyms.txt --osymbols=osyms.txt text.fst.conv binary.fst.conv
fstdraw --portrait --isymbols=isyms.txt --osymbols=osyms.txt binary.fst.conv fst.dot
dot -Tpdf fst.dot > fst.pdf
echo -e $2 | farcompilestrings --generate_keys=1 -symbols=isyms.txt --keep_symbols | ngramperplexity --v=1 binary.fst -

