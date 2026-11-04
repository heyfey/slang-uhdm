// § elabBodyIpsBoundSelName256 (a ternary branch in a program continuous assignment)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
program p import fp::*; (input logic [7:0] a, input logic c, output logic [2:0] q);
  assign q = c ? a[FW +: PW] : '0;
endprogram
module top(input logic [7:0] a, input logic c, output logic [2:0] q);
  p u (.*);
endmodule
