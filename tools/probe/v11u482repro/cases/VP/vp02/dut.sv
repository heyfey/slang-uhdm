// § cloneTfVarParentAtTf482 (for loop variable and a local)
package u;
  function int f(int n);
    int s;
    s = 0;
    for (int i = 0; i < n; i++) s += i;
    return s;
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
