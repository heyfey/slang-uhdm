// § fixArrLocalNamedAggElemTs480 (declaring module under a generate loop)
module sub;
  typedef struct packed { logic [1:0] a; logic [1:0] b; } op_t;
  function automatic logic [3:0] f(input logic [1:0] n);
    op_t acc[2];
    acc[0].a = n;
    acc[0].b = ~n;
    return acc[0];
  endfunction
  logic [3:0] x;
  assign x = f(2'd1);
endmodule
module top;
  for (genvar i = 0; i < 2; i++) begin : g
    sub s();
  end
endmodule
