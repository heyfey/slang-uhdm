// § modOutOfBodyMethodIsModuleTf420
module top;
  class C;
    int x;
    extern function void f();
  endclass
  function void C::f();
    this.x = 5;
  endfunction
endmodule
