// § genIpsBoundOwner256 (for-generate, the select in an always_comb (control: a process))
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  for (genvar i = 0; i < 4; i++) begin : gb
    always_comb o[i] = a[FW +: PW] == b[WW +: PW];
  end
  assign q = '0;
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
