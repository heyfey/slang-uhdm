// § cloneHpIdxNamesByChain220
package p1;
  typedef struct { int a; } s_t;
  class c;
    s_t arr[4];
    extern function int f();
  endclass
  function int c::f();
    int s = 0;
    foreach (arr[i]) s += arr[i].a;
    return s;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
