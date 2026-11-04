// § fixArrLocalNamedAggElemTs480 (module function, alias of a struct typedef)
module top;
  typedef struct { int k; bit [7:0] data; } op_t;
  typedef op_t op2_t;
  function int f(int n);
    op2_t acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
  int x;
  initial x = f(1);
endmodule
