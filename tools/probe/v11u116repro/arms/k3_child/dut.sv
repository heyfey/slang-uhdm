package pk;
  parameter logic [6:0] P_LIT = 7'h73;
  parameter int P_INT = 5;
  parameter byte P_B = 8'sd7;
  parameter shortint P_S = 16'd9;
  parameter integer P_I = 11;
endpackage
module sub import pk::*; (input logic [6:0] x, output logic [3:0] y);
  always_comb case (x) P_LIT: y = 1; P_INT: y = 2; P_B: y = 3; P_S: y = 4; P_I: y = 5; default: y = 0; endcase
endmodule
module dut (input logic [6:0] x, output logic [3:0] y, output logic [3:0] y2);
  sub u1 (.x(x), .y(y));
  sub u2 (.x(~x), .y(y2));
endmodule
