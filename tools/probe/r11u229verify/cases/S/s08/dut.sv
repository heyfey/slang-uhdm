// § strLitPpEscIdShift224 (an instance port connection, another connection after it on the line)
module m(input string s, output string o); assign o = s; endmodule
module top(output string o);
  m u(.s("a\nb` c"), .o(o));
endmodule
