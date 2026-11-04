// § fixArrLocalNamedAggElemTs480 (two declarators and an initializer)
module top;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[2], bcc[3];
    op_t ccc[2] = '{'{1, 2}, '{3, 4}};
    acc[0].k = n;
    bcc[2] = acc[0];
    return bcc[2].k + ccc[1].data;
  endfunction
  int x;
  initial x = f(1);
endmodule
