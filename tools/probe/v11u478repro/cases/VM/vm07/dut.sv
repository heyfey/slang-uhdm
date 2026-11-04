// § cloneHierArrElemMember478 (a package-level array)
package u;
  typedef struct { int k; bit [63:0] data; } op_t;
  op_t g_acc[4];
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);

    int r;
    r = g_acc[1].data;
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
