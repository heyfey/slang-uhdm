// § connOperandNonOvParamFold431
module child(input [7:0] a, output b);
assign b = a[0];
endmodule
module top(input [7:0] x, output [1:0] w);
for (genvar i = 0; i < 2; i++) begin : g
  localparam K = 3;
  child c(.a(x ^ K), .b(w[i]));
end
endmodule
