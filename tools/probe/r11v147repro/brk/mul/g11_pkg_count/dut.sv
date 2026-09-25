// § gcaUseSiteParamConst147
package pk;
  localparam int N = 3;
endpackage
module top #(parameter M = 2)(input [M-1:0] A, output [M+pk::N-1:0] P [pk::N-1:0]);
genvar i;
for (i=0; i < pk::N; i=i+1) begin: g
  assign P[i] = {{(pk::N-i){1'b0}}, A, {i{1'b0}}};
end
endmodule
