// § modOutOfBodyMethodIsModuleTf420
module tb;
  class c;
    int a;
    extern function void f(int v);
  endclass
  function void c::f(int v);
    $display(v);
  endfunction
  c h;
  initial begin h = new; h.f(3); end
endmodule
