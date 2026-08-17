// v6 — L1 x L2 crossed: an iface-member cont-assign whose Rhs is a reference to
// a localparam that itself folded through a ternary onto an enum member (the
// implementer's named residue R2, measured explicitly), plus the R1/R3/R4
// residues re-measured so a fix that "helps" one does not silently change them.
package p_v6;
  typedef enum logic [1:0] { E_A = 2'b00, E_B = 2'b10 } e_t;
endpackage

interface if_v6;
  logic [1:0] a, b, c, d, e;
endinterface

module dut_v6 #(parameter int P = 1, parameter bit BZ = 1'b0) (if_v6 vif);
  import p_v6::*;
  localparam e_t LE_SEL = (BZ) ? E_B : E_A;
  assign vif.a = LE_SEL;              // R2 enum-typed localparam ref
  assign vif.b = P;                   // R1 plain param ref
  assign vif.c = (BZ) ? E_B : E_A;    // R3 ternary in a cont_assign
  assign vif.d = P + 1;               // R4 operation on a param
  assign vif.e = E_A;                 // control: the shipped law
endmodule

module v6_vrgg1;
  if_v6 vif();
  dut_v6 #(.P(1), .BZ(1'b0)) u (.vif(vif));
endmodule
