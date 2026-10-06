// § elabBodyIpsBoundSelName256 (the select in the top module's own body (no instance above))
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
endpackage
module top import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  assign q = c ? a[FW +: PW] : '0;
  assign o = {c, b[WW +: PW]};
endmodule
