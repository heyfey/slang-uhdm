// § modOutOfBodyMethodIsModuleTf420
module m;
  class C;
    int x;
    extern function void f();
  endclass
  function void C::f();
    x = 1;
  endfunction
endmodule
module top;
  if (1) begin : g
    m a();
  end
endmodule
