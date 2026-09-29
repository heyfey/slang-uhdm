// § cloneHpIdxNamesByChain220
package p1;
  typedef struct { int a; } s_t;
  class c;
    s_t m[string];
    extern function int f(string key);
  endclass
  function int c::f(string key);
    return m[key].a;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
