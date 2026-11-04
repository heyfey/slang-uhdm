// § cloneHierArrElemMember478 (the struct imported from another package)
package s;
  typedef struct { int k; bit [63:0] data; } op_t;
endpackage
package u;
  import s::*;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    op_t acc[2];
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
