// § castStructInstCopy260 (an unpacked struct target (abstains))
module m (input logic [5:0] w, output logic [5:0] o);
  typedef struct { logic [5:0] x; } t_t;
  t_t wd;
  always_comb wd = t_t'('{x: w});
  assign o = wd.x;
endmodule
module top;
  logic [5:0] w, o;
  m u (.w(w), .o(o));
endmodule
