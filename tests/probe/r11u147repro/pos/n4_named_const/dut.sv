// § firstOrderedConnBitSelWhole147
module top(input [3:0] A, B, output [3:0] S);
add u(.A(A[0]), .B(B[0]), .S(S[0]));
endmodule
module add(input A, B, output S);
assign S = A ^ B;
endmodule
