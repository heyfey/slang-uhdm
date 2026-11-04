// § strLitContOwnerEnd224
module top(input logic c, output string o, output int k);
  always_comb begin o = c ? "x" : "ab \
cd"; k = 2; end
endmodule
