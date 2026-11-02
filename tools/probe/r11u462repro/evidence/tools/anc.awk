# print the ancestor chain of record N (1-based line) in a strictcmp record dump
{ split($0,f,"\t"); d=f[1]+0; L[d]=$0; if (NR==N) { for (i=0;i<=d;i++) print substr(L[i],1,200); exit } }
