// § cloneHierArrElemMember478
package u;
  typedef struct { int k; bit [63:0] data; } op_t;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    op_t acc[$];
    int r; byte p[$];
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
