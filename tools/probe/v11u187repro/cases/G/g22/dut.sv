// § cloneLoopVarHomeObject183 (a class method iterating a formal, the class imported by a second package)
package u;
  class c;
    function int tot(int a[]);
      int n;
      foreach (a[i]) n = n + a[i];
      return n;
    endfunction
  endclass
endpackage
package s;
  import u::*;
  class d extends c; endclass
endpackage
module top; endmodule
