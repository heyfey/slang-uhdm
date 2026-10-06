// § genIpsBoundOwner256 (instance depth 2, the generate scope in the child)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  for (genvar i = 0; i < 4; i++) begin : gb
    assign o[i] = a[FW +: PW] == b[WW +: PW];
  end
  assign q = '0;
endmodule
module mid(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u2 (.*);
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  mid u (.*);
endmodule
