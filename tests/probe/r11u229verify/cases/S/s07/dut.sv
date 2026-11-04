// § strLitPpEscIdShift224 (a named argument list, the literal first)
module top(output string o);
  function automatic string f(string s, int k); return s; endfunction
  initial o = f(.s("a\nb` c"), .k(1));
endmodule
