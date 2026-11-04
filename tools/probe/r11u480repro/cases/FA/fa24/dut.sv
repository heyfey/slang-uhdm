// § fixArrLocalNamedAggElemTs480 (two instances of the declaring module)
module sub;
  typedef struct { int k; int data; } op_t;
  function automatic int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
  int x;
  initial x = f(1);
endmodule
module top;
  sub a();
  sub b();
endmodule
