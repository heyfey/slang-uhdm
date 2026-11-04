// § cloneFixArrAggElemShared482 (fixed packed struct array local)
package u;
  typedef struct packed { logic [3:0] k; logic [3:0] data; } op_t;
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
  int x;
  initial x = g();
endmodule
