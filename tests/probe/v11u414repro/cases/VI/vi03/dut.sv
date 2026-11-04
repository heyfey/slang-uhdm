// § ifaceClsScopedArgUnsup414
interface class ic;
  typedef int T;
endclass
class C implements ic;
  function void f(ref ic::T a, output ic::T b);
  endfunction
endclass
module top;
  C c;
endmodule
