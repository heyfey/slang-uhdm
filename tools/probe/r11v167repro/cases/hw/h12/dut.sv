// § hpDotWsTrimmed167
interface bif;
  logic [7:0] wdtxx;
endinterface
module top #(parameter int I = 1) (input logic [7:0] a, output logic [7:0] y);
  bif bs [2] ();
  assign bs[I - 1] . wdtxx = a;
  assign bs[I] . wdtxx = a;
  assign y = bs[ I ] . wdtxx;
endmodule
