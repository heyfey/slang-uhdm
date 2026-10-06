// § genIpsBoundOwner256 (an if-generate, the select the whole target)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [7:0] o, output logic [2:0] q);
  if (LB == 1) begin : gw
    assign o[FW +: PW] = a[2:0];
  end
  assign q = b[2:0];
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [7:0] o, output logic [2:0] q);
  m u (.*);
endmodule
