// § firstOrderedConnBitSelWhole147
module top(input [3:0] A, B, input [1:0] k, output [3:0] S);
add u(A[k], B[k], S[0]);
endmodule
module add(input A, B, output S);
assign S = A ^ B;
endmodule
