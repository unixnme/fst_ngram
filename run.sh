set -e

# create a binary WFST from the given ARPA fle
ngramread --ARPA $1 binary.fst

# create a text-version of the WFST
fstprint --save_isymbols=isyms.txt --save_osymbols=osyms.txt binary.fst text.fst

# the weights are in natural log; let's convert to log10 so that the numbers match with ARPA file
python ../convert_to_log10.py text.fst

# compile the text WFST into binary WFST
fstcompile --isymbols=isyms.txt --osymbols=osyms.txt text.fst.conv binary.fst.conv

# for easier visualization, plot WFST
fstdraw --portrait --isymbols=isyms.txt --osymbols=osyms.txt binary.fst.conv fst.dot
dot -Tpdf fst.dot > fst.pdf

# run perplexity analysis for the given sentence
echo -e $2 | farcompilestrings --generate_keys=1 -symbols=isyms.txt --keep_symbols | ngramperplexity --v=1 binary.fst -

