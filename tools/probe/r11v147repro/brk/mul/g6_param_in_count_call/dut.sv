// § gcaUseSiteParamConst147
module top #(parameter M = 4, parameter N = 4)(input [M-1:0] A, output [M*N-1:0] P);
genvar i;
for (i=0; i < N; i=i+1) begin: g
  assign P[M*i +: M] = {{($clog2(N)-1){1'b0}}, A[M-$clog2(N):0]};
end
endmodule
