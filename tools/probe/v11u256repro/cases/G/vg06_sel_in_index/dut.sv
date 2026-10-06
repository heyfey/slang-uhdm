// § genIpsBoundOwner256 (a for-generate, the select inside another select index)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  logic [7:0] t;
  for (genvar i = 0; i < 1; i++) begin : gb
    assign t[i] = b[a[FW +: PW]];
  end
  assign q = t[2:0]; assign o = t[7:4];
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
