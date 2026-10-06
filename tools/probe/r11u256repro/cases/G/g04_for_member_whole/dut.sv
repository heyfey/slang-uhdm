// § genIpsBoundOwner256 (for-generate, the select on a struct member path, whole right side)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  typedef struct packed { logic [7:0] addr; } rb_t;
  rb_t rb [2];
  assign rb[0].addr = a; assign rb[1].addr = b;
  logic [2:0] t [2];
  for (genvar i = 0; i < 2; i++) begin : gb
    assign t[i] = rb[i].addr[FW +: PW];
  end
  assign o = {t[0][1:0], t[1][1:0]}; assign q = t[0];
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
