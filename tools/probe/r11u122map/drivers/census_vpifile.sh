#!/bin/bash
# Span writes (VpiLineNo setters) with no VpiFile / setLoc / copyLoc within 10 lines.
cd "$(dirname "$0")/../../../../src" || exit 1
for f in *.cpp; do
  awk -v f=$f '{L[NR]=$0} END{for(i=1;i<=NR;i++) if (L[i] ~ /VpiLineNo\([^)]/ && L[i] !~ /^[ \t]*\/\//) { ok=0; for(j=i-10;j<=i+10;j++) if (L[j] ~ /VpiFile\(/ || L[j] ~ /copyLoc\(|setLoc\(/) ok=1; if(!ok) print f":"i": "L[i] }}' $f
done
