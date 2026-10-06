// § genIpsBoundOwner256 (for-generate, a net declaration assignment)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  for (genvar i = 0; i < 2; i++) begin : gb
    wire [2:0] w = a[FW +: PW];
    assign o[i] = w[0];
  end
  assign o[3:2] = '0; assign q = '0;
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
