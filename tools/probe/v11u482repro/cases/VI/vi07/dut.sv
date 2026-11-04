// § cloneHierIdxChainActual482 (struct with a two-dimension array member s.arr[0][1])
package u;
  typedef struct { int arr[2][2]; int z; } op_t;
  function int f(int n);
    op_t s;
    s.arr[0][1] = n;
    return s.arr[1][0];
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
