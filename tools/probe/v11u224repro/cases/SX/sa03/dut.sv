// § strLitPpEscIdShift224
module top(output string o, output int k);
  function automatic string f(string s); return s; endfunction
  initial begin
    o = f("a\nb` c"); k = 1;
  end
endmodule
