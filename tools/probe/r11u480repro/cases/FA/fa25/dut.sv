// § fixArrLocalNamedAggElemTs480 (typedef declared in the function)
module top;
  function int f(int n);
    typedef struct { int k; int data; } op_t;
    op_t acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
  int x;
  initial x = f(1);
endmodule
