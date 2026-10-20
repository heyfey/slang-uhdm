// § ifaceClsScopedArgUnsup414
interface class ic;
  typedef struct { int a; } s_t;
endclass
class C implements ic;
  function void f(ic::s_t a);
  endfunction
endclass
module top;
  C c;
endmodule
