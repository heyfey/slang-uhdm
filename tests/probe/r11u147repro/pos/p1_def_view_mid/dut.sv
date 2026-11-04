// § firstOrderedConnBitSelWhole147
module top(input [3:0] A, B, output [3:0] S);
  mid m(A, B, S);
endmodule
module mid(input [3:0] A, B, output [3:0] S);
  add u(A[0], B[0], S[0]);
endmodule
module add(input A, B, output S);
  assign S = A ^ B;
endmodule
