// § ifaceClsScopedArgUnsup414
interface class ic;
  typedef int T;
endclass
class C implements ic;
  function void f(input ic::T a, ic::T b);
  endfunction
endclass
module top;
  C c;
endmodule
