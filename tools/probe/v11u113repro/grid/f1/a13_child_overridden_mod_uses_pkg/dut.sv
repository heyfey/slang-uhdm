package pk; parameter int unsigned P = 5; endpackage
module c import pk::*; #(parameter int W = 2) (input logic [7:0] i, output logic [7:0] o);
  logic [P:0] x;
  logic [W:0] y;
  assign x = i[5:0];
  assign y = i[W:0];
  assign o = x ^ y;
endmodule
module top (input logic [7:0] i, output logic [7:0] o);
  c #(.W(3)) u (.i(i), .o(o));
endmodule
