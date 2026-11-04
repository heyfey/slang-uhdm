// § cloneTfVarParentAtTf482 (local declared after statements in an unnamed begin)
package u;
  function int f(int n);
    int t;
    t = n;
    begin
      int q;
      q = t;
      t = q + 1;
    end
    return t;
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
