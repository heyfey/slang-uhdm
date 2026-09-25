// § firstOrderedConnBitSelWhole147
module top(input [3:0] A, B, output [3:0] S);
add u0(A[0], B[0], S[0]), u1(A[1], B[1], S[1]);
endmodule
module add(input A, B, output S);
assign S = A ^ B;
endmodule
