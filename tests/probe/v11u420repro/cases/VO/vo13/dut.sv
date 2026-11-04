// § modOutOfBodyMethodIsModuleTf420
module top;
  class C;
    int x;
    extern function void f();
  endclass
  function void C::f();
    x = 5;
  endfunction
  initial begin
    C o = new;
    o.f();
  end
endmodule
