// § ifaceClsScopedArgUnsup414
interface class ic;
  typedef int T;
endclass
class C implements ic;
  extern function void f(ic::T a);
endclass
function void C::f(ic::T a);
endfunction
module top;
  C c;
endmodule
