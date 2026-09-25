// § hpDotWsTrimmed167
interface bif;
  logic [7:0] wdtxx;
  logic [7:0] rd;
endinterface
module sub (input logic [7:0] a);
  bif bs();
  assign bs.wdtxx = a;
endmodule
module top (input logic [7:0] a, output logic [7:0] y);
  sub u (.a(a));
  assign y = u . bs . wdtxx;
endmodule
