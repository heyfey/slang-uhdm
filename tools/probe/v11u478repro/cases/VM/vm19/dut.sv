// § cloneHierArrElemMember478 (a class property queue read by an out-of-body method)
package u;
  typedef struct { int k; bit [63:0] data; } op_t;
  class C;
    op_t acc[$];
    extern function int f(int n);
  endclass
  function int C::f(int n);
    int r;
    r = acc[0].data;
    return r;
  endfunction
endpackage
package a;
  import u::*;
  class A; C c; endclass
endpackage
module top;
  import a::*;
  A o;
endmodule
