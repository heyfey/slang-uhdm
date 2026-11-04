// § fixArrLocalNamedAggElemTs480 (array local declared inside a begin block of the function)
module top;
  typedef struct { int k; int d; } op_t;
  function int f(int n);
    begin : blk
      op_t acc[2];
      acc[0].k = n;
      return acc[0].k;
    end
  endfunction
  int x;
  initial x = f(1);
endmodule
