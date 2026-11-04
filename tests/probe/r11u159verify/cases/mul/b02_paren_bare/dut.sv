// § gcaBareBoundKeepsInst147v
module top #(parameter M = 4)(input [M-1:0] A, output [M:0] P);
wire [M:0] PP [2:0];
assign PP[0] = {1'b0, A};
genvar i;
for (i=1; i < 3; i=i+1) begin: g
  wire [M:0] gB;
  assign gB = PP[i-1][(M):0];
  assign PP[i] = gB;
end
assign P = PP[2];
endmodule
