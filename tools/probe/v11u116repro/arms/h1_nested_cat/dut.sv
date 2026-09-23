package pk;
  parameter logic [7:0] A = 8'h3;
  parameter logic [31:0] P_N = { 24'h0, A };
  parameter logic [31:0] P_Q = P_N;
  parameter logic [31:0] P_T = (A > 2) ? {24'h0, A} : 32'h0;
endpackage
module dut import pk::*; (input logic [31:0] x, output logic [31:0] z, output logic [31:0] z2, output logic [31:0] z3);
  assign z = x & P_N;
  assign z2 = x & P_Q;
  assign z3 = x & P_T;
endmodule
