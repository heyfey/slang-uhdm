// § hpDotWsTrimmed167 — a blank after the dot only, on a continuous-assignment target
interface bif;
  logic [7:0] wdtxx;
endinterface
module top (input logic [7:0] a, output logic [7:0] y);
  bif bs();
  assign bs. wdtxx = a;
  assign y = bs.wdtxx;
endmodule
