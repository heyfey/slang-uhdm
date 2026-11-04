// § strLitContOwnerEnd224
module top(input logic c, output string o);
  always_comb o = c ? "x" : "ab \
cd \
ef";
endmodule
