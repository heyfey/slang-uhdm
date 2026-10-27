#!/bin/bash
# prints the count of live sweep/runner processes (anchored on the interpreter, so shell waiters never match)
ps -eo args= | grep -E '^(\S*/)?python3(\.[0-9]+)? \S*(check_svtests|svtests_matrix|verify_golden|check_probe|downstream_uhdm2rtlil)\.py|^(/bin/)?bash \S*(tests/sweep\.sh|fullsweep\.sh)' | wc -l
