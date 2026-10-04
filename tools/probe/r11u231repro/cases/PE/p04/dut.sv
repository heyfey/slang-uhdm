// § deferredPortElemImplicitEnd231 — a signed implicit type and two packed dimensions
module arb #(parameter int N = 4, parameter int DW = 8) (
  input signed [DW-1:0]    ds_i [N],
  input [1:0][DW-1:0]      dd_i [N],
  output [3:0] o
);
  assign o = ds_i[0][3:0] ^ dd_i[0][0][3:0];
endmodule
module top(input signed [7:0] d [4], input [1:0][7:0] e [4], output [3:0] g);
  arb #(.N(4), .DW(8)) u (.ds_i(d), .dd_i(e), .o(g));
endmodule
