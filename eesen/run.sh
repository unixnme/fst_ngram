set -e
set -x

arpa=$1

ngramread --ARPA $arpa G.fst
fstprint --save_isymbols=vocab.txt G.fst > /dev/null
awk '{print $1}' < vocab.txt | grep -v "<s>" | grep -v "</s>" | grep -v "<epsilon>" | LANG= LC_ALL= sort | sed 's:([0-9])::g' | \
    perl -e 'while(<>){ chop; $str="$_"; foreach $p (split("", $_)) {$str="$str $p"}; print "$str\n";}' \
    > lexicon_words.txt

( echo '[BREATH] [BREATH]'; echo '[NOISE] [NOISE]'; echo '[COUGH] [COUGH]';
  echo '[SMACK] [SMACK]'; echo '[UM] [UM]'; echo '[UH] [UH]'; echo '<UNK> <UNK>'; echo '<SPACE> <SPACE>';) | \
  cat - lexicon_words.txt | sort | uniq > lexicon.txt || exit 1;

perl -ape 's/(\S+\s+)(.+)/${1}1.0\t$2/;' < lexicon.txt > lexiconp.txt || exit 1;

ndisambig=`utils/add_lex_disambig.pl lexiconp.txt lexiconp_disambig.txt`
ndisambig=$[$ndisambig+1]

space_char="<SPACE>"

cut -d' ' -f2- lexicon_words.txt | tr ' ' '\n' | sort -u > units_nosil.txt

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

utils/ctc_token_fst.py tokens.txt | fstcompile --isymbols=tokens.txt --osymbols=tokens.txt \
   --keep_isymbols=true --keep_osymbols=true | fstarcsort --sort_type=olabel > T.fst || exit 2;

utils/make_lexicon_fst.pl --pron-probs lexiconp_disambig.txt 0.5 "$space_char" '#'$ndisambig | \
    fstcompile --isymbols=tokens.txt --osymbols=words.txt \
    --keep_isymbols=true --keep_osymbols=true |   \
    fstaddselfloops  "echo $token_disambig_symbol |" "echo $word_disambig_symbol |" | \
    fstarcsort --sort_type=olabel > L.fst || exit 1;


oov_list=/dev/null
sed 's/<unk>/<UNK>/g' < $arpa | \
   grep -v '<s> <s>' | \
   grep -v '</s> <s>' | \
   grep -v '</s> </s>' | \
   arpa2fst - | fstprint | \
   utils/remove_oovs.pl $oov_list | \
   utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=words.txt \
     --osymbols=words.txt  --keep_isymbols=true --keep_osymbols=true | \
    fstrmepsilon | fstarcsort --sort_type=ilabel > G2.fst

fsttablecompose L.fst G2.fst | fstdeterminizestar --use-log=true | \
  fstminimizeencoded | fstarcsort --sort_type=ilabel > LG2.fst || exit 1;
fsttablecompose T.fst LG2.fst > TLG2.fst || exit 1;

