// § fixArrLocalNamedAggElemTs480 (parameterized struct width, two instances with different overrides)
module sub #(parameter int W = 4);
  typedef struct packed { logic [W-1:0] a; logic b; } op_t;
  function automatic logic [W:0] f(input logic [W-1:0] n);
    op_t acc[2];
    acc[0].a = n;
    acc[0].b = 1'b1;
    return acc[0];
  endfunction
  logic [W:0] x;
  assign x = f('0);
endmodule
module top;
  sub #(.W(4)) a();
  sub #(.W(8)) b();
endmodule
