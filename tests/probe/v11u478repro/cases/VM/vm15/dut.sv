// § cloneHierArrElemMember478 (a free function, direct and provider importers)
package u;
  typedef struct { int k; bit [63:0] data; } op_t;
  function automatic int f(int n);
    op_t acc[$];
    int r;
    acc.push_back('{1, 2});
    r = acc[0].data;
    return r;
  endfunction
endpackage
package a;
  import u::*;
  class A; function int g(); return f(1); endfunction endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
package d;
  import u::*;
  class D; function int g(); return f(2); endfunction endclass
endpackage
module top; import t::*; import d::*; T o; D q; endmodule
