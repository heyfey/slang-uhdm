// § cloneHierIdxChainActual482 (acc[0][1].i.data, both chain laws)
package u;
  typedef struct { int k; int data; } in_t;
  typedef struct { in_t i; int z; } op_t;
  function int f(int n);
    op_t acc[2][2];
    acc[0][1].z = n;
    return acc[1][0].i.data;
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
