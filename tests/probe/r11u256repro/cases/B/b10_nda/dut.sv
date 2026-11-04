// § elabBodyIpsBoundSelName256 (a net declaration assignment and an always_comb (controls))
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  wire [2:0] w = c ? a[FW +: PW] : '0;
  assign q = w;
  always_comb o = {1'b0, c ? b[WW +: PW] : 3'b0};
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
