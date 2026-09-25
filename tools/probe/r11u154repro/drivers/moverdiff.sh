#!/bin/bash
# moverdiff.sh <corpus> <mode> <test> <lawwd> <priswd>: strict differing-record sets (--max 5000) of pristine vs law
# for one row; prints counts and the records only one side has (fenced names refused).
[ -n "${FENCED:-}" ] || { echo "FENCED unset"; exit 2; }
c=$1; m=$2; t=$3; L=$4; P=$5
for f in $FENCED; do [ "$t" = "$f" ] && { echo "fenced: skipped"; exit 0; }; done
dl=$(ls -d $L/$c/$m/$t-*); dp=$(ls -d $P/$c/$m/$t-*)
gc=$(grep -o 'golden cache hit [^)]*' $dp/cmds.txt | awk '{print $4}'); g=$(find $gc -name '*.uhdm' | head -1)
/tmp/r11u154_bin/strictcmp --max 5000 $g $dp/slang.uhdm 2>&1 | paste - - - | grep '^#' | sed 's/^#[0-9]* //' | sort > /tmp/r11u154_md_p.txt
/tmp/r11u154_bin/strictcmp --max 5000 $g $dl/slang.uhdm 2>&1 | paste - - - | grep '^#' | sed 's/^#[0-9]* //' | sort > /tmp/r11u154_md_l.txt
echo "$c/$m/$t pristine=$(wc -l < /tmp/r11u154_md_p.txt) law=$(wc -l < /tmp/r11u154_md_l.txt) only_law=$(comm -13 /tmp/r11u154_md_p.txt /tmp/r11u154_md_l.txt | wc -l) only_pris=$(comm -23 /tmp/r11u154_md_p.txt /tmp/r11u154_md_l.txt | wc -l)"
