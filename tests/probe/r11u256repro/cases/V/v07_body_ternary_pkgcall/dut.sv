// § elabBodyIpsBoundSelName256 (a module-body ternary with a select of a package function result width)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
endpackage
module m import fp::*; (input logic [7:0] a, input logic c, output logic [2:0] q, output logic [2:0] r);
  assign q = c ? a[FW +: PW] : a[0 +: PW];
  assign r = (c && a[0]) ? {a[FW +: 2], 1'b0} : 3'b0;
endmodule
module top(input logic [7:0] a, input logic c, output logic [2:0] q, output logic [2:0] r); m u (.*); endmodule
