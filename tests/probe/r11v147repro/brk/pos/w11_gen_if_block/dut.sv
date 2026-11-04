// § firstOrderedConnBitSelWhole147
module top(input [3:0] A, B, output [3:0] S);
if (1) begin : gi
  add u(A[2], B[1], S[0]);
end
endmodule
module add(input A, B, output S);
assign S = A ^ B;
endmodule
