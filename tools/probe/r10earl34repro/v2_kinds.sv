// r10earl34 VERIFIER ARM V2 — the INDEX-KIND cells the implementer's grid
// leaves EMPTY, all of them reachable by `idxText34`'s new call sites.
//
//  v2_hex   : the package localparam's initializer is a SIZED HEX literal.
//             § hierSelPkgParamFold's own table says the splice then uses the
//             parameter's LITERAL spelling (`5'h8`), not its decimal value —
//             measured only on the RANGE-select arm (dm_csrs).  Never measured
//             on this builder.  A wrong answer here is a WRONG NAME, not a
//             missing fold.
//  v2_cat   : the package localparam is initialised from a CONCATENATION.
//             The brief named this cell explicitly ("(e) a parameter that does
//             NOT reduce (concat-init — the § 32 discriminator may reappear
//             here)").  It is absent from a1/a2/a3.
//  v2_clog  : the index is `$clog2(PkgLp)` — a SystemFunction call with the
//             package parameter buried in an argument.  collectPkgParamFolds
//             visits the whole subtree, so it fires inside the call.
//  v2_var   : a VARIABLE index in the SAME path as a package-parameter index.
//             This is the only cell that reaches `prefix + "." + dotted`, the
//             site where the FOLDED name leaks into a CHILD ref_obj's naming
//             scope.  Nothing in a1/a2/a3 has a variable index at all.
//  v2_shadow: a MODULE localparam with the SAME NAME as the package one, used
//             in a neighbouring index — the cell that separates an offset
//             splice from a name-keyed one in the opposite direction from a3.

package v2_pkg;
  localparam bit [4:0] PkgHex = 5'h8;
  localparam int       PkgCat = {2'b10, 2'b01};   // = 9
  localparam int       PkgLp  = 8;
  localparam int       Dup    = 3;
endpackage

typedef struct packed {
  logic [3:0] q;
} v2_inner_t;

typedef struct packed {
  v2_inner_t base;
  logic [15:0] a_source;
} v2_cfg_t;

module v2_kinds import v2_pkg::*; (
  input  logic       clk,
  input  logic [3:0] idx,
  output logic [3:0] o
);
  localparam int Dup = 5;              // shadows v2_pkg::Dup at module scope

  v2_cfg_t [15:0] arr;
  v2_cfg_t [15:0] arr2;
  v2_cfg_t [15:0] arr3;
  v2_cfg_t [15:0] arr4;
  v2_cfg_t [15:0] arr5;

  assign arr[PkgHex].base.q  = 4'h0;   // v2_hex
  assign arr2[PkgCat].base.q = 4'h1;   // v2_cat
  assign arr3[$clog2(v2_pkg::PkgLp)].base.q = 4'h2;  // v2_clog
  assign arr4[Dup].base.q    = 4'h3;   // v2_shadow (module Dup = 5)
  assign arr5[v2_pkg::Dup].base.q = 4'h4;           // v2_shadow, package side

  // v2_var : a VARIABLE index next to a package-parameter index, in a PROCESS
  // LVALUE — the one shape that reaches `prefix + "." + dotted`.
  v2_cfg_t [15:0] arrv;
  always_comb begin
    arrv[v2_pkg::PkgLp].a_source[idx] = 1'b0;
  end

  assign o = arr[0].base.q;
endmodule
