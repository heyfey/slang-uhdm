// § paramIdxPartSelWholeSpan131
module top(output logic [3:0] o);
 parameter bit [15:0] D = 16'h1234;
 assign o = D[1*4+:4];
endmodule
