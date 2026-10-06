// § elabBodyIpsBoundSelName256 (an interface body continuous assignment)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
endpackage
interface ifc import fp::*; (input logic [7:0] a, input logic c);
  logic [2:0] q;
  assign q = c ? a[FW +: PW] : '0;
endinterface
module top(input logic [7:0] a, input logic c, output logic [2:0] q);
  ifc i (.a(a), .c(c));
  assign q = i.q;
endmodule
