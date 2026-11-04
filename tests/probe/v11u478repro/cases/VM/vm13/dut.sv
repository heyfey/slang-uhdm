// § cloneHierArrElemMember478 (a write and a foreach)
package u;
  typedef struct { int k; bit [63:0] data; } op_t;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    op_t acc[2];
    int r;
    acc[0].data = 5; foreach (acc[i]) r += acc[i].k;
    return r;
  endfunction
endpackage
package a;
  import u::*;
  class A; C c; endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
module top;
  import a::*; import t::*;
  A o; T p;
endmodule
