package pk;
  parameter logic [6:0] P_LIT = 7'h73;
endpackage
module dut import pk::*; #(parameter logic [6:0] Q = P_LIT) (input logic [6:0] x, output logic [3:0] y);
  always_comb case (x) P_LIT: y = 1; Q: y = 2; default: y = 0; endcase
endmodule
