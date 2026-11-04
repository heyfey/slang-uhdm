// § genIpsBoundOwner256 (a for-generate, the select inside a replication)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  logic [5:0] t [2];
  for (genvar i = 0; i < 2; i++) begin : gb
    assign t[i] = {2{a[FW +: PW]}};
  end
  assign q = t[0][2:0]; assign o = t[1][3:0];
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
