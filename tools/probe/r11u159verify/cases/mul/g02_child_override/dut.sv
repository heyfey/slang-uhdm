// § gcaUseSiteParamConst147
module sub #(parameter N = 4)(input [3:0] A, output [7:0] P);
wire [7:0] PP [3:0];
genvar i;
for (i=1; i < 3; i=i+1) begin: g
  assign PP[i] = {{(N*2-i){1'b0}}, A};
end
assign P = PP[2];
endmodule
module top(input [3:0] A, output [7:0] P);
  sub #(.N(3)) u (.A(A), .P(P));
endmodule
