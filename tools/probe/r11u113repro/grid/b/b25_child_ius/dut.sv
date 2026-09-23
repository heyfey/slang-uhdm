package pk; parameter int unsigned P = 5; parameter int unsigned Q = 2; endpackage
module c import pk::*; (input logic [7:0] i, output logic [7:0] o);
  logic [P:0] x;
  assign x = i[5:0];
  assign o = x;
endmodule
module top (input logic [7:0] i, output logic [7:0] o);
  c u (.i(i), .o(o));
endmodule
