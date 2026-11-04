// § cloneHierArrElemMember478 (a provider package: t reaches u only through a)
package u;
  typedef struct { int k; bit [63:0] data; } op_t;
  function automatic void f(int n);
    op_t acc[$];
    byte p[$];
    foreach (acc[i0])
      for (int i1 = 0; i1 < n; i1++)
        p.push_back(acc[i0].data[i1*8+:8]);
  endfunction
endpackage
package a;
  import u::*;
  class A;
    function void g(); f(1); endfunction
  endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
module top;
  import t::*;
  T o;
endmodule
