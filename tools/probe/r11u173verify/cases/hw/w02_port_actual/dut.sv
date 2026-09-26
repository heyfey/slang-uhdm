// § hpDotWsTrimmed167 — blanks around the dot inside a port-connection actual
interface bif;
  logic [7:0] wdtxx;
endinterface
module leaf (input logic [7:0] i, output logic [7:0] o);
  assign o = ~i;
endmodule
module top (input logic [7:0] a, output logic [7:0] y);
  bif bs();
  assign bs.wdtxx = a;
  leaf u (.i(bs . wdtxx), .o(y));
endmodule
