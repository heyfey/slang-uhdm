// § firstOrderedConnBitSelWhole147
module top(input [3:0] A, B, input c, output [3:0] S);
add u(c, B[1], S[0]);
endmodule
module add(input A, B, output S);
assign S = A ^ B;
endmodule
