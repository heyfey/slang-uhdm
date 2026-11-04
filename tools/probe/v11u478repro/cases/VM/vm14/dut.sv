// § cloneHierArrElemMember478 (a struct typedef of a class read through a package alias)
package u;
  class K; typedef struct { int k; int data; } op_t; endclass
  typedef K::op_t op2_t;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    op2_t acc[2];
    int r;
    r = acc[1].data;
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
