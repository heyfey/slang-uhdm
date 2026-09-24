package pk;
  parameter logic [31:0] P_CAT = { 16'h0, 16'h73 };
  parameter logic [31:0] P_REP = { {25{1'b0}}, 7'h37 };
endpackage
module a1 import pk::*; (input logic [31:0] x, output logic [31:0] z);
  assign z = x & P_CAT;
endmodule
module dut import pk::*; (input logic [31:0] x, output logic [31:0] z, output logic [31:0] z2);
  a1 u (.x(x), .z(z));
  assign z2 = x | P_CAT;
endmodule
