// § asgOpInnermostParenSpan401
module top;
  int a, b;
  initial begin if (((a += 1))) b = 1; b = ((a <<= 1)) + ((a |= 2)); end
endmodule
