// § hpDotWsTrimmed167
interface bif;
  logic [7:0] wdtxx;
  logic [7:0] rd;
endinterface
module top (input logic [7:0] a, output logic [7:0] y);
  bif bs();
  assign bs	.	wdtxx = a;
  assign y = bs.wdtxx;
endmodule
