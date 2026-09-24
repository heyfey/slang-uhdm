// t3: OVERRIDE and re-pass -- what the ELAB view carries when the type
// parameter is left at its default (u0), overridden with a LITERAL-bounded
// type (u1), and overridden with a type whose bound is an EXPRESSION over a
// parameter at the instantiation site (u2).
module leaf #(
    parameter  int  LW = 8,
    parameter  type PT = logic [LW-1:0],
    localparam type LT = logic [LW-1:0]
) (input PT p, input LT l, output logic o);
  assign o = ^{p,l};
endmodule
module dut #(parameter int W = 5) (output logic o1, output logic o2, output logic o3);
  leaf #(.LW(W))                    u0 (.p('0), .l('0), .o(o1));
  leaf #(.LW(W), .PT(logic [2:0]))  u1 (.p('0), .l('0), .o(o2));
  leaf #(.LW(W), .PT(logic [W-1:0])) u2 (.p('0), .l('0), .o(o3));
endmodule
