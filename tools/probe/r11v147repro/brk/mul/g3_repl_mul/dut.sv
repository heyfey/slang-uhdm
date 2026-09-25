// § gcaUseSiteParamConst147
module top #(parameter M = 2, parameter N = 3)(input [M-1:0] A, output [2*M*N-1:0] P);
genvar i;
for (i=0; i < N; i=i+1) begin: g
  assign P[2*M*i +: 2*M] = {{(M*2-M){1'b0}}, A};
end
endmodule
