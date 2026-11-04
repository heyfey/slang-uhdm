// § deferredPortElemImplicitEnd231 — a non-ANSI port
module arb (data_i, o);
  parameter int N = 4;
  parameter int DW = 8;
  input   [DW-1:0]   data_i [N];
  output [3:0] o;
  assign o = data_i[1][3:0];
endmodule
module top(input [7:0] d [4], output [3:0] g);
  arb #(.N(4), .DW(8)) u (.data_i(d), .o(g));
endmodule
