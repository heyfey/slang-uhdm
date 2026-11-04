// § firstOrderedConnBitSelWhole147
module top(input [3:0] A, B, output [3:0] S);
for (genvar i = 0; i < 2; i++) begin : g
  add u(A[i], B[i], S[i]);
end
assign S[3:2] = '0;
endmodule
module add(input A, B, output S);
assign S = A ^ B;
endmodule
