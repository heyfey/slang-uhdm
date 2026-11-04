// § firstOrderedConnBitSelWhole147
module top(input [3:0] A, B, output [3:0] S);
add u(, B[0], S[0]);
endmodule
module add(input A, B, output S);
assign S = B;
endmodule
