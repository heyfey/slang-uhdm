// § cloneHpIdxNamesByChain220
package p1;
  typedef struct { int a; } s_t;
  class c;
    s_t arr[4];
    function int g(int x); return x; endfunction
    extern function int f(int i, int k);
  endclass
  function int c::f(int i, int k);
    return arr[g(i+k)].a + arr[g(arr[i].a)].a;
  endfunction
endpackage
package p2; import p1::*; endpackage
module top(output int o); import p2::*; assign o = 1; endmodule
