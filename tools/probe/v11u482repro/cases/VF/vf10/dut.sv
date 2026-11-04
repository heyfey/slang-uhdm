// § cloneFixArrAggElemShared482 (packed struct with a named enum member)
package u;
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef struct packed { e_t e; logic [5:0] d; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].e = B;
    return acc[1].d + n;
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
