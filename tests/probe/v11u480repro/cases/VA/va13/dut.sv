// § fixArrLocalNamedAggElemTs480 (nested struct typedef element)
module top;
  typedef struct { int k; } in_t;
  typedef struct { in_t i; int d; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].i.k = n;
    return acc[0].i.k;
  endfunction
  int x;
  initial x = f(1);
endmodule
