// § deferredPortElemImplicitEnd231 — two instances with two widths, the dimension split over two lines
module arb #(parameter int N = 4, parameter int DW = 8) (
  input [DW-1:
         0]      data_i [N],
  output [3:0] o
);
  assign o = data_i[0][3:0];
endmodule
module top(input [7:0] d [4], input [15:0] e [2], output [3:0] g, output [3:0] h);
  arb #(.N(4), .DW(8)) u (.data_i(d), .o(g));
  arb #(.N(2), .DW(16)) v (.data_i(e), .o(h));
endmodule
