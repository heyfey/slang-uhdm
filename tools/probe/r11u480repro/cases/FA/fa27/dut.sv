// § fixArrLocalNamedAggElemTs480 (packed struct, packed dimension on the element)
module top;
  typedef struct packed { logic [3:0] k; } op_t;
  function int f(int n);
    op_t [1:0] acc[2];
    acc[0][1].k = n;
    return acc[0][1].k;
  endfunction
  int x;
  initial x = f(1);
endmodule
