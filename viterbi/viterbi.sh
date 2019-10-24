arc=standard

# construct input (acoustic -log_prob)
cat << EOF > T.syms
<eps> 0
<blank> 1
<space> 2
<phi> 3
a 11
b 12
c 13
EOF

cat << EOF > U.txt
0 1 <blank> <blank> 1
0 1 <space> <space> 2
0 1 a a 3
0 1 b b 4
0 1 c c 5
1 2 <blank> <blank> 5
1 2 <space> <space> 4
1 2 a a 3
1 2 b b 2
1 2 c c 1
2 3 <blank> <blank> 2
2 3 <space> <space> 3
2 3 a a 1
2 3 b b 3
2 3 c c 2
3
EOF

fstcompile --arc_type=$arc --isymbols=T.syms --osymbols=T.syms --keep_isymbols --keep_osymbols U.txt | fstarcsort --sort_type=olabel - U.fst

# construct tokens
cat << EOF > T.txt
0 0 <blank> <eps>
0 0 <space> <eps>
0 1 a a
1 1 a <eps>
1 0 <space> <space>
1 0 <phi> <eps>
0 2 b b
2 2 b <eps>
3 0 <space> <space>
2 0 <phi> <eps>
0 3 c c
3 3 c <eps>
3 0 <space> <space>
3 0 <phi> <eps>
0
EOF

fstcompile --arc_type=$arc --isymbols=T.syms --osymbols=T.syms --keep_isymbols --keep_osymbols T.txt | fstarcsort --sort_type=ilabel - T.fst

# compose
fstphicompose 3 U.fst T.fst UT.fst
fstprint UT.fst UT.txt
fstdraw --portrait UT.fst | dot -Tpdf > UT.pdf

fstproject --project_output UT.fst | fstrmepsilon - | fstdeterminize - | fstshortestpath --nshortest=5 - | fstrmepsilon - | fstdeterminize - | fstminimize - | fstdraw --portrait | dot -Tpdf > paths.pdf
