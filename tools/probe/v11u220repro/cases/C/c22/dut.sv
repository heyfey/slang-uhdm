// § cloneHpIdxNamesByChain220
package p1;
  typedef struct { int a; } s_t;
  class c;
    s_t arr[4];
    extern function int f(logic [7:0] i);
  endclass
  function int c::f(logic [7:0] i);
    return arr[i[1:0]].a + arr[int'(i)].a + arr[i[0]].a;
  endfunction
endpackage
package p2; import p1::*; endpackage
module top(output int o); import p2::*; assign o = 1; endmodule
