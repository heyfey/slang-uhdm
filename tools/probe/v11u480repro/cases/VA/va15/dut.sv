// § fixArrLocalNamedAggElemTs480 (typedef used by a module array variable and a function local)
module top;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
  op_t mem[2];
  function automatic logic [7:0] f(input logic [3:0] n);
    op_t acc[2];
    acc[0].a = n;
    acc[0].b = n;
    return acc[0];
  endfunction
  assign mem[0] = f(4'h3);
  assign mem[1] = f(4'h4);
endmodule
