// b9 — the LEAK arm.  The law's flag is set around buildUnpackedArrayTypedefTs,
// but that function calls buildStructTs for a STRUCT element, and buildStructTs
// mints its own unpacked-array member element typespecs through the very
// anonAggregateElemTs the law re-routes.  A struct declared in a PACKAGE is
// compiled by Surelog through CompilePackage.cpp:263, which passes a VARIABLE
// `reduce` — not the module body's hard Reduce::No.  If golden folds there and
// our leaked flag keeps it symbolic, this is an AWAY.
package p;
  parameter int PN = 5;
  typedef struct {
    logic [PN-1:0] q [2];
    logic [PN-1:0] r;
  } ps_t;
endpackage

module dut #(parameter int N = 4, parameter int DEPTH = 8) (
  input logic clk,
  output logic o
);
  import p::*;
  // the package struct as the ELEMENT of a body unpacked-dim typedef
  typedef ps_t parr_t [DEPTH];
  parr_t pa;
  // a control: the same package struct with NO unpacked-dim typedef wrapper
  ps_t plain;
  assign o = plain.r[0] ^ pa[0].r[0];
endmodule
