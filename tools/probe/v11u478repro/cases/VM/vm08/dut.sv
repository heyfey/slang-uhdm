// § cloneHierArrElemMember478 (a struct array inside a struct array)
package u;
  typedef struct { int k; int data; } in_t;
  typedef struct { in_t b[2]; int z; } op_t;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    op_t acc[2];
    int r;
    r = acc[0].b[1].data;
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
