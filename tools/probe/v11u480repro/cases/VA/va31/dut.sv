// § fixArrLocalNamedAggElemTs480 (module typedef shadowing a wildcard-imported typedef of the same name)
package p;
  typedef struct { int k; } op_t;
endpackage
module top;
  import p::*;
  typedef struct { int k; int d; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].d = n;
    return acc[0].d;
  endfunction
  int x;
  initial x = f(1);
endmodule
