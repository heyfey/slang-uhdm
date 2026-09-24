# rowcmp.sh <wd> <corp> <mode> <name> [max] : strict records of one sweep row
source /tmp/v11u130_env.sh
p=$(ls -d $1/$2/$3/$4-* | head -1); g=$(grep -o 'golden cache hit [^)]*' $p/cmds.txt | awk '{print $4}')/golden.uhdm
$STRICT_CMP --max ${5:-3} $g $p/slang.uhdm 2>&1 | tail -${6:-12}
