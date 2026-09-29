// § cloneHpIdxNamesByChain220
package p1;
  typedef struct { int a; } s_t;
  class c;
    s_t arr[$];
    extern function int f();
  endclass
  function int c::f();
    return arr[arr.size()-1].a;
  endfunction
endpackage
package p2; import p1::*; endpackage
module top(output int o); import p2::*; assign o = 1; endmodule
