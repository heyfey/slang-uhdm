// § genIpsBoundOwner256 (for-generate, the indexed part select the whole right side)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  logic [2:0] t [4];
  for (genvar i = 0; i < 4; i++) begin : gb
    assign t[i] = a[FW +: PW];
  end
  assign o = {t[0][0], t[1][0], t[2][0], t[3][0]}; assign q = t[0];
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
