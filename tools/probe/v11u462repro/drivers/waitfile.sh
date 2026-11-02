#!/bin/bash
# waitfile.sh <file> <pattern> <maxsec>
t=0; while ! grep -q "$2" "$1" 2>/dev/null; do sleep 15; t=$((t+15)); [ $t -ge $3 ] && { echo TIMEOUT; exit 1; }; done; cat "$1"
