## Language Model using OpenFST & OpenGRM Ngram
This is to demonstrate how an ARPA language model is converted to WFST<br>

### Requirements
Install openfst & ngram library
```
http://www.openfst.org/twiki/bin/view/FST/WebHome
http://www.openfst.org/twiki/bin/view/GRM/NGramLibrary
```

### Example Run
```
mkdir test && cd test
../run.sh ../test.arpa "i also little more ." 
```
Follow the sentence `i also little more .` token by token in the `fst.pdf` graph or `text.fst.conv` from the initial state
, and add all the transition weights and final state weights.<br>
 The sum will equal to the probability of the given sentence, including `<s>` and `</s>` tokens.

### Construct LG by composing Lexicon (spelling) and Grammar (ngram)
```
cd hbka
./run.sh
```
By composing lexicon with grammar, we can optimize search because we can apply the weight before the entire word is determined. That is, for example, from a given state if we only have two choices, say "LIKE" and "LOVE" with weight 1/3 and 2/3, respectively. If we don't compose the lexicon, we have to wait until the entire vocab is formed, i.e., at least five character-level predictions (including space) before we can assign the weights. With lexicon composed, we can apply the weight of 1 at the first character "L" and weight of 0 for the rest, and weight of 1/3, 2/3, and 0 for the second charactor "I", "O", and the rest, respectively. Clearly, this allows us to optimize beam search where pruning is necessary.
