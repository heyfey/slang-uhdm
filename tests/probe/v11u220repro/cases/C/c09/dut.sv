// § cloneHpIdxNamesByChain220
package p1;
  typedef struct { int a; int b; } s_t;
  class c;
    s_t arr[4];
    extern function int f();
  endclass
  function int c::f();
    automatic int k = 1;
    return arr[k].b;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
