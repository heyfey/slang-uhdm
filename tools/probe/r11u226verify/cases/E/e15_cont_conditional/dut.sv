// § strLitContLineSpan220 — a continued string literal as a conditional operand and as the right side of a continuous assignment of a string-typed variable
module top(input logic c, output string o1, output string o2);
  initial o1 = c ? "short" : "long \
tail";
  initial o2 = "whole \
continued";
endmodule
