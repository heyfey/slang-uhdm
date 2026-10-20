// § ifaceClsScopedArgUnsup414
interface class ic;
  typedef int T;
endclass
module top;
  function ic::T g();
    return 0;
  endfunction
endmodule
