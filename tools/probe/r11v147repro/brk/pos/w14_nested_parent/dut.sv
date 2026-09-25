// § firstOrderedConnBitSelWhole147
module top(input [3:0] A, B, output [3:0] S);
mid m(A, B, S);
endmodule
module mid(input [3:0] X, Y, output [3:0] Z);
for (genvar i = 0; i < 4; i++) begin : g
  add u(X[i], Y[i], Z[i]);
end
endmodule
module add(input A, B, output S);
assign S = A ^ B;
endmodule
