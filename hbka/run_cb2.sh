# create from corpus

set -x

arpa=$1
w2c=$2

python create_class_lex.py $w2c > L_class.txt
ngramread --ARPA $arpa | fstarcsort --sort_type=ilabel - G_class.fst
fstprint --save_isymbols=isym.txt G_class.fst > /dev/null
fstcompile --isymbols=ascii.syms --osymbols=isym.txt --keep_isymbols --keep_osymbols L_class.txt | fstarcsort --sort_type=olabel - L_class.fst

fstcompose L_class.fst G_class.fst | fstproject - | fstdeterminize - | fstminimize - | fstrmepsilon - | fstdeterminize - | fstminimize - | fstarcsort - LG_class.fst

set +x
