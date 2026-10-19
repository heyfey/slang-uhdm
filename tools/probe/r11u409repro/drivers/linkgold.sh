#!/bin/bash
# link cached Surelog goldens into <row>/slpp_all/surelog.uhdm for every kept row under $1
find "$1" -name cmds.txt | while read c; do d=$(dirname "$c"); g=$(sed -n 's/.*golden cache hit \([^)]*\)).*/\1/p' "$c"); [ -n "$g" ] || continue; u=$(find "$g" -name golden.uhdm | head -1); [ -n "$u" ] && mkdir -p "$d/slpp_all" && ln -sf "$u" "$d/slpp_all/surelog.uhdm"; done
