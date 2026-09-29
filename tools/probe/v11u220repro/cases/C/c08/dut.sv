// § cloneHpIdxNamesByChain220
package p1;
  typedef struct { int a; } s_t;
  class c;
    s_t arr[4];
    extern function int f(int i);
  endclass
  function int c::f(int i);
    return arr[i].a;
  endfunction
endpackage
module top(output int o);
  import p1::*;
  c h;
  initial begin h = new; o = h.f(1); end
endmodule
