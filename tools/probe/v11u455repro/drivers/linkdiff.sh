#!/bin/bash
# linkdiff.sh <golden.uhdm> <ours.uhdm>: multiset diff of call links (count of golden-only and ours-only lines)
L=/tmp/v11u455_tools/links
$L $1 | sort > /tmp/v11u455_ld_g.$$; $L $2 | sort > /tmp/v11u455_ld_o.$$
g=$(comm -23 /tmp/v11u455_ld_g.$$ /tmp/v11u455_ld_o.$$ | wc -l); o=$(comm -13 /tmp/v11u455_ld_g.$$ /tmp/v11u455_ld_o.$$ | wc -l)
echo "links golden-only=$g ours-only=$o"
[ -n "$SHOW" ] && { comm -23 /tmp/v11u455_ld_g.$$ /tmp/v11u455_ld_o.$$ | head -$SHOW | sed 's/^/G /'; comm -13 /tmp/v11u455_ld_g.$$ /tmp/v11u455_ld_o.$$ | head -$SHOW | sed 's/^/O /'; }
rm -f /tmp/v11u455_ld_g.$$ /tmp/v11u455_ld_o.$$
