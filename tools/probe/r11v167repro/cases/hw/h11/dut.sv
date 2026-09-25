// § hpDotWsTrimmed167
interface bif;
  logic [7:0] wdtxx;
endinterface
module top (input logic [7:0] a, output logic [7:0] y);
  bif \bs.x ();
  assign \bs.x .wdtxx = a;
  assign y = \bs.x . wdtxx;
endmodule
