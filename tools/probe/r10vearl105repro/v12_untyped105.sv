// r10v105 v12 — THE UNTYPED AND RANGED-UNTYPED SOURCES.  The full-CLONE arm
// (`c5`) does NOT consult `intAtom105` at all — it fires on ANY parameter whose
// elaborated `param_assign` Rhs is a constant with an eagerly-bound
// `int_typespec`, which r10earl104's replication fold mints.  An UNTYPED
// parameter is exactly the case `adjustCopiedParamConst64` REFUSES (its fence
// F-A1), so the two halves disagree about it here.
module v12_leaf105 (input logic [31:0] sig, output logic [63:0] z);
  localparam         RU  = {2{2'b01}};      // UNTYPED, replication-folded
  localparam [3:0]   RR  = {2{2'b01}};      // RANGED-UNTYPED, replication-folded
  localparam         DU  = 5;               // UNTYPED, a plain decimal
  localparam [3:0]   DR  = 4'hA;            // RANGED-UNTYPED, a hex literal
  for (genvar i = 0; i < 2; i++) begin : gen_u
    logic [63:0] u0,u1,u2,u3,u4,u5;
    assign u0 = RU ^ sig;          // plain: the NEW window
    assign u1 = sig[RU];           // a bit-select INDEX: an OLD window
    assign u2 = RR ^ sig;
    assign u3 = sig[RR];
    assign u4 = DU ^ sig;
    assign u5 = DR ^ sig;
  end
  assign z = 64'b0;
endmodule

module v12_untyped105 (input logic [31:0] sig, output logic [63:0] z);
  logic [63:0] zc;
  v12_leaf105 u_leaf (.sig(sig), .z(zc));
  assign z = zc;
endmodule
