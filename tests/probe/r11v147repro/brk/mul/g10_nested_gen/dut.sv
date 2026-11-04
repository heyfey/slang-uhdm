// § gcaUseSiteParamConst147
module top #(parameter M = 2, parameter N = 2)(input [M-1:0] A, output [M+N-1:0] P [N-1:0][N-1:0]);
genvar i, j;
for (i=0; i < N; i=i+1) begin: g
  for (j=0; j < N; j=j+1) begin: h
    assign P[i][j] = {{(N-j){1'b0}}, A, {j{1'b0}}};
  end
end
endmodule
