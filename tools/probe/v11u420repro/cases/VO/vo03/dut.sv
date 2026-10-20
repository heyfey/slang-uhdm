// § modOutOfBodyMethodIsModuleTf420
module top;
  logic q;
  class C;
    int x;
    extern function void f();
  endclass
  function void C::f();
    x = q;
  endfunction
endmodule
