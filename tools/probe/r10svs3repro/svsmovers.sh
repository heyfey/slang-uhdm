#!/bin/bash
# r10svs3repro/svsmovers.sh — PER-SHAPE MOVER ATTRIBUTION AGAINST GOLDEN.
#
# This is the instrument the standing brief demands, and the reason is on the
# record: it is what caught 11 over-fires that an eyeball audit of the same movers
# missed.  A mover is a database whose BYTES changed; that alone says nothing
# about DIRECTION.  For every changed dump line this script asks GOLDEN whether
# the line belongs there:
#     a REMOVED line that GOLDEN HAS      -> FINDING (we deleted convergence)
#     an ADDED line that GOLDEN LACKS     -> FINDING (we invented an object)
#     a REMOVED line that GOLDEN LACKS    -> convergence (we stopped inventing)
#     an ADDED line that GOLDEN HAS       -> convergence (we started matching)
# ADDED and REMOVED are reported SEPARATELY and never netted, and the lookup is a
# per-shape `grep -Fc` on the whole line with its INDENTATION KEPT — uhdm-dump
# encodes depth as leading spaces, and stripping it is how a sibling instrument
# in this campaign reported distance 0 for a pure re-parenting.
#
#   usage: svsmovers.sh <patched_workdir_root> <pristine_workdir_root>
#     Both roots are `--workdir` trees from scripts/verify_golden.py, so each
#     mover's GOLDEN is recoverable from its own `cmds.txt` cache line.
#
# GUARDS:
#   * uhdm-dump's FIRST LINE is the database path: every dump goes through
#     `sed 1d`, so no figure here carries a +1/+2 path bias.
#   * a mover whose GOLDEN cannot be located is reported NO_GOLDEN and counted,
#     never silently attributed.
#   * the path sets are asserted identical first, because a "no movers" reading
#     from mis-lined-up inputs is indistinguishable from a clean run.
set -u
A=${1:?patched workdir root}
B=${2:?pristine workdir root}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$DUMP" ] || { echo "FATAL: uhdm-dump not executable: $DUMP"; exit 3; }
[ -d "$A" ] && [ -d "$B" ] || { echo NO_WORKDIR; exit 6; }
la=$(mktemp); lb=$(mktemp)
(cd "$A" && find . -name slang.uhdm | sort) > "$la"
(cd "$B" && find . -name slang.uhdm | sort) > "$lb"
diff -q "$la" "$lb" > /dev/null || { echo "PATH_SETS_DIFFER — refusing"; exit 4; }
echo "PATH_SETS_IDENTICAL ($(wc -l < "$la") paths)"
T=$(mktemp -d)
movers=0; nogold=0; findings=0
while read -r p; do
    cmp -s "$A/$p" "$B/$p" && continue
    movers=$((movers + 1))
    d=$(dirname "$p")
    echo "=================================================================="
    echo "MOVER $p"
    G=$(ls "$A/$d"/slpp_all/*.uhdm "$A/$d"/slpp_unit/*.uhdm 2>/dev/null | head -1)
    if [ -z "${G:-}" ] && [ -f "$A/$d/cmds.txt" ]; then
        C=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' "$A/$d/cmds.txt")
        [ -n "${C:-}" ] && G=$(ls "$C"/*.uhdm 2>/dev/null | head -1)
    fi
    if [ -z "${G:-}" ] || [ ! -f "$G" ]; then
        echo "  NO_GOLDEN — cannot attribute this mover"
        nogold=$((nogold + 1)); continue
    fi
    "$DUMP" "$A/$p" | sed '1d' > "$T/a.dump"
    "$DUMP" "$B/$p" | sed '1d' > "$T/b.dump"
    "$DUMP" "$G"    | sed '1d' > "$T/g.dump"
    # DIRECTION: b(pristine) -> a(patched).  `-` = a line the PATCHED binary
    # STOPPED emitting (REMOVED); `+` = one it STARTED emitting (ADDED).
    diff -u "$T/b.dump" "$T/a.dump" | grep '^-' | grep -v '^---' | cut -c2- > "$T/rem"
    diff -u "$T/b.dump" "$T/a.dump" | grep '^+' | grep -v '^+++' | cut -c2- > "$T/add"
    echo "  changed lines: REMOVED=$(wc -l < "$T/rem")  ADDED=$(wc -l < "$T/add")"
    for side in rem add; do
        [ -s "$T/$side" ] || continue
        echo "  ---- $( [ $side = rem ] && echo REMOVED || echo ADDED ) shapes (count in this mover / count in GOLDEN)"
        sort "$T/$side" | uniq -c | sort -rn | while read -r n line; do
            # grep -F on the WHOLE line, indentation kept: a per-shape count.
            gc=$(grep -Fxc -- "$line" "$T/g.dump" 2>/dev/null || true)
            gc=${gc:-0}
            verdict=ok
            if [ "$side" = rem ] && [ "$gc" != 0 ]; then verdict="*** FINDING: golden HAS this removed line ($gc) ***"; fi
            if [ "$side" = add ] && [ "$gc" = 0 ];  then verdict="*** FINDING: golden LACKS this added line ***"; fi
            printf '    %6s  golden=%-5s %s\n        %s\n' "$n" "$gc" "$verdict" "$line"
        done
        # A second pass purely to COUNT findings (the loop above runs in a
        # subshell, so its counter cannot escape).
        c=$(sort -u "$T/$side" | while read -r line; do
                gc=$(grep -Fxc -- "$line" "$T/g.dump" 2>/dev/null || true); gc=${gc:-0}
                if [ "$side" = rem ] && [ "$gc" != 0 ]; then echo x; fi
                if [ "$side" = add ] && [ "$gc" = 0 ]; then echo x; fi
            done | wc -l)
        findings=$((findings + c))
    done
done < "$la"
echo "=================================================================="
echo "MOVERS=$movers  NO_GOLDEN=$nogold  FINDING_SHAPES=$findings"
rm -rf "$T" "$la" "$lb"
[ "$findings" = 0 ] && [ "$nogold" = 0 ] && echo "PASS: every changed line in every mover moved TOWARD golden." \
  || echo "ATTENTION: read the findings above; do not summarise them."
