module top;
  class base;
    extern function int f(int a, string s = "q");
  endclass
  function int base::f(int a, string s = "q");
    return a;
  endfunction
  base b;
  initial begin b = new; void'(b.f(1)); end
endmodule
