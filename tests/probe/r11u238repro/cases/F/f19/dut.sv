// § foreachFlatLocalRefTs238
interface ifc;
  function automatic int f;
    string vs[$];
    foreach (vs[i]) f++;
  endfunction
endinterface
package p;
  function automatic int g;
    int d[$];
    foreach (d[i]) g += d[i];
  endfunction
endpackage
package q;
  import p::*;
  function int h(); return g(); endfunction
endpackage
module top;
  ifc u();
  int r;
  initial r = u.f() + q::h();
endmodule
