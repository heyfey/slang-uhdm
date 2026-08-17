// v2 — the enumTernTakenLeafEnc1 walk in every PARAM shape: enum-typed vs
// int-typed vs logic-typed Lhs, taken/untaken, nested, non-const condition.
package p_v2;
  typedef enum logic [1:0] { E_A = 2'b00, E_B = 2'b10, E_C = 2'b11 } e_t;
  typedef enum logic [3:0] { H_A = 4'h6, H_B = 4'ha } h_t;
  typedef enum int { I_A = 7, I_B = 9 } i_t;
endpackage

module dut_v2 #(parameter bit BZ = 1'b0, parameter bit B1 = 1'b1) (input logic nc);
  import p_v2::*;
  localparam e_t       P1 = (BZ) ? E_B : E_A;      // B1 enum-typed, UNTAKEN=E_B
  localparam e_t       P2 = (B1) ? E_B : E_A;      // B2 enum-typed, TAKEN=E_B
  localparam int       P3 = (BZ) ? E_B : E_A;      // B3 INT-typed Lhs
  localparam logic[1:0] P4 = (B1) ? E_B : E_A;     // B4 logic-typed Lhs
  localparam h_t       P5 = (B1) ? H_B : H_A;      // B5 HEX member
  localparam i_t       P6 = (BZ) ? I_B : I_A;      // B6 base-less enum int
  localparam e_t       P7 = (BZ) ? E_C : ((B1) ? E_B : E_A); // B7 NESTED
  logic [1:0]          P8 = (nc) ? E_B : E_A;      // B8 NON-const condition (var)
  localparam e_t       P9 = E_B;                   // B9 bare (pre-existing law)
  localparam int       PA = (B1) ? 5 : 6;          // BA literal leaf (no enum)
  localparam e_t       PB = e_t'((BZ) ? E_B : e_t'(E_A + 0));  // BB operation leaf
endmodule

module v2_vrgg1;
  logic nn;
  dut_v2 #(.BZ(1'b0), .B1(1'b1)) u (.nc(nn));
endmodule
