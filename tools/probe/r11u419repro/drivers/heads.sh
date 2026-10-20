#!/bin/bash
# r11u419 heads.sh <workroot> <list> : uhdm-cmp first object (LHS/RHS) per kept runner row
CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp; [ -x $CMP ] || exit 1
H=$(dirname $(readlink -f $0)); W=$1
while read -r t <&3; do d=$W/${t%.sv}; [ -f $d/slang.uhdm ] || { echo "$t NO_DB"; continue; }
 G=$(bash $H/gold.sh $d); [ -f "$G" ] || { echo "$t NO_GOLD"; continue; }
 o=$(timeout 600 $CMP $G $d/slang.uhdm 2>&1 | awk '/^LHS:/{f=1} f&&/^[a-z_]+: /{print; n++} n==2{exit} f&&/RHS: <null>|LHS: <null>/{print}' | sed 's/, id:[0-9]*//' | tr '\n' ' ' | cut -c1-240)
 echo "$t | $o"
done 3< $2
