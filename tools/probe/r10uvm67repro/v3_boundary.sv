// r10uvm67 VERIFIER arm v3 — the SIX attack surfaces the implementer's own
// README.verifier.md §2.3/§2.4 names as UNMEASURED.  One cell per surface.
// LHS is always golden (Surelog); RHS ours.

// ---- v3a: a FOREIGN package supplying the range bound -------------------
package v3other;
  parameter V3O_W = 100*8-1;     // folded, foreign to the function's package
  parameter V3O_LIT = 799;       // literal twin, foreign
endpackage

// ---- v3b: a $unit-scope parameter and a $unit-scope enum ----------------
parameter V3U_W = 50*8-1;        // compilation-unit parameter
typedef enum int { V3E_LO = 0, V3E_HI = 399 } v3e_t;   // $unit enum

package v3pkg;
  import v3other::*;
  parameter V3P_W = 120*8-1;     // same-package folded (the landed witness shape)

  // v3a1 — package function, return range names an IMPORTED FOREIGN param
  function bit[V3O_W:0] v3_foreign_bits(string s);
    v3_foreign_bits = 0;
  endfunction

  // v3a2 — the same, but QUALIFIED rather than imported
  function bit[v3other::V3O_LIT:0] v3_qual_bits(string s);
    v3_qual_bits = 0;
  endfunction

  // v3b1/v3b2 REMOVED: a package may not reference a compilation-unit item
  // ("cannot reference compilation unit item from within a package"), so the
  // unitParamMap / enumConstMap bindScope arms are UNREACHABLE under this
  // pass's Package-only gate.  Surface closed by language rule, not by luck.

  // v3c — return type IS a package TYPEDEF whose own range names a param
  //       (the § pkgTdCloneRefNoBind18 fence this pass must NOT override)
  typedef bit [V3P_W:0] v3_bits_t;
  function v3_bits_t v3_td_bits(string s);
    v3_td_bits = 0;
  endfunction

  // control — same-package folded param, the shape the pass targets
  function bit[V3P_W:0] v3_own_bits(string s);
    v3_own_bits = 0;
  endfunction
endpackage

// ---- v3d: an INTERFACE-scope and a PROGRAM-scope subroutine -------------
interface v3if;
  parameter V3I_W = 30*8-1;
  function bit[V3I_W:0] v3if_bits(string s);
    v3if_bits = 0;
  endfunction
endinterface

program v3prog;
  parameter V3G_W = 20*8-1;
  function bit[V3G_W:0] v3prog_bits(string s);
    v3prog_bits = 0;
  endfunction
endprogram
