// § connOperandNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module top(input [7:0] x, output [1:0] w);
localparam XF = 4;
for (genvar i = 0; i < 2; i++) begin : g
  child c(.a(x ^ XF ^ i), .b(w[i]));
end
endmodule
