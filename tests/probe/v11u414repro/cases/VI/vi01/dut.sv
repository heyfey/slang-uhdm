// § ifaceClsScopedArgUnsup414
interface class ic;
  typedef int T;
endclass
class C implements ic;
  task t(ic::T a);
  endtask
endclass
module top;
  C c;
endmodule
