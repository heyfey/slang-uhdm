// § caFoldParentUnboundLhs267
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module m #(parameter int W = 4) (output s_t [1:0] o);
  assign o[1].a = W + 1;
  assign o[0].b = {W{1'b0}};
  assign o[0].a = 4'(W);
endmodule
module top(output s_t [1:0] o);
  m u(.o(o));
endmodule
