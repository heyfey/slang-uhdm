// § elabBodyIpsBoundSelName256 (operands of + == & ^ and a shift)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  assign q = a[FW +: PW] + b[WW +: PW];
  assign o[0] = a[FW +: PW] == b[WW +: PW];
  assign o[1] = ^(a[FW +: PW] ^ b[WW +: PW]);
  assign o[3:2] = a[WW +: 2] << 1;
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
