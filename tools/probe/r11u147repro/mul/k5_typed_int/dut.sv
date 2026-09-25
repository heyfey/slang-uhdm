// § gcaUseSiteParamConst147
module top #(parameter int N = 4)(input [3:0] A, output [7:0] P);
wire [7:0] PP [3:0];
genvar i;
for (i=1; i < 4; i=i+1) begin: g
  assign PP[i] = {{(N-i){1'b0}}, A};
end
assign P = PP[3];
endmodule
