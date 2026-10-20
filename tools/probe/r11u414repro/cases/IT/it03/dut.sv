// § ifaceClsScopedArgUnsup414
interface class ic;
  typedef int i_t;
endclass
class C;
  ic::i_t p;
  function ic::i_t g(); return 0; endfunction
endclass
module top;
  function void h(ic::i_t x); endfunction
endmodule
