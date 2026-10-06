// § elabBodyIpsBoundSelName256 (two instances, one overriding nothing (the select names per instance))
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  assign q = c ? a[FW +: PW] : '0;
  assign o = '0;
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [3:0] o2, output logic [2:0] q, output logic [2:0] q2);
  m u (.*);
  m v (.a(a), .b(b), .c(c), .o(o2), .q(q2));
endmodule
