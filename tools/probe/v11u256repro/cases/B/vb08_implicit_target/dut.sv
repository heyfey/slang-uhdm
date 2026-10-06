// § elabBodyIpsBoundSelName256 (an implicit-net target under a ternary)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  assign imp = c ? a[FW] : b[WW];
  assign q = c ? a[FW +: PW] : b[WW +: PW];
  assign o = {3'b0, imp};
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
