// § cloneTfVarParentAtTf482 (local with an initializer, two importers)
package u;
  function int f(int n);
    int t = n;
    int w = 2;
    return t + w;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
package b;
  import u::*;
  function int h(); return f(2); endfunction
endpackage
package c;
  import u::*;
  function int k(); return f(3); endfunction
endpackage
module top;
  import a::*;
  import b::*;
  import c::*;
  int x;
  initial x = g() + h() + k();
endmodule
