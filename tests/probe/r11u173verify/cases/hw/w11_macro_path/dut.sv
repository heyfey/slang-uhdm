// § hpDotWsTrimmed167 — the blank-carrying dotted path produced by a macro expansion
`define BSW bs . wdtxx
interface bif;
  logic [7:0] wdtxx;
endinterface
module top (input logic [7:0] a, output logic [7:0] y);
  bif bs();
  assign `BSW = a;
  assign y = bs.wdtxx;
endmodule
