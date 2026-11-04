// § castStructInstCopy260 (the casting module instantiated inside a for-generate)
module m (input logic [7:0] w, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  t_t r;
  always_comb r = t_t'(w);
  assign o = r.a;
endmodule
module top;
  logic [7:0] w; logic [3:0] o [2];
  for (genvar i = 0; i < 2; i++) begin : g
    m u (.w(w), .o(o[i]));
  end
endmodule
