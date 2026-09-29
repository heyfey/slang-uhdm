// § strLitPpEscIdShift224
module top(input logic c, output string o);
  always_comb o = c ? "a\nb` c" : "d";
endmodule
