// § fixArrLocalNamedAggElemTs480 (one typedef, local arrays in two functions)
module top;
  typedef struct { int k; int d; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
  function int g(int n);
    op_t buf2[3];
    buf2[2].d = n;
    return buf2[2].d;
  endfunction
  int x, y;
  initial begin x = f(1); y = g(2); end
endmodule
