// § ifaceClsScopedArgUnsup414
interface class ic;
  typedef logic [3:0] v_t;
  typedef int i_t;
  pure virtual function void f(v_t a);
endclass
class C implements ic;
  virtual function void f(ic::v_t a); endfunction
  function void g(ic::i_t b, input ic::v_t c); endfunction
  task t(ic::i_t d); endtask
endclass
module top;
endmodule
