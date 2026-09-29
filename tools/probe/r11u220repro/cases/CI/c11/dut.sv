// § cloneHpIdxNamesByChain220
package p1;
  typedef struct { int a; int b; } s_t;
  class c;
    s_t arr[4];
    extern function int f(int i);
  endclass
  function int c::f(int i);
    int s = 0;
    for (int j = 0; j < i; j++) s += arr[j].a + arr[i-j].b;
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
