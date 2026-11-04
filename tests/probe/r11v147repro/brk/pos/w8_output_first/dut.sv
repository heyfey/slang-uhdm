// § firstOrderedConnBitSelWhole147
module top(input [3:0] A, B, output [3:0] S);
add u(S[2], A[0], B[0]);
endmodule
module add(output S, input A, B);
assign S = A ^ B;
endmodule
