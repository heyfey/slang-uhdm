package pk;
  parameter logic [31:0] P_CAT = { 16'h0, 16'h73 };
  parameter logic [31:0] P_REP = { {25{1'b0}}, 7'h37 };
endpackage
interface ifc import pk::*; (input logic [31:0] x);
  logic [31:0] z;
  assign z = x & P_CAT;
  always_comb if (x == P_REP) z = 0;
endinterface
module dut (input logic [31:0] x);
  ifc i (.x(x));
endmodule
