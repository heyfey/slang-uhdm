// § deferredPortElemImplicitEnd231 — implicit beside `logic`, one space before the name
module arb #(parameter int N = 4, parameter int DW = 8) (
  input [DW-1:0] data_i [N],
  input logic [DW-1:0]   data2_i [N],
  output [3:0] o
);
  assign o = data_i[0][3:0];
endmodule
module top(input [7:0] d [4], output [3:0] g);
  arb #(.N(4), .DW(8)) u (.data_i(d), .data2_i(d), .o(g));
endmodule
