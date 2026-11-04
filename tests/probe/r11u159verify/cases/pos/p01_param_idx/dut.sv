// § firstOrderedConnBitSelWhole147
module top #(parameter K = 1)(input [3:0] A, B, output [3:0] S);
add u(A[K], B[K], S[K]);
endmodule
module add(input A, B, output S);
assign S = A ^ B;
endmodule
