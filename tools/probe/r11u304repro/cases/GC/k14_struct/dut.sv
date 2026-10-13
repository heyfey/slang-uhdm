// § genCaCastTdAliasScopedName304
module top (input logic [1:0] a, output logic [1:0] y);
  typedef struct packed { logic p; logic q; } s_t;
  if (1) begin : g
    assign y = s_t'(a);
  end
endmodule
