#!/bin/bash
# pair.sh <gridA.txt> <gridB.txt>: join two gridall outputs by case key; prints key, verdict A, verdict B.
join <(awk '{print $1, $5}' "$1" | sort) <(awk '{print $1, $5}' "$2" | sort) | column -t
