// § gcaUseSiteParamConst147
module top #(parameter M = 2, parameter N = 3)(input [M-1:0] A, output logic [M+N-1:0] P [N-1:0]);
genvar i;
for (i=0; i < N; i=i+1) begin: g
  always_comb P[i] = {{(N-i){1'b0}}, A, {i{1'b0}}};
end
endmodule
