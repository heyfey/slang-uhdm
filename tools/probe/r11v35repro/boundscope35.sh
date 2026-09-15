#!/usr/bin/env bash
# r11v35 (VERIFIER) — THE BLAST-RADIUS GATE: prove that every dump line the law
# changes lies INSIDE a range-bound expression.
#
#   usage: boundscope35.sh <pristine.dump> <law.dump>
#
# WHY IT EXISTS.  `uhdm-cmp` reports ONE head, and a head that MOVES after a
# change is ambiguous: it can be a pre-existing difference the fix unmasked, or
# a NEW one the fix created.  This settles it without guessing: strip the
# object ids (they renumber whenever the object count changes) and diff the two
# databases' dumps.  If no changed line names a structural object or a judged
# field OUTSIDE a bound expression (module_inst, vpiInstance, a variable, a
# net, a port, a typespec member, a container list), then every head that is
# not itself a bound constant/operation was already there in the pristine
# database and was merely reached later in the walk.
#
# Prints the changed-line total and the out-of-scope count; out-of-scope 0 is
# the gate.
set -u
A=${1:?pristine dump}
B=${2:?law dump}
# strip the banner: its first line names the database's own path, which differs
# between the two runs and is not a change in the design.
norm() { tail -n +2 "$1" | sed -E 's/, id:[0-9]+//g'; }
tot=$(diff <(norm "$A") <(norm "$B") | grep -c '^[<>]'; true)
out=$(diff <(norm "$A") <(norm "$B") | grep '^[<>]' \
      | grep -cE 'module_inst|interface_inst|package:|vpiInstance|_var:|net:|port:|typespec_member|vpiVariables|vpiNets|vpiPorts|vpiTypespecMember'; true)
echo "changed-lines=$tot outside-bound-expression=$out"
[ "$out" = 0 ] || diff <(norm "$A") <(norm "$B") | grep '^[<>]' \
      | grep -E 'module_inst|interface_inst|package:|vpiInstance|_var:|net:|port:|typespec_member|vpiVariables|vpiNets|vpiPorts|vpiTypespecMember' | head -20
exit 0
