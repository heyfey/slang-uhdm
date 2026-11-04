// § genIpsBoundOwner256 (for-generate, the select under a concatenation)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  logic [3:0] t [2];
  for (genvar i = 0; i < 2; i++) begin : gb
    assign t[i] = {a[FW +: PW], c};
  end
  assign o = t[0]; assign q = t[1][2:0];
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
