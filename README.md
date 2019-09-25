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
Follow the sentence `i also little more .` token by token in the `fst.pdf` graph or `text.fst.conv` from state 0
, and add all the transition weights and initial/final states.<br>
 The sum will equal to the probability of the given sentence, including `<s>` and `</s>` tokens.