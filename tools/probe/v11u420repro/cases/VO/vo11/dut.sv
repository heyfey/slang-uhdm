// § modOutOfBodyMethodIsModuleTf420
module top;
  class C;
    int x;
    extern function void f(int a = 2);
  endclass
  function void C::f(int a = 2);
    int x;
    x = a;
  endfunction
endmodule
