// § firstOrderedConnBitSelWhole147
module top(input [3:0] X, Y, output [3:0] Z);
add u(X[0], Y[0], Z[0]);
endmodule
module add(input A, B, output S);
assign S = A ^ B;
endmodule
