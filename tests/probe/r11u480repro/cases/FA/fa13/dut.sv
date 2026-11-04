// § fixArrLocalNamedAggElemTs480 (package function, scoped p::op_t)
package p;
  typedef struct { int k; bit [7:0] data; } op_t;
endpackage
module top;
  function int f(int n);
    p::op_t acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
  int x;
  initial x = f(1);
endmodule
