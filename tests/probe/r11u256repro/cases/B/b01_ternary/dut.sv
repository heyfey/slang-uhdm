// § elabBodyIpsBoundSelName256 (a ternary branch (Earlgrey flash_phy host_bank_sel))
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
endpackage
module m import fp::*; (input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  assign q = c ? a[FW +: PW] : '0;
  assign o = c ? '0 : {1'b0, b[WW +: PW]};
endmodule
module top(input logic [7:0] a, input logic [7:0] b, input logic c, output logic [3:0] o, output logic [2:0] q);
  m u (.*);
endmodule
