// § paramIdxPartSelWholeSpan131
module top (input logic [31:0] a, output logic [7:0] o);
  assign o = a[8 +: 8];
endmodule
