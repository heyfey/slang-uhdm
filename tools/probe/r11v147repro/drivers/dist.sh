#!/bin/bash
# dist.sh <corpus> <mode> <test> <wdA> <wdB>: order-blind dump distance to golden (diff lines) for A and B
source /tmp/v11u147_env.sh
c=$1; m=$2; t=$3; A=$4; B=$5
nrm(){ $UHDM_DUMP $1 2>/dev/null | sed -E 's#id:[0-9]+##g; s#(/[^ ,:]+)*/([^/ ,:]+\.(sv|v|svh|vh))#\2#g' | sort; }
da=$(ls -d $A/$c/$m/$t-* | head -1); db=$(ls -d $B/$c/$m/$t-* | head -1)
g=/home/heyfey/.cache/slang-uhdm-$(grep -o 'goldens/[0-9a-f]*' $da/cmds.txt | head -1)/golden.uhdm
T=/tmp/v11u147_dist_$$; nrm $g > $T.g; nrm $da/slang.uhdm > $T.a; nrm $db/slang.uhdm > $T.b
echo "$c/$m/$t A=$(diff $T.g $T.a | grep -c '^[<>]') B=$(diff $T.g $T.b | grep -c '^[<>]')"; rm -f $T.*
