// § paramIdxPartSelWholeSpan131
module top();
 parameter bit [15:0] D = 16'h1234;
 parameter bit [7:0] E = {D[0+:4], D[4+:4]};
endmodule
