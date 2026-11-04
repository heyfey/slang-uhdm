// § cloneHierIdxChainActual482 (array of int arrays inside a struct array acc[0].arr[1][0])
package u;
  typedef struct { int arr[2][2]; int z; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].arr[1][0] = n;
    return acc[1].arr[0][1];
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
