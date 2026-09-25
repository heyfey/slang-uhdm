// § firstOrderedConnBitSelWhole147
module top(input [3:0] \a.b , input [3:0] B, output [3:0] S);
add u(\a.b [1], B[1], S[1]);
endmodule
module add(input A, B, output S);
assign S = A ^ B;
endmodule
