// § modOutOfBodyMethodIsModuleTf420
module tb;
  logic a;
  class c;
    int a;
    extern function void f(int v);
  endclass
  function void c::f(int v);
    a = v;
  endfunction
  c h;
  initial begin h = new; h.f(3); end
endmodule
