// § ifaceClsScopedArgUnsup414
class D;
  typedef int T;
endclass
class C;
  function void f(D::T a);
  endfunction
  function D::T g();
    return 0;
  endfunction
endclass
module top;
  C c;
endmodule
