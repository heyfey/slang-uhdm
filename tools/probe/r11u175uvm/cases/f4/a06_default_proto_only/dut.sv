package p1;
  class base;
    extern function int f(int a, int b = 5);
  endclass
  function int base::f(int a, int b);
    return a + b;
  endfunction
endpackage
module top;
  import p1::*;
  base b;
  initial begin b = new; void'(b.f(1)); end
endmodule
