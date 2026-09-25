// § gcaUseSiteParamConst147 § genLpOperandTsNoParent152
module top #(parameter N = 4)(input [3:0] A, output [7:0] P);
parameter int Q [2] = '{1, 2};
wire [7:0] PP [3:0][1:0];
genvar i, j;
for (i=1; i < 3; i=i+1) begin: g
  for (j=0; j < 2; j=j+1) begin: h
    localparam int L = Q[1];
    assign PP[i][j] = {{(N-L){1'b0}}, A};
  end
end
assign P = PP[2][1];
endmodule
