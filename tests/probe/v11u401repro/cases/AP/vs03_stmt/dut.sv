// § asgOpInnermostParenSpan401
module top;
  int i, s;
  initial s = ((s ^= i));
  always @(s) i = ((i));
endmodule
