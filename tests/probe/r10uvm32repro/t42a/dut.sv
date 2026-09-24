// t42a — WHO owns a package typedef's IMPORT-CLONE listing object?
//
// Pass 31's ranked #1 (SeqDriver's 1148 `INST` rows, golden `@adpcm_pkg` where
// we say `@uvm_pkg`) reduces, via r10uvm32td, to ONE object field: the
// second-generation listing clone that every importer shares.  For a VECTOR
// typedef we already follow Surelog's LAST-WRITER stamp; for an ENUM and a
// STRUCT we stamp the FIRST writer (and something later re-stamps the HOME
// package).  Cells, all read on the OBJ lines of `r10uvm32td`:
//
//   (1) ONE importer          — is the clone owned by the importer or the home?
//   (2) TWO importers         — first, last, or home?
//   (3) an importer that does NOT USE the type at all (pc42 below) — does the
//       stamp follow the package LISTING or the package's USE of the type?
//   (4) a MODULE importing last — does a module ever take the stamp?
//   (5) the same four cells for a vector typedef (the control we match today)
//       and for a STRUCT (the third kind).
package pa42;
  typedef enum int { A0, A1 } aen_t;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } ast_t;
  typedef logic [7:0] avec_t;
  function void a_use(input aen_t e, input ast_t s, input avec_t v);
  endfunction
endpackage

// FIRST importer, uses all three types.
package pb42;
  import pa42::*;
  function void b_use(input aen_t e, input ast_t s, input avec_t v);
  endfunction
endpackage

// SECOND importer that USES NOTHING from pa42 — cell (3).  If the stamp
// follows the LISTING, pc42 wins over pb42; if it follows the USE, pb42 wins.
package pc42;
  import pa42::*;
  function void c_none(input int k);
  endfunction
endpackage

// THIRD importer, uses all three again — the plain "last importer" cell.
package pd42;
  import pa42::*;
  function void d_use(input aen_t e, input ast_t s, input avec_t v);
  endfunction
endpackage

// LAST importer, and an EXPLICIT type-only import: it LISTS all three
// typedefs but gets no wildcard subroutine clone whose formals could stamp
// them.  Cell (3') — "the package LISTING stamps" predicts pe42 here, "the
// imported subroutine clone's formal stamps" predicts pd42.
package pe42;
  import pa42::aen_t;
  import pa42::ast_t;
  import pa42::avec_t;
  function void e_none(input int k);
  endfunction
endpackage

module top42a;
  import pa42::*;
  aen_t  e;
  ast_t  st;
  avec_t v;
  initial begin
    e = A0;
    st = '0;
    v = 8'h1;
    a_use(e, st, v);
  end
endmodule
