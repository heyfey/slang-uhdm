// § caFoldParentUnboundLhs267
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module m #(parameter int W = 4) (output s_t o);
  assign o.a = {W{1'b1}};
  assign o.b = {2{2'b10}};
endmodule
module top(output s_t o);
  m u(.o(o));
endmodule
