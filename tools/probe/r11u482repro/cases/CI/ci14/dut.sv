// § cloneHierIdxChainActual482 (two-dimension array with a variable index)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[2][3];
    int i;
    i = 1;
    acc[i][n].k = 2;
    return acc[0][i].data;
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
