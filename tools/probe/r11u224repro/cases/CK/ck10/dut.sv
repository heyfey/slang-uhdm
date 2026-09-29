// § strLitContOwnerEnd224
module top(input logic c, output string o);
  always_comb if (c) o = "ab \
cd"; else o = "x";
endmodule
