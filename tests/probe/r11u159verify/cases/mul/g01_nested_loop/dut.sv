// § gcaUseSiteParamConst147
module top #(parameter N = 3)(input [3:0] A, output [7:0] P);
wire [7:0] PP [3:0][1:0];
genvar i, j;
for (i=1; i < 3; i=i+1) begin: g
  for (j=0; j < 2; j=j+1) begin: h
    assign PP[i][j] = {{(N-i){1'b0}}, A};
  end
end
assign P = PP[2][1];
endmodule
