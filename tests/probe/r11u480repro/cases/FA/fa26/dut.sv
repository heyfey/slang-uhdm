// § fixArrLocalNamedAggElemTs480 (alias of an enum typedef)
module top;
  typedef enum { A, B } e_t;
  typedef e_t e2_t;
  function int f(int n);
    e2_t acc[2];
    acc[0] = B;
    return acc[0];
  endfunction
  int x;
  initial x = f(1);
endmodule
