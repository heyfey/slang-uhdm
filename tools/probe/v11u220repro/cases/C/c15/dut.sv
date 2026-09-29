// § cloneHpIdxNamesByChain220
package p1;
  typedef struct { int a; } s_t;
  virtual class base;
    pure virtual function int f(int i);
  endclass
  class c extends base;
    s_t arr[4];
    extern virtual function int f(int i);
  endclass
  function int c::f(int i);
    return arr[i].a;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
