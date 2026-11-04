// § genIpsBoundOwner256 (for-generate, the member-path select under & and == (Earlgrey flash_phy_rd))
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  typedef struct packed { logic [7:0] addr; } rb_t;
  rb_t rb [4];
  for (genvar i = 0; i < 4; i++) begin : gb
    assign rb[i].addr = a ^ b;
    assign o[i] = (c & rb[i].addr[FW +: PW] == a[WW +: PW]) | (rb[i].addr == b);
  end
  assign q = '0;
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
