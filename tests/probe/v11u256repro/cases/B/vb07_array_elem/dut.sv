// § elabBodyIpsBoundSelName256 (the select of an unpacked array element under an operation)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  logic [7:0] arr [2];
  assign arr[0] = a; assign arr[1] = b;
  assign q = arr[1][FW +: PW] & arr[0][WW +: PW];
  assign o = b[3:0];
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
