// § fixArrLocalNamedAggElemTs480 (two top modules, the declaring one uninstantiated)
module other;
  typedef struct { int k; int d; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
  int x;
  initial x = f(1);
endmodule
module top;
  int y;
endmodule
