#!/bin/bash
# r11u419 quiet.sh: count live measurement processes (bracketed patterns so the
# checker never matches its own command line; agent shell wrappers excluded)
pgrep -af 'tests/swee[p].sh|svtests_matri[x]|check_svtest[s]|verify_golde[n]|check_prob[e]|downstream_uhdm2rtli[l]' | grep -v 'shell-snapshots' | wc -l
