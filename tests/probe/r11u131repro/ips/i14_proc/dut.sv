// § paramIdxPartSelWholeSpan131
module top(input logic [15:0] d, output logic [3:0] o);
 always_comb o = d[1*4+:4];
endmodule
