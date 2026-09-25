// § firstOrderedConnBitSelWhole147
`define SEL(x) x[0]
module top(input [3:0] A, B, output [3:0] S);
add u(`SEL(A), B[0], S[0]);
endmodule
module add(input A, B, output S);
assign S = A ^ B;
endmodule
