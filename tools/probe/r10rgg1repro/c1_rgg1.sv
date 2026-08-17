package p_rgg1;
  typedef enum logic [1:0] {
    PK_OKAY = 2'b00,
    PK_ERR  = 2'b11
  } pk_e;
  typedef enum logic [3:0] { PK_H = 4'h6 } pkh_e;
  parameter int PK_INT = 7;
endpackage

interface if_rgg1;
  logic [1:0] a, b, c, d, e, f, g, h, i, j, k, l;
endinterface

module dut_rgg1 #(
  parameter int P = 1,
  parameter bit BZ = 1'b0
)(
  if_rgg1 vif,
  input logic [1:0] n1
);
  import p_rgg1::*;
  typedef enum logic [1:0] { L_OKAY = 2'b00, L_ERR = 2'b10 } l_e;
  localparam l_e LE_SEL = (BZ) ? L_ERR : L_OKAY;
  logic [1:0] w1;
  function automatic logic [1:0] f_const(int x);
    return 2'(x);
  endfunction
  assign vif.a = L_OKAY;                 // C1 enum-const ref
  assign vif.b = P;                      // C2 param ref
  assign vif.c = 2'b01;                  // C3 literal
  assign vif.d = n1;                      // C4 net ref
  assign vif.e = (BZ) ? L_ERR : L_OKAY;  // C5 ternary, const cond
  assign vif.f = P + 1;                  // C6 operation on param
  assign vif.g = f_const(2);             // C7 constant call
  assign vif.h = n1 | P;                 // C8 mixed net+param
  assign vif.i = PK_OKAY;                // C9 package enum-const ref
  assign vif.j = PK_H;                   // C10 pkg enum HEX member (width 4 -> 2)
  assign vif.k = LE_SEL;                 // C11 enum-typed localparam ref
  assign vif.l = w1;                     // C12 internal net ref
  assign w1 = L_ERR;                     // D1 plain-signal LHS, enum ref
endmodule

module c1_rgg1;
  if_rgg1 vif();
  logic [1:0] nn;
  dut_rgg1 #(.P(1), .BZ(1'b0)) u_dut (.vif(vif), .n1(nn));
endmodule
