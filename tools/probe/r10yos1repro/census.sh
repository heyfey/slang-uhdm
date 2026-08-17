#!/usr/bin/env bash
# r10yos1repro/census.sh — corpus-wide census for § dottedTopNameBareElab.
#
# The law only fires when a DESIGN TOP's module name contains a '.', which in
# SystemVerilog is reachable ONLY through an escaped identifier.  So the census
# is: every module/interface/program/primitive DECLARATION in either corpus
# whose declared name is escaped, split into "name has a dot" (candidate) and
# "name has no dot" (cannot fire).
#
#   usage: ./census.sh
#
# GUARDS:
#   * the dot must be inside the DECLARED NAME token, not anywhere on the line
#     — `module \dut$interfaces$sim_sram_if (a, \ss_if.start_addr );` has a dot
#     in a PORT name and must NOT be counted, so the name is cut at the first
#     whitespace before testing;
#   * the uhdm2rtlil corpus is filtered to files a test can actually feed the
#     tools (dut.sv / dut.v / project.f members): the `*_from_*.v` and
#     `*_synth.v` files there are Yosys OUTPUT and are never compiled;
#   * hits are printed, not just counted, so a zero is auditable.
set -u
SL_ROOT=${SL_ROOT:-$HOME/git-repos/Surelog}
U2R_ROOT=${U2R_ROOT:-$HOME/git-repos/uhdm2rtlil/test}

scan() { # $1=label  $2..=files
  local label=$1; shift
  local dotted=0 plain=0
  for f in "$@"; do
    [ -f "$f" ] || continue
    while IFS= read -r line; do
      # strip up to the backslash that opens the escaped name, then cut at the
      # first whitespace: what remains is EXACTLY the declared identifier.
      nm=${line#*\\}
      nm=${nm%%[[:space:]]*}
      case "$nm" in
        *.*) dotted=$((dotted+1)); echo "  DOTTED-NAME  $f: \\$nm" ;;
        *)   plain=$((plain+1)) ;;
      esac
    done < <(grep -hE '^[[:space:]]*(module|macromodule|interface|program|primitive)[[:space:]]+\\' "$f" 2>/dev/null)
  done
  echo "$label: escaped-name declarations = $((dotted+plain))  (dotted = $dotted, plain = $plain)"
}

echo "== surelog corpus =="
mapfile -t slfiles < <(find "$SL_ROOT/tests" "$SL_ROOT/third_party/tests" \
    \( -name '*.v' -o -name '*.sv' -o -name '*.svh' -o -name '*.vh' \) 2>/dev/null)
scan "surelog" "${slfiles[@]}"

echo
echo "== uhdm2rtlil corpus (compiled inputs only) =="
mapfile -t u2rfiles < <(find "$U2R_ROOT" \( -name 'dut.sv' -o -name 'dut.v' \) 2>/dev/null)
# project.f members, resolved relative to the .f file's directory
while IFS= read -r pf; do
  dir=$(dirname "$pf")
  while IFS= read -r tok; do
    case "$tok" in
      -*|+*|'') continue ;;
    esac
    [ -f "$dir/$tok" ] && u2rfiles+=("$dir/$tok")
  done < <(tr ' \t' '\n\n' < "$pf")
done < <(find "$U2R_ROOT" -name 'project.f' 2>/dev/null)
scan "uhdm2rtlil" "${u2rfiles[@]}"

echo
echo "A DOTTED-NAME hit is only a MOVER if that module is also a design TOP"
echo "(not instantiated by anything else) — see grid.sh arm h_dotchild."
