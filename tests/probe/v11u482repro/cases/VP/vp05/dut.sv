// § cloneTfVarParentAtTf482 (class method in the home package called by the clone)
package u;
  class C;
    function int m(int n);
      int r;
      r = n;
      return r;
    endfunction
  endclass
  function int f(int n);
    int z;
    C c = new;
    z = c.m(n);
    return z;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
