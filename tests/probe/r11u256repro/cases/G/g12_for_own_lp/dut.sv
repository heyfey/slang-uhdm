// § genIpsBoundOwner256 (for-generate, the module's own localparam and header parameter (control))
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m #(parameter int HP = 3) (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  localparam int LF = 2;
  logic [2:0] t [2];
  for (genvar i = 0; i < 2; i++) begin : gb
    assign t[i] = a[LF +: HP];
  end
  assign o = {t[0][1:0], t[1][1:0]}; assign q = t[1];
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
