## TLG Compilation for CTC

Tokens graph maps CTC's output token to lexical character.

![alt text](T.png "T Graph")

Lexical graph maps alphabet characters to words.

![alt text](L.png "L Graph")

Composition of T and L graphs maps CTC's acoustic tokens to words.
We add `<phi>` self loop to be composed with G's backoff transitions

![alt text](TL.png "TL Graph")

Grammar graph maps sequence of words to probability.
`<phi>` represents backoff  or failure transition.

![alt text](G.png "G Graph")

Composition of TL and G graph maps CTC's acoustic tokens to ngram

![alt text](TLG.png "TLG Graph")
