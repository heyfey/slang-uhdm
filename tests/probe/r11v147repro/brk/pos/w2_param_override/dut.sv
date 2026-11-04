// § firstOrderedConnBitSelWhole147
module top(input [3:0] A, B, output [3:0] S);
add #(1) u(A[1], B[2], S[3]);
endmodule
module add #(parameter P = 0)(input A, B, output S);
assign S = A ^ B ^ P[0];
endmodule
