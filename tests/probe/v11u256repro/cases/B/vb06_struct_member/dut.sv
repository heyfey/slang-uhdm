// § elabBodyIpsBoundSelName256 (the select of a struct member under an operation)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  typedef struct packed { logic [7:0] f; } s_t;
  s_t s;
  assign s.f = a;
  assign q = c ? s.f[FW +: PW] : '0;
  assign o = b[3:0];
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
