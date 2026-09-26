// § castRhsClonePerInst176
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module sub (input logic [7:0] i, output s_t o);
  assign o.a = 4'(i);
  assign o.b = 4'(i >> 4);
endmodule
module top (input logic [7:0] x, output s_t o1, output s_t o2);
  sub u1 (.i(x), .o(o1));
  sub u2 (.i(x), .o(o2));
endmodule
