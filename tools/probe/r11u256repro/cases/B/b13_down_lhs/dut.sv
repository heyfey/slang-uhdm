// § elabBodyIpsBoundSelName256 (an indexed down select and a select on the left side)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  logic [7:0] t;
  assign t[FW +: PW] = c ? a[2:0] : b[WW +: PW];
  assign t[1:0] = '0; assign t[7:5] = '0;
  assign q = c ? a[FW+PW -: PW] : t[2:0];
  assign o = '0;
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
