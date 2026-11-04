// § cloneHierIdxChainActual482 (acc[0][1].data, three importers)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[2][3];
    acc[0][1].k = n;
    return acc[1][2].data;
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
