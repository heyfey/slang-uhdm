#!/bin/bash
# r10rggen6uu2: file-stripped diff of the unbased-unsized census (our elab
# clones carry no VpiFile, so the path column is dropped on both sides).
sed 's|^[^ ]*/||;s|^[^:]*:||' /tmp/r10rggen6_uug.txt | sort > /tmp/r10rggen6_uug2.txt
sed 's|^[^ ]*/||;s|^[^:]*:||' /tmp/r10rggen6_uus.txt | sort > /tmp/r10rggen6_uus2.txt
diff /tmp/r10rggen6_uug2.txt /tmp/r10rggen6_uus2.txt > /tmp/r10rggen6_uu2.diff
echo "diff=$(grep -c '^[<>]' /tmp/r10rggen6_uu2.diff)"
head -${1:-40} /tmp/r10rggen6_uu2.diff
