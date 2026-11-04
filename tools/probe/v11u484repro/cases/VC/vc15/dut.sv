// § cloneAliasCopyBareName484 (two aliases of one struct in one clone)
package u;
  typedef struct { int k; int data; } op_t;
  typedef op_t opa_t;
  typedef op_t opb_t;
  function int f(int n);
    opa_t x;
    opb_t y[2];
    x.k = n;
    y[0] = x;
    return y[0].k;
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
