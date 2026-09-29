// § strLitPpEscIdShift224
module top(output string o);
  function automatic string f(string s = "a\nb` c"); return s; endfunction
  initial o = f();
endmodule
