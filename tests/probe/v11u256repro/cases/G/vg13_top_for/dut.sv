// § genIpsBoundOwner256 (a for-generate in the top module itself)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
  parameter int WW = 1;
  parameter int LB = 1;
endpackage
module top import fp::*; (input logic [7:0] a, output logic [2:0] q, output logic [2:0] r);
  logic [2:0] t [2];
  for (genvar i = 0; i < 2; i++) begin : gb
    assign t[i] = a[FW +: PW] | a[0 +: PW];
  end
  assign q = t[0]; assign r = t[1];
endmodule
