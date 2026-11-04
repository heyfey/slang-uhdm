// § cloneLoopVarHomeObject183 (class method over a string-keyed property, imported)
package u;
  class c;
    int m[string];
    function int sum();
      int n;
      foreach (m[k]) n = n + m[k];
      return n;
    endfunction
  endclass
endpackage
package s;
  import u::*;
  class d extends c; endclass
endpackage
module top; endmodule
