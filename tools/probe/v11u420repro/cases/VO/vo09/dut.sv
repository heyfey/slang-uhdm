// § modOutOfBodyMethodIsModuleTf420
module top;
  class C;
    int x;
    extern function new(int a);
  endclass
  function C::new(int a);
    x = a;
  endfunction
endmodule
