// § firstOrderedConnBitSelWhole147
module top(input [3:0] A, input [1:0][1:0] B, output [1:0] S);
add u[1:0](A[1], B[0], S);
endmodule
module add(input A, input [1:0] B, output S);
assign S = A ^ B[0];
endmodule
