// § fixArrLocalNamedAggElemTs480 (out-of-body method of a class in a module)
module top;
  typedef struct { int k; int d; } op_t;
  class C;
    extern function int f(int n);
  endclass
  function int C::f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
  C c;
endmodule
