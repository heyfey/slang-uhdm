package p;
  parameter int unsigned W = 4;
endpackage
module sub import p::*; (input logic c, input logic [31:0] x, output logic [31:0] z);
  assign z = $bits(x[W:0]);
endmodule
module top (input logic c, input logic [31:0] x, output logic [31:0] z);
  sub u (.*);
endmodule
