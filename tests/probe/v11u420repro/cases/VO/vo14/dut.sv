// § modOutOfBodyMethodIsModuleTf420
module top;
  localparam int K = 3;
  class C;
    int x;
    extern function void f();
  endclass
  function void C::f();
    x = K;
  endfunction
endmodule
