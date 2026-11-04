// § fixArrLocalNamedAggElemTs480 ($unit struct typedef, declaring module instantiated twice)
typedef struct packed { logic [3:0] a; logic [3:0] b; } op_t;
module sub;
  function automatic logic [7:0] f(input logic [3:0] n);
    op_t acc[2];
    acc[0].a = n;
    acc[0].b = n;
    return acc[0];
  endfunction
  logic [7:0] x;
  initial x = f(4'h1);
endmodule
module top;
  sub a();
  sub b();
endmodule
