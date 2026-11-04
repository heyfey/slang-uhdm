// § elabBodyIpsBoundSelName256 (a struct member path select nested under an operation)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  typedef struct packed { logic [7:0] addr; } rb_t;
  rb_t r;
  assign r.addr = a;
  assign q = c ? r.addr[FW +: PW] : '0;
  assign o = '0;
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
