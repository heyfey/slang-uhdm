// § cloneFixArrAggElemShared482 (module importing the package function directly)
package u;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[1].data;
  endfunction
endpackage
module top;
  import u::*;
  int x;
  initial x = f(1);
endmodule
