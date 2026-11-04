// § cloneArrElemAggOwnCopy482 (queue of a struct, three importers)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[$];
    acc.push_back('{k: n, data: 1});
    return acc[0].data;
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
