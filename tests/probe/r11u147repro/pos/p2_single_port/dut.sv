// § firstOrderedConnBitSelWhole147 (control: a single ordered connection keeps the index span)
module top(input [3:0] A, output [3:0] S);
  buf1 u(A[1]);
  assign S = '0;
endmodule
module buf1(input X);
endmodule
