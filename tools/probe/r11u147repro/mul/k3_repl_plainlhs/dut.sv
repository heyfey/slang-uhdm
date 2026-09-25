// § gcaUseSiteParamConst147
module top #(parameter N = 4)(input [3:0] A, output [7:0] P);
genvar i;
for (i=1; i < 2; i=i+1) begin: g
  wire [6:0] x;
  assign x = {{(N-i){1'b0}}, A};
end
assign P = '0;
endmodule
