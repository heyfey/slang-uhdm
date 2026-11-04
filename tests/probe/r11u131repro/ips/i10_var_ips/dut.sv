// § paramIdxPartSelWholeSpan131
module top();
 parameter A = 68'h200000000000000;
 parameter I = 8;
 parameter B = A[I*4+:4];
endmodule
