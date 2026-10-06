// § genIpsBoundOwner256 (for-generate, the select a system-call argument and a unary operand)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  for (genvar i = 0; i < 2; i++) begin : gb
    assign o[i] = $countones(a[FW +: PW]) == 2;
  end
  for (genvar i = 2; i < 4; i++) begin : gu
    assign o[i] = ~a[WW +: 1];
  end
  assign q = '0;
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
