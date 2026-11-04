// § fixArrLocalNamedAggElemTs480 (module function, two-dimension struct array)
module top;
  typedef struct { int k; bit [7:0] data; } op_t;
  function int f(int n);
    op_t acc[2][3];
    acc[0][1].k = n;
    return acc[0][1].k;
  endfunction
  int x;
  initial x = f(1);
endmodule
