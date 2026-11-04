// § fixArrLocalNamedAggElemTs480 (package function, package struct typedef)
package p;
  typedef struct { int k; bit [7:0] data; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f(1);
endmodule
