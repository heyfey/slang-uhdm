// § castStructInstCopy260 (the cast one for-generate level down)
module m (input logic [7:0] w, output logic [3:0] o [2]);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  for (genvar i = 0; i < 2; i++) begin : g
    t_t r;
    assign r = t_t'(w);
    assign o[i] = r.a;
  end
endmodule
module top;
  logic [7:0] w; logic [3:0] o [2];
  m u (.w(w), .o(o));
endmodule
