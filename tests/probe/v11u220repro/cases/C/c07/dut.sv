// § cloneHpIdxNamesByChain220
package p1;
  typedef struct { int a; } s_t;
  class c;
    s_t arr[4];
    extern function int f(int i);
  endclass
  function int c::f(int i);
    return arr[i].a + arr[i+1].a;
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
package p3;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  import p3::*;
  assign o = 1;
endmodule
