package pk;
  parameter logic [6:0] P_LIT = 7'h73;
  parameter int P_INT = 5;
endpackage
interface ifc import pk::*; (input logic [6:0] x);
  logic [3:0] y;
  always_comb case (x) P_LIT: y = 1; P_INT: y = 2; default: y = 0; endcase
endinterface
module dut (input logic [6:0] x);
  ifc i (.x(x));
endmodule
