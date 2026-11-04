// § modOutOfBodyMethodIsModuleTf420
module top;
  class C;
    int x;
    extern function void f();
  endclass
  function void C::f();
    int t = 4;
    $display("%0d", x + t);
  endfunction
endmodule
