// § gcaUseSiteParamConst147
module top #(parameter M = 2, parameter N = 3)(input [M-1:0] A, output logic [M+N-1:0] P);
always_comb P = {{(N-1){1'b0}}, 1'b0, A};
endmodule
