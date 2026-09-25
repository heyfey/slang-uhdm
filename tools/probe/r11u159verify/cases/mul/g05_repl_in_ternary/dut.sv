// § gcaUseSiteParamConst147
module top #(parameter N = 4)(input [3:0] A, output [7:0] P);
wire [7:0] PP [3:0];
assign PP[0] = {4'b0, A};
genvar i;
for (i=1; i < 4; i=i+1) begin: g
  assign PP[i] = (i > 1) ? {{(N-i){1'b0}}, A, {(i){1'b1}}} : PP[i-1];
end
assign P = PP[3];
endmodule
