// § firstOrderedConnBitSelWhole147
module top(input [4:0] A, B, output [3:0] S);
for (genvar i = 0; i < 4; i++) begin : g
  add u(A[i+1], B[i], S[i]);
end
endmodule
module add(input A, B, output S);
assign S = A ^ B;
endmodule
