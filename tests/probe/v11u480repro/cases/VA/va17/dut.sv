// § fixArrLocalNamedAggElemTs480 (static local array in a static function)
module top;
  typedef struct { int k; int d; } op_t;
  function static int f(int n);
    static op_t acc[2];
    acc[0].k += n;
    return acc[0].k;
  endfunction
  int x;
  initial x = f(1);
endmodule
