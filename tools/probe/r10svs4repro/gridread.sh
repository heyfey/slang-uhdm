#!/bin/bash
# r10svs4repro/gridread.sh — read the GRID cell-for-cell out of two dumps.
#
# For every `hier_path` in a dump, print (line, vpiName, then each path element's
# TYPE and span) as ONE line, so golden and ours can be put side by side and the
# three gating fields read off directly:
#     index PRESENT/ABSENT in the name | last element TYPE | element SPANS
#
#   usage: gridread.sh <g.dump> <o.dump> [line-regex]
#
# GUARDS:
#   * both dumps are existence- AND non-empty-checked; a missing dump is a hard
#     exit, never an empty (and therefore falsely "identical") report.
#   * hier_path *parents* are printed by uhdm-dump inside every child block, so a
#     naive grep double-counts.  This walks the INDENT COLUMN: a hier_path header
#     opens a block and every line indented deeper by exactly 2 that starts with
#     `\_` is one of ITS children.  A `\_hier_path` appearing as a `|vpiParent:`
#     child is skipped (its own indent is deeper than the vpiParent marker).
#   * the element list printed is Path_elems in dump order, which is the order
#     hier_path::Compare walks -- so a TYPE difference here is a real cmp field.
set -u
G=${1:?g.dump}
O=${2:?o.dump}
RE=${3:-.}
for f in "$G" "$O"; do
    [ -s "$f" ] || { echo "FATAL: dump missing or empty: $f"; exit 3; }
done

read_side() {
    awk '
    function ind(s) { match(s, /[^ ]/); return RSTART - 1 }
    /\\_hier_path:/ {
        # a hier_path that is the child of a |vpiParent: marker is a back-pointer
        if (prevparent) { prevparent = 0; next }
        hpind = ind($0)
        line = $0
        sub(/^[ ]*\\_hier_path: /, "", line)
        # (name), line:L:C, endln:L:C
        nm = line; sub(/^\(/, "", nm); sub(/\).*/, "", nm)
        sp = line; sub(/^[^,]*, /, "", sp); gsub(/ /, "", sp)
        out = "hp[" nm "] " sp " elems:"
        inhp = 1
        next
    }
    {
        if (inhp) {
            i = ind($0)
            if (i <= hpind) { print out; inhp = 0 }
            else if (i == hpind + 2 && $0 ~ /^[ ]*\\_/) {
                e = $0
                sub(/^[ ]*\\_/, "", e)
                ty = e; sub(/:.*/, "", ty)
                sp2 = e
                if (sp2 ~ /line:/) { sub(/^[^,]*, /, "", sp2); gsub(/ /, "", sp2) }
                else sp2 = "NOLOC"
                enm = e; sub(/^[a-z_]*: /, "", enm); sub(/^\(/, "", enm); sub(/\).*/, "", enm)
                if (e !~ /^hier_path/ && ty != "operation")
                    out = out " {" ty " (" enm ") " sp2 "}"
            }
        }
        prevparent = ($0 ~ /\|vpiParent:$/ || $0 ~ /\|vpiIndex:$/ || $0 ~ /\|vpiActual:$/)
    }
    END { if (inhp) print out }
    ' "$1"
}

echo "=== GOLDEN hier_paths"
read_side "$G" | grep -E "$RE" | sort -u
echo
echo "=== OURS hier_paths"
read_side "$O" | grep -E "$RE" | sort -u
