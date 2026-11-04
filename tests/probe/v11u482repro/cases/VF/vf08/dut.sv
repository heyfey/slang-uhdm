// § cloneFixArrAggElemShared482 (struct also used as a module variable type)
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
  import a::*;
  u::op_t mv;
  int x;
  initial begin x = g(); mv.k = x; end
endmodule
