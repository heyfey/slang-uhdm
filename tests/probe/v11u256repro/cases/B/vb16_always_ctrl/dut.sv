// § elabBodyIpsBoundSelName256 (an always_comb control beside the continuous assignment)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  logic [2:0] r;
  always_comb r = c ? a[FW +: PW] : '0;
  assign q = c ? r : a[WW +: PW];
  assign o = b[3:0];
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
