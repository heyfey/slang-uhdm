// § hpDotWsTrimmed167
interface bif;
  logic [7:0] wdtxx;
  logic [7:0] rd;
endinterface
module top (input logic [7:0] a, output logic [7:0] y);
  bif bs [2] ();
  assign bs[0] . wdtxx = a;
  assign bs[1] . wdtxx = ~a;
  assign y = bs[1] . wdtxx;
endmodule
