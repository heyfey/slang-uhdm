// § cloneOwnCopyInstHomeTop482 (scalar union local, two importers)
package u;
  typedef union { int i; bit [31:0] b; } op_t;
  function int f(int n);
    op_t s;
    s.i = n;
    return s.i;
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
