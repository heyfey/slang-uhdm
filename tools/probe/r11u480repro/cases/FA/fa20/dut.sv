// § fixArrLocalNamedAggElemTs480 (program function)
program prg;
  typedef struct { int k; int data; } op_t;
  function int f(int n);
    op_t acc[2];
    acc[0].k = n;
    return acc[0].k;
  endfunction
  int x;
  initial x = f(1);
endprogram
module top;
  prg p();
endmodule
