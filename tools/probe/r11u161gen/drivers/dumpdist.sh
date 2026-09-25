#!/bin/bash
# dumpdist.sh <sweepA> <sweepB> <corpus> <mode> <test>: order-blind uhdm-dump distance to the golden of one row in two
# sweep workdirs (sorted dumps, workdir paths normalised; lines in the symmetric difference).  Fail-closed on $FENCED.
[ -n "$FENCED" ] || { echo "dumpdist.sh: source drivers/env.sh" >&2; exit 2; }
A=$1; B=$2; co=$3; mo=$4; t=$5
echo "$t" | grep -qwE "$(echo $FENCED | tr ' ' '|')" && { echo "dumpdist.sh: fenced row refused" >&2; exit 2; }
W=$(mktemp -d /tmp/r11u161_scratch/dd.XXXX)
da=$(ls -d $A/$co/$mo/$t-* | grep -E "/$t-[0-9a-f]{8}$" | head -1); db=$(ls -d $B/$co/$mo/$t-* | grep -E "/$t-[0-9a-f]{8}$" | head -1)
gc=$(grep -o 'golden cache [a-z]* *[^ )]*' $da/cmds.txt | awk '{print $NF}')
norm() { sed -E "s#$1##g; s#/tmp/r11u161_sw[A-Z0-9]+##g" | tail -n +2 | sort; }
$UHDM_DUMP $gc/golden.uhdm 2>&1 | norm "$gc" > $W/g
$UHDM_DUMP $da/slang.uhdm 2>&1 | norm "$da" > $W/a
$UHDM_DUMP $db/slang.uhdm 2>&1 | norm "$db" > $W/b
na=$(diff $W/g $W/a | grep -c '^[<>]'); nb=$(diff $W/g $W/b | grep -c '^[<>]'); nab=$(diff $W/a $W/b | grep -c '^[<>]')
echo -e "$co\t$mo\t$t\tdist_A=$na\tdist_B=$nb\tA_vs_B=$nab"
rm -rf $W
