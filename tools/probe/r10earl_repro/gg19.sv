// gg19.sv — § genScopeVarBoundFoldTs19's witness.  work@prim_gate_gen (Top)
// r=1: the LEFT bound of a GEN-SCOPE variable's packed range folds to a
// constant on both sides, but golden's constant carries a vpiTypespec
// (ref_typespec) and ours carries none.  Corpus:
// `logic [NumInnerRounds:0][DataWidth-1:0] inner_data;` inside
// `for (genvar k = ...) begin : gen_outer_round` (prim_gate_gen.sv:86:12).
//
// Rows: a gen-scope variable (the head's shape), a gen-scope NET, and a
// module-body variable as the control.
module gg19 #(
  parameter int NumInner = 2,
  parameter int DataW    = 8
) (
  input  logic       clk,
  output logic [7:0] o
);
  // control: module-body variable with the same two bounds
  logic [NumInner:0][DataW-1:0] mod_data;
  // control: module-body variable whose RIGHT bound is the bare param
  logic [7:NumInner] mod_rb;

  for (genvar k = 0; k < 2; k++) begin : gen_round
    logic [NumInner:0][DataW-1:0] inner_data;
    wire  [NumInner:0][DataW-1:0] inner_net;
    // the u2r genscope_cells shape: a bare param as the RIGHT bound
    logic [7:NumInner] inner_rb;
    assign inner_net = inner_data;
  end

  if (NumInner > 0) begin : gen_if
    logic [NumInner:0] if_lb;
    logic [7:NumInner] if_rb;
  end

  // the u2r genscope_cells shape EXACTLY: a gen block inside a CHILD
  // instance whose parameter is OVERRIDDEN at instantiation.
  gg19sub #(.CW(3)) u_sub ();
  // ...and the NEGATIVE control: the same child with its parameter left at
  // the DEFAULT (no override).
  gg19sub2 u_sub2 ();

  assign o = mod_data[0] ^ 8'(mod_rb);
endmodule

module gg19sub #(
  parameter int CW = 4
) ();
  if (CW < 64) begin : g_narrow
    logic [7:CW] sub_rb;
    logic [CW:0] sub_lb;
  end
endmodule

module gg19sub2 #(
  parameter int CW2 = 4
) ();
  if (CW2 < 64) begin : g_narrow2
    logic [7:CW2] sub2_rb;
    logic [CW2:0] sub2_lb;
  end
endmodule
