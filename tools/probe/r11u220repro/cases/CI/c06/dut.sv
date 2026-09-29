// § cloneHpIdxNamesByChain220
package p1;
  typedef struct { int a; int b; } s_t;
  class c;
    s_t arr[4];
    function int f(int i);
      return arr[i].a;
    endfunction
  endclass
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
