// § formalRegNoHeap223v § tfArgScalarTdWriter223 — formals recorded across packages, classes, a module and an interface, read back in emission order from the static registry
package p;
  typedef int T1;
  typedef byte T2;
  typedef bit [5:0] T3;
  class a;
    function void f(T1 x, T2 y, T3 z);
    endfunction
    task t(T3 u, T1 v);
    endtask
  endclass
  function automatic int g(T2 w);
    return w;
  endfunction
endpackage
package q;
  import p::*;
  class b extends a;
    function void h(T1 x2, T3 z2);
    endfunction
  endclass
endpackage
interface ifc;
  import p::*;
  function automatic T1 k(T1 i1);
    return i1;
  endfunction
endinterface
module top(input int a0, output int o);
  import p::*;
  import q::*;
  ifc i();
  function automatic int m(T2 m1, T3 m2);
    return m1 + m2;
  endfunction
  assign o = m(a0, a0) + g(a0);
endmodule
