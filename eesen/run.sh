set -e
set -x

dir="."

ngramread --ARPA $1 G.fst
fstprint --save_isymbols=vocab.txt G.fst > /dev/null
awk '{print $1}' < vocab.txt | grep -v "<.*>" | LANG= LC_ALL= sort | sed 's:([0-9])::g' | \
    perl -e 'while(<>){ chop; $str="$_"; foreach $p (split("", $_)) {$str="$str $p"}; print "$str\n";}' \
    > lexicon_words.txt

( echo '[BREATH] [BREATH]'; echo '[NOISE] [NOISE]'; echo '[COUGH] [COUGH]';
  echo '[SMACK] [SMACK]'; echo '[UM] [UM]'; echo '[UH] [UH]'; echo '<UNK> <UNK>'; echo '<SPACE> <SPACE>';) | \
  cat - lexicon_words.txt | sort | uniq > lexicon.txt || exit 1;

perl -ape 's/(\S+\s+)(.+)/${1}1.0\t$2/;' < lexicon.txt > lexiconp.txt || exit 1;

ndisambig=`utils/add_lex_disambig.pl lexiconp.txt lexiconp_disambig.txt`
ndisambig=$[$ndisambig+1]

space_char="<SPACE>"

cut -d' ' -f2- $dir/lexicon_words.txt | tr ' ' '\n' | sort -u > units_nosil.txt

# The complete set of lexicon units, indexed by numbers starting from 1
(echo '[BREATH]'; echo '[NOISE]'; echo '[COUGH]'; echo '[SMACK]';
 echo '[UM]'; echo '[UH]'; echo '<SPACE>'; echo '<UNK>'; ) | cat - units_nosil.txt | awk '{print $1 " " NR}' > units.txt

( for n in `seq 0 $ndisambig`; do echo '#'$n; done ) > disambig.list

cat units.txt | awk '{print $1}' > units.list
(echo '<eps>'; echo '<blk>';) | cat - units.list disambig.list | awk '{print $1 " " (NR-1)}' > tokens.txt

cat lexiconp.txt | awk '{print $1}' | sort | uniq  | awk '
  BEGIN {
    print "<eps> 0";
  }
  {
    printf("%s %d\n", $1, NR);
  }
  END {
    printf("#0 %d\n", NR+1);
  }' > words.txt || exit 1;
