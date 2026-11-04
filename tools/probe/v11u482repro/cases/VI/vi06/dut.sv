// § cloneHierIdxChainActual482 (two-dimension array called only from the module (no clone))
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[2][3];
    acc[0][1].k = n;
    return acc[1][2].data;
  endfunction
endpackage
module top;
  import u::*;
  int x;
  initial x = f(1);
endmodule
