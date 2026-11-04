// § genIpsBoundOwner256 (a two-level for-generate, the select an operand two scopes down)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  logic [2:0] t [2][2];
  for (genvar i = 0; i < 2; i++) begin : gb
    for (genvar j = 0; j < 2; j++) begin : gc
      assign t[i][j] = a[FW +: PW] ^ b[WW +: PW];
    end
  end
  assign q = t[0][1]; assign o = {1'b0, t[1][0]};
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
