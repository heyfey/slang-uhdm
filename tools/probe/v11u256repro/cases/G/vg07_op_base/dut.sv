// § genIpsBoundOwner256 (a for-generate, a base computed from two package parameters)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  logic [2:0] t [2];
  for (genvar i = 0; i < 2; i++) begin : gb
    assign t[i] = a[FW + WW +: PW];
  end
  assign q = t[0]; assign o = {1'b0, t[1]};
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
