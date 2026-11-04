// § cloneFixArrAggElemShared482 (module imports u directly and package a clones)
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
module top;
  import u::*;
  import a::*;
  int x;
  initial x = g() + f(5);
endmodule
