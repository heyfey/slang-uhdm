// § fixArrLocalNamedAggElemTs480 (explicit import of the typedef)
package p;
  typedef struct { int k; int data; } op_t;
endpackage
module top;
  import p::op_t;
  function int f(int n);
    op_t acc[2];
    acc[1].data = n;
    return acc[1].data;
  endfunction
  int x;
  initial x = f(3);
endmodule
