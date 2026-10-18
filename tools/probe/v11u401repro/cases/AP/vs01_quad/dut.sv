// § asgOpInnermostParenSpan401
module top;
  int a, b, d;
  initial begin d = ((((a -= 2)))); d = (( (b *= 3) )); end
endmodule
