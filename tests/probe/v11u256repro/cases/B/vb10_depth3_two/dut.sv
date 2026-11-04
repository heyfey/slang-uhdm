// § elabBodyIpsBoundSelName256 (two instances at depths 2 and 3, a ternary branch)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  assign q = c ? a[FW +: PW] : b[WW +: PW];
  assign o = b[3:0];
endmodule
module mid(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u2 (.*);
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q, output logic [3:0] o2, output logic [2:0] q2);
  mid u1 (.*);
  m u3 (.a(a), .b(b), .c(c), .o(o2), .q(q2));
endmodule
