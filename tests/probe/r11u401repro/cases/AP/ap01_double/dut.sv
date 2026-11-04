// § asgOpInnermostParenSpan401
module top();
  int a, b, d;
  initial d = ((b += (a+=1) + 1));
endmodule
