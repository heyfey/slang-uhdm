package pk;
  parameter logic [31:0] P_CAT = { 16'h0, 16'h73 };
  parameter logic [31:0] P_REP = { {25{1'b0}}, 7'h37 };
endpackage
module dut import pk::*; (input logic clk, input logic [31:0] x, output logic [63:0] z);
  always_ff @(posedge clk) z[P_CAT[4:0]] <= x[0];
  always_ff @(posedge clk) z[P_REP] <= x[1];
endmodule
