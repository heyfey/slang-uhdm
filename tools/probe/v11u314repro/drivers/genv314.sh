#!/bin/bash
# v11u314 genv314.sh: writes the verifier's fresh attack cases under cases/ (absolute paths from this file). Each
# case's first line names the law it attacks.  cls <dir> <law> <stmt...>: the class template of r11u314's
# gen314.sh with the statements as probe()'s body; raw <dir> <law> <text...>: the whole file after the law line.
H=$(cd "$(dirname "$0")" && pwd); C=$(cd "$H/.." && pwd)/cases
case "$C" in /*/tools/probe/v11u314repro/cases) ;; *) echo "genv314: cases root unexpected: $C" >&2; exit 2;; esac
cls() { local d=$C/$1 law=$2; shift 2; mkdir -p "$d"; {
  echo "// § $law"
  cat <<'T'
package p; localparam int N = 1; localparam logic [3:0] NL = 2; parameter NU = 2; typedef enum int {E0, E1, E2} e_t; localparam int M = 1; function automatic int f(int x); return x; endfunction endpackage
typedef struct { int k; int m; } s_t;
class item; int f; int g[4]; int k; item nx; function int get(); return f; endfunction static function int sget(); return 0; endfunction static function int sget2(int x = 1); return x; endfunction class inner; static function int isg(); return 0; endfunction endclass endclass
typedef item item_t;
class holder; item arr[4]; int idx[4]; int k; holder hh; logic [7:0] v; int q[$]; holder harr[4]; endclass
class grid;
  localparam int N2 = 1;
  item iarr[4]; item i2[4][4]; int midx[4]; int i; int j; int r; bit c; holder h; holder harr[4]; int ia[4];
  int ib[4][4]; logic [7:0] lv; s_t s; string sarr[4]; int qa[$]; string sq[$]; holder hs[4]; int ih[$];
  function int fn(int x); return x; endfunction
  static function int sg(); return 0; endfunction
  function void probe();
T
  printf '    %s\n' "$@"
  cat <<'T'
  endfunction
  function int fwd(int x); return x; endfunction
endclass
module top; endmodule
T
  } > "$d/dut.sv"; }
raw() { local d=$C/$1 law=$2; shift 2; mkdir -p "$d"; { echo "// § $law"; printf '%s\n' "$@"; } > "$d/dut.sv"; }
. "$H/gridv314.inc"
