package pk;
  parameter logic [31:0] P_CAT = { 16'h0, 16'h73 };
  parameter logic [31:0] P_REP = { {25{1'b0}}, 7'h37 };
endpackage
module dut import pk::*; (input logic [31:0] x, output logic [31:0] z);
  logic [31:0] v = P_CAT;
  var logic [31:0] w = P_REP & x;
  assign z = v ^ w;
endmodule
