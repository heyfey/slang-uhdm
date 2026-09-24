// § paramIdxPartSelWholeSpan131
module top();
 parameter bit [15:0] D = 16'h1234;
 logic [D[1*4+:4]:0] q;
endmodule
