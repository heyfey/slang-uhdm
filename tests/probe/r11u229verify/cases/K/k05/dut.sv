// § strLitContOwnerEnd224 § strLitPpEscIdShift224 (a literal holding both a backtick and a line continuation)
module top(input logic c, output string o);
  always_comb o = c ? "x" : "a\nb` \
cd";
endmodule
