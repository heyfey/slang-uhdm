// § cloneHierArrElemMember478 (a member named size)
package u;
  typedef struct { int k; int size; } op_t;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    op_t acc[$];
    int r;
    r = acc[0].size;
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
