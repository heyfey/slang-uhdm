#!/usr/bin/env bash
# ordcmp <golden.uhdm> <ours.uhdm> [type-regex]: per-type creation order (restored
# address order within a type) of both databases, keyed type+name+span+parent-type;
# prints the per-type sequences that differ (unified diff).
G=$1; O=$2; T=${3:-.*}
IDL=${IDL:-/tmp/r11u120_idlist}
f() { $IDL "$1" "$T" | awk '{p=""; for(i=7;i<=NF;i++) if($i=="<-"){p=$(i+1); sub(/@.*/,"",p)} print $4, $5, $6, p}' | awk '{print $1"\t"$0}' | sort -s -k1,1 | cut -f2; }
diff <(f $G) <(f $O)
