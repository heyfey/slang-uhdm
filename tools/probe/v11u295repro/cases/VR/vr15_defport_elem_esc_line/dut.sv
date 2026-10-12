// § rawEndLineModel295
module m #(parameter int DW = 8, N = 2)(input logic \x.y , input [DW-1:0] di [N], output logic [DW-1:0] o);
  assign o = di[0];
endmodule
module top(input logic x, input logic [7:0] d [2], output logic [7:0] o);
  m #(.DW(8)) u (.\x.y (x), .di(d), .o(o));
endmodule
