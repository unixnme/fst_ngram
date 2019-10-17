# create from corpus

set -x

corpus=$1
wcluster --threads 5 --c 100 --text $corpus --output_dir brown
python create_path.py brown/paths > w2c.txt
python create_class_corpus.py $corpus w2c.txt > corpus_class.txt
lmplz --o 2 --discount_fallback < corpus_class.txt > class-2gram.arpa
python create_class_lex.py w2c.txt > L_class.txt
ngramread --ARPA class-2gram.arpa | fstarcsort --sort_type=ilabel - G_class.fst
fstprint --save_isymbols=isym.txt G_class.fst > /dev/null
fstcompile --isymbols=ascii.syms --osymbols=isym.txt --keep_isymbols --keep_osymbols L_class.txt | fstarcsort --sort_type=olabel - L_class.fst

fstcompose L_class.fst G_class.fst | fstproject - | fstdeterminize - | fstminimize - | fstrmepsilon - | fstdeterminize - | fstminimize - | fstarcsort - LG_class.fst

set +x
