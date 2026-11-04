// § gcaUseSiteParamConst147
module top #(parameter M = 4)(input [7:0] A, output [7:0] P);
genvar i;
for (i=1; i < 3; i=i+1) begin: g
  wire [M+i-1:0] y;
  assign y = A[M+i-1:0];
end
assign P = '0;
endmodule
