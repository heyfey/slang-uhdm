// r10v109 adversarial arm B -- THREE INSTANCES of one definition, each with a
// different override, so the `int` localparam the port bound names has a
// DIFFERENT value per instance.  The law resolves the name in
// `internal->getParentScope()`, which is claimed to be per-instance; this arm
// is what convicts a shared/first-instance answer.  Instance 3 is left at the
// DEFAULT while 1 and 2 are overridden (the § boundOverriddenParamWidth24
// trap: a default instance whose sibling is overridden).
// The bound param is a LOCALPARAM (never overridden itself) whose value is
// computed from the overridden parameter.
// A fourth instance sits one level DEEPER, under a wrapper, so the stale
// `currentScope` at its port-typespec build is a grandchild's body.
// MEASUREMENT ONLY.  LHS is ALWAYS golden.
module vB_leaf109 (input logic a_i, output logic b_o);
  assign b_o = ~a_i;
endmodule

module vB_kid109 #(
  parameter  int MaxC109 = 64,
  localparam int PktC109 = $clog2(MaxC109)
) (
  input  logic              clk_i,
  input  logic [PktC109:0]  sz_i,
  input  logic [0:PktC109]  rv_i,          // the SAME param on the RIGHT
  input  logic [PktC109:PktC109] both_i,   // BOTH bounds, same param
  output logic              q_o
);
  logic lb109;
  vB_leaf109 u_leaf (.a_i(clk_i), .b_o(lb109));
  assign q_o = clk_i & lb109 & sz_i[0] & rv_i[0] & both_i[PktC109];
endmodule

module vB_wrap109 #(parameter int MaxD109 = 1024) (
  input logic clk_i, input logic [31:0] w_i, output logic q_o
);
  logic q3;
  vB_kid109 #(.MaxC109(MaxD109)) u_deep (
    .clk_i(clk_i), .sz_i(w_i), .rv_i(w_i), .both_i(w_i), .q_o(q3));
  assign q_o = q3;
endmodule

module vB_inst109;
  logic clk, q1, q2, q3, q4;
  logic [31:0] w;
  vB_kid109 #(.MaxC109(16))  u_1 (.clk_i(clk), .sz_i(w), .rv_i(w), .both_i(w), .q_o(q1));
  vB_kid109 #(.MaxC109(256)) u_2 (.clk_i(clk), .sz_i(w), .rv_i(w), .both_i(w), .q_o(q2));
  vB_kid109                  u_3 (.clk_i(clk), .sz_i(w), .rv_i(w), .both_i(w), .q_o(q3));
  vB_wrap109                 u_4 (.clk_i(clk), .w_i(w), .q_o(q4));
endmodule
