// § rawEndLineModel295
`define T logic [DW-1:0]
module m #(parameter int DW = 8, N = 2)(input `T di [N], output logic [DW-1:0] o);
  assign o = di[0];
endmodule
module top(input logic [7:0] d [2], output logic [7:0] o);
  m #(.DW(8)) u (.di(d), .o(o));
endmodule
