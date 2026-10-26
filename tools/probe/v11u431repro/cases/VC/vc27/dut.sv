// § connOperandNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module sub(input [7:0] x, output [1:0] w);
localparam P = 3;
for (genvar i = 0; i < 2; i++) begin : g
  wire [7:0] t = x ^ i;
  child c(.a(t + P), .b(w[i]));
end
endmodule
module top(input [7:0] x, output [1:0] w); sub u(.x(x), .w(w)); endmodule
