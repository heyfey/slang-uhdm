// § cloneHierIdxChainActual482 (acc[0][1].data[3:0] part-select after the member)
package u;
  typedef struct { int k; logic [7:0] data; } op_t;
  function int f(int n);
    op_t acc[2][2];
    acc[0][1].data[3:0] = n;
    return acc[1][1].data[7:4];
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
