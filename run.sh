set -e

# create a binary WFST from the given ARPA fle
ngramread --ARPA $1 binary.fst

# create a text-version of the WFST
fstprint --save_isymbols=isyms.txt --save_osymbols=osyms.txt binary.fst text.fst

# the weights are in natural log; let's convert to log10 so that the numbers match with ARPA file
python ../convert_to_log10.py text.fst

# compile the text WFST into binary WFST
fstcompile --isymbols=isyms.txt --osymbols=osyms.txt --keep_isymbols --keep_osymbols text.fst.conv binary.fst.conv

# for easier visualization, plot WFST
fstdraw --portrait --isymbols=isyms.txt --osymbols=osyms.txt binary.fst.conv fst.dot
dot -Tpdf fst.dot > fst.pdf

# convert string input to far
echo $2 > input.txt
farcompilestrings --generate_keys=1 -symbols=isyms.txt --keep_symbols input.txt input.far

# apply ngram to the input and print the cost (-log10(prob))
echo "ngram probability (-log10(p))"
ngramapply binary.fst.conv input.far | farprintstrings --print_weight
echo

# run perplexity analysis for the given sentence
ngramperplexity --v=1 binary.fst input.far

