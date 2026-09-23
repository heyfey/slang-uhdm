package pk;
  parameter logic [31:0] P_CAT = { 16'h0, 16'h73 };
  parameter logic [31:0] P_REP = { {25{1'b0}}, 7'h37 };
endpackage
module dut import pk::*; (input logic [31:0] x, output logic [31:0] z, output logic [31:0] z2);
  localparam logic [31:0] P_CAT = { 16'h1, 16'h73 };
  assign z = x & P_CAT;
  assign z2 = x & P_REP;
endmodule
