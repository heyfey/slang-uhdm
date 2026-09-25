// § firstOrderedConnBitSelWhole147
module top(input [1:0][3:0] A, input [3:0] B, output [3:0] S);
add u(A[1][2], B[1], S[0]);
endmodule
module add(input A, B, output S);
assign S = A ^ B;
endmodule
