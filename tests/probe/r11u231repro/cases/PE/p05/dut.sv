// § deferredPortElemImplicitEnd231 — the packed range written by a macro, an output port
`define W(x) [x-1:0]
module arb #(parameter int N = 4, parameter int DW = 8) (
  input  `W(DW)   data_i [N],
  output [DW-1:0] data_o [N]
);
  assign data_o = data_i;
endmodule
module top(input [7:0] d [4], output [7:0] q [4]);
  arb #(.N(4), .DW(8)) u (.data_i(d), .data_o(q));
endmodule
