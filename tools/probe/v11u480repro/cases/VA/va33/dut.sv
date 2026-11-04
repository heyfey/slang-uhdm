// § fixArrLocalNamedAggElemTs480 (array local and a scalar local of the same typedef)
module top;
  typedef struct { int k; int d; } op_t;
  function int f(int n);
    op_t one;
    op_t acc[2];
    one.k = n;
    acc[1] = one;
    return acc[1].k;
  endfunction
  int x;
  initial x = f(1);
endmodule
