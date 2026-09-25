// § firstOrderedConnBitSelWhole147
module top(input [3:0] A, B, output [3:0] S);
add u(A[1:0], B[1], S[0]);
endmodule
module add(input [1:0] A, input B, output S);
assign S = A[0] ^ B;
endmodule
