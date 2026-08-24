#!/usr/bin/env bash
# r10buvm32repro/arm32.sh — one purpose-built arm, BOTH views: Surelog golden vs
# our binary, dumps + the OFFICIAL uhdm-cmp on each side.  Every command is
# echoed with its rc into <workdir>/cmds.txt so the binary each database came
# from is auditable BY PATH (RESUME §9).  MEASUREMENT ONLY.
#   arm32.sh <file.sv> <binary> <workdir>
#!/usr/bin/env bash
# arm.sh <file.sv> <bin> <workdir> — golden + ours, both views, dumps + cmp.
set -u
SV=$(readlink -f "$1"); BIN=$2; W=$3
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$W"; : > "$W/cmds.txt"
run(){ echo "$*" >>"$W/cmds.txt"; "$@" >/dev/null 2>&1; echo "rc=$? $*" >>"$W/cmds.txt"; }
for v in def elab; do
  EF=""; SF=""
  [ "$v" = elab ] && { EF="--elabuhdm"; SF="-elabuhdm"; }
  ( cd "$W" && run "$SL" -parse -nocache -nowritecache -noprecompiledcache -d coveruhdm $SF -o "$W/g_$v" "$SV" )
  run "$BIN" "$SV" $EF -o "$W/o_$v.uhdm"
  G="$W/g_$v/slpp_all/surelog.uhdm"
  "$DUMP" "$G" > "$W/dump.g.$v.txt" 2>&1
  "$DUMP" "$W/o_$v.uhdm" > "$W/dump.o.$v.txt" 2>&1
  "$CMP" "$G" "$W/o_$v.uhdm" > "$W/cmp.$v.txt" 2>&1
  echo "$v: cmp=$(wc -l < "$W/cmp.$v.txt") heads=$(grep -c '^LHS:' "$W/cmp.$v.txt" || true)"
done
