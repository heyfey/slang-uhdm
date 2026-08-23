#!/usr/bin/env bash
# tab71.sh <file.ex> <instfilter>  — compact ELAB gen-scope bound table
sort -u "$1" | grep "module_inst(i_m2)" | grep -E "HC/(l|r)(/|$| )" \
 | sed 's/ span=[^ ]*//; s/ tsspan=[^ ]*//; s/ afn=[^ ]*//; s/ ts=[^ ]* tsname=[^ ]* tssgn=[^ ]*//; s/ aval=[^ ]* adec=[^ ]* asz=[^ ]*//' \
 | sed 's#TS design(work@top_earl72)/module_inst(work@top_earl72)/module_inst(i_m2)/##' \
 | grep -v "\[1\]" | sort -u
