// § connBitSelIdxNonOvParamFold431
module child(input a, output b);
assign b = a;
endmodule
module top(input [15:0] x, output [1:0] w);
genvar i;
localparam K = 2;
for (i = 0; i < 2; i++) begin : g
  child c(.a(x[K]), .b(w[i]));
end
endmodule
