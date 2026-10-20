// § modOutOfBodyMethodIsModuleTf420
module top;
  class C;
    int x;
    extern function void f();
    extern function void g();
  endclass
  function void C::f();
    x = 1;
  endfunction
  function void C::g();
    x = 2;
  endfunction
endmodule
