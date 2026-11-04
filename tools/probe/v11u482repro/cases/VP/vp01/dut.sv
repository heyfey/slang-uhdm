// § cloneTfVarParentAtTf482 (named block local and function locals)
package u;
  function int f(int n);
    int t;
    begin : blk
      int q;
      q = n;
      t = q;
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
