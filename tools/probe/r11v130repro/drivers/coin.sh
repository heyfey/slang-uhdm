# coin.sh <wdA> <wdB> <corp> <name> <mode> : order-blind sorted dump diff line count
source /tmp/v11u130_env.sh
a=$(ls -d $1/$3/$5/$4-*/slang.uhdm); b=$(ls -d $2/$3/$5/$4-*/slang.uhdm)
na=$($UHDM_DUMP $a 2>/dev/null | sed "s#$1#WD#g" | sort); nb=$($UHDM_DUMP $b 2>/dev/null | sed "s#$2#WD#g" | sort)
echo "$4/$5 unsorted=$(diff <($UHDM_DUMP $a 2>/dev/null | sed "s#$1#WD#g") <($UHDM_DUMP $b 2>/dev/null | sed "s#$2#WD#g") | grep -c '^[<>]') sorted=$(diff <(echo "$na") <(echo "$nb") | grep -c '^[<>]')"
