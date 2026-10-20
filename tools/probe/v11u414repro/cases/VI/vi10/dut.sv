// § ifaceClsScopedArgUnsup414
interface class ic;
  typedef int T;
endclass
class C implements ic;
  function ic::T g();
    return 0;
  endfunction
  task t(input int i, ic::T a);
  endtask
endclass
module top;
  C c;
endmodule
