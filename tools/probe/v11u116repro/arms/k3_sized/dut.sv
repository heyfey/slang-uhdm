package pk;
  parameter logic [6:0] P_A = 'h73;
  parameter logic [6:0] P_B = 115;
  parameter logic [6:0] P_C = 7'b111_0011;
  parameter logic [6:0] P_D = 7'o163;
  parameter logic [6:0] P_E = 7'sd5;
  parameter logic [7:0] P_F = 4'hF;
  parameter int P_G = 'd5;
  parameter logic P_H = 1'b1;
endpackage
module dut import pk::*; (input logic [6:0] x, output logic [3:0] y);
  always_comb case (x) P_A: y = 1; P_B: y = 2; P_C: y = 3; P_D: y = 4; P_E: y = 5; P_F: y = 6; P_G: y = 7; P_H: y = 8; default: y = 0; endcase
endmodule
