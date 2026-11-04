// § ifaceClsScopedArgUnsup414
package p;
  interface class ic;
    typedef bit [3:0] T;
  endclass
  class C implements ic;
    function ic::T g(ic::T a);
      return a;
    endfunction
  endclass
endpackage
module top;
endmodule
