// § cloneHierIdxChainActual482 (variable indexes in two dimensions)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int i, int j);
    op_t acc[2][3];
    acc[i][j].k = 1;
    return acc[j][i].data;
  endfunction
endpackage
package a;
  import u::*;
  function int g(); return f(0, 1); endfunction
endpackage
module top;
  import a::*;
  int x;
  initial x = g();
endmodule
