// § oobInheritedCallBindsOwnPkgClone455
// a void call statement and a call in a loop body of an OOB method
package p;
  function int f(int a); $display(a); return a; endfunction
  function void w(int a); $display(a); endfunction
endpackage
package q;
  import p::*;
  class C;
    int v[4];
    extern function void g();
  endclass
  function void C::g();
    void'(f(1));
    foreach (v[i]) w(v[i]);
    for (int j = 0; j < 2; j++) v[j] = f(j);
  endfunction
endpackage
module top;
  import q::*;
  C c;
  initial begin c = new; c.g(); end
endmodule
