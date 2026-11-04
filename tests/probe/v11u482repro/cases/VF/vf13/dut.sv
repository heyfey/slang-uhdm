// § cloneFixArrAggElemShared482 (importer chain b imports a which imports u)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[1].data;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(1); endfunction
endpackage
package b;
  import a::*;
  import u::*;
  function int h(); return g() + f(2); endfunction
endpackage
module top;
  import b::*;
  int x;
  initial x = h();
endmodule
