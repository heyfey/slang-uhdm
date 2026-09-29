// § strLitContOwnerEnd224
module top(input logic c, input logic d, output string o);
  always_comb o = c ? (d ? "x" : "ab \
cd") : "y";
endmodule
