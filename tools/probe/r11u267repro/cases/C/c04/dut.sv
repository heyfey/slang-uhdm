// § caFoldParentUnboundLhs267
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module m #(parameter int W = 4) (output s_t o, output logic [3:0] p);
  assign o.a = {W{1'b1}}, p = {W{1'b0}};
endmodule
module top(output s_t o, output logic [3:0] p, output s_t o2, output logic [5:0] p2);
  m u(.o(o), .p(p));
  m #(.W(6)) u2(.o(o2), .p(p2));
endmodule
