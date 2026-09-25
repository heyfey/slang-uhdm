// § firstOrderedConnBitSelWhole147 (control: named connections keep the index span)
module top(input [3:0] A, B, output [3:0] S);
genvar i;
for (i=0; i < 4; i=i+1) begin: g
  add u(.A(A[i]), .B(B[i]), .S(S[i]));
end
endmodule
module add(input A, B, output S);
assign S = A ^ B;
endmodule
