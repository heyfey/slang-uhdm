// r10earl5 ll.sv — the 5-head `TotalWakeWidth` cluster (pwrmgr_pkg.sv:19).
// The census after the jj laws ranks this FIRST: five module DEF listings
// (pwrmgr, pwrmgr_cdc, pwrmgr_fsm, pwrmgr_slow_fsm, pwrmgr_wake_info) all fail
// on ONE object, and the two constants differ in NOTHING but the constType:
//     golden  constant pwrmgr_pkg.sv:19:31 {ct=9 (UINT) sz=32 dec=18}
//     ours    constant                     {ct=7 (INT)  sz=32 dec=18}
// It is the MATERIALIZED IMPORT copy of an UNTYPED package localparam whose
// initialiser is a FOLDED arithmetic expression (`WakeUpPeris + 2`).  The
// package's OWN listings keep the unfolded `+` operation on both sides, so
// this is the import copy's re-render only.
// Shape copied from pwrmgr_wake_info.sv: `module m import pkg::*; (ports);`
// with the localparam used as a PORT WIDTH.
package lp;

  parameter  WakeUpPeris    = 16;
  localparam TotalWakeWidth = WakeUpPeris + 2;   // + fold  -> ?
  localparam DiffWidth      = WakeUpPeris - 4;   // - fold  -> ?
  localparam ProdWidth      = WakeUpPeris * 2;   // * fold  -> ?
  localparam PlainWidth     = 12;                // no fold (control)
  localparam int TypedWidth = WakeUpPeris + 1;   // TYPED control

endpackage

module lchild import lp::*; (
  input  logic                      clk_i,
  input  logic [TotalWakeWidth-1:0] data_i,
  output logic                      o
);
  // The other rows are NOT read at all: a wildcard `import pkg::*;` in the
  // module header materializes EVERY package parameter into both module
  // listings whether or not it is referenced (this is what makes all five
  // pwrmgr modules carry TotalWakeWidth), and any read of them here — a port
  // range bound, a bit-select index — drags in an UNRELATED divergence, each
  // ranked as a fresh residue.
  assign o = clk_i ^ data_i[0];
endmodule

module ll (input logic clk_i, output logic o);
  logic [17:0] d;
  assign d = '0;
  lchild u_l (.clk_i(clk_i), .data_i(d), .o(o));
endmodule
