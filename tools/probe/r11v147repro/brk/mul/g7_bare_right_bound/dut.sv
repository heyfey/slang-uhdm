// § gcaBareBoundKeepsInst147v
module top #(parameter M = 4, parameter N = 3)(input [M:0] A, output [M-1:0] P [N-1:0]);
wire [M:0] PP [N-1:0];
assign PP[0] = A;
genvar i;
for (i=1; i < N; i=i+1) begin: g
  assign PP[i] = PP[i-1];
  assign P[i] = PP[i][M:1];
end
assign P[0] = PP[0][M-1:0];
endmodule
