// § fixArrLocalNamedAggElemTs480 (enum with a logic base)
module top;
  typedef enum logic [1:0] { A, B, C } e_t;
  function int f(int n);
    e_t acc[3];
    acc[0] = C;
    return acc[0];
  endfunction
  int x;
  initial x = f(1);
endmodule
