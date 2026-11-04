// § fixArrLocalNamedAggElemTs480 (module function, enum typedef)
module top;
  typedef enum { A, B } e_t;
  function int f(int n);
    e_t acc[2];
    acc[0] = B;
    return acc[0];
  endfunction
  int x;
  initial x = f(1);
endmodule
