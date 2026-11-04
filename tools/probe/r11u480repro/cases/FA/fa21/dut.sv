// § fixArrLocalNamedAggElemTs480 (function in a generate block)
module top;
  typedef struct { int k; int data; } op_t;
  if (1) begin : g
    function int f(int n);
      op_t acc[2];
      acc[0].k = n;
      return acc[0].k;
    endfunction
    int x;
    initial x = f(1);
  end
endmodule
