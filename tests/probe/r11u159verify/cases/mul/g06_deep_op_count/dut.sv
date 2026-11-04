// § gcaUseSiteParamConst147
module top #(parameter M = 4, parameter N = 3)(input [M-1:0] A, output [M+N:0] P);
wire [M+N:0] PP [N-1:0];
assign PP[0] = {{N+1{1'b0}}, A};
genvar i;
for (i=1; i < N; i=i+1) begin: g
  wire [M+i-1:0] gB;
  assign gB = PP[i-1][M+i-1:0];
  assign PP[i] = {{N-i+1{1'b0}}, gB};
end
assign P = PP[N-1];
endmodule
