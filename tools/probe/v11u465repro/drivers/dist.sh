#!/bin/bash
# dist.sh <golden.uhdm> <ours.uhdm>: path-normalized uhdm-dump diff line count
source /tmp/v11u465_env.sh || exit 1
norm(){ "$UHDM_DUMP" "$1" 2>/dev/null | sed -E 's#/[^ ,:]*/##g; s/^\|?[[:space:]]*//' ; }
diff <(norm "$1") <(norm "$2") | grep -c '^[<>]'
