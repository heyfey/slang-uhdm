// § ifaceClsScopedArgUnsup414
interface class ic;
  typedef int T;
endclass
module top;
  function void f(ic::T a);
  endfunction
endmodule
