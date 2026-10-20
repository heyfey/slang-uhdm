// § modOutOfBodyMethodIsModuleTf420
module top;
  int x;
  class C;
    int x;
    extern function void f();
  endclass
  function void C::f();
    x = 3;
  endfunction
endmodule
