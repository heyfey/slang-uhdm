#!/bin/bash
# order-blind distance: v11u116_ob.sh a.dump b.dump
n() { sed -E 's/, id:[0-9]+//; s#/tmp/[^ ,]*##g; s#/home/[^ ,]*##g' "$1" | sort; }
diff <(n "$1") <(n "$2") | grep -c '^[<>]'; true
