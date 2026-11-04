// § hpDotWsTrimmed167
interface bif;
  logic [7:0] wdtxx;
  logic [7:0] rd;
endinterface
module top (input logic clk, input logic [7:0] a, output logic [7:0] y);
  bif bs();
  always_ff @(posedge clk) bs . wdtxx <= a;
  always_comb y = bs . wdtxx;
endmodule
