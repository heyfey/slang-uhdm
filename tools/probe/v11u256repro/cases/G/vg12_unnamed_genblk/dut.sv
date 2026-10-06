// § genIpsBoundOwner256 (an unnamed generate for-block in a generate region)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  logic [2:0] t [2];
  generate
    for (genvar i = 0; i < 2; i++) begin
      assign t[i] = a[FW +: PW] + b[WW +: PW];
    end
  endgenerate
  assign q = t[0]; assign o = {1'b0, t[1]};
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
