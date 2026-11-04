// § castStructInstCopy260 (the cast in a concatenation and in a ternary branch)
module m (input logic [7:0] w, input logic s, output logic [9:0] o, output logic [7:0] p);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  t_t r;
  assign o = {t_t'(w), 2'b01};
  assign r = s ? t_t'(w) : t_t'(~w);
  assign p = r;
endmodule
module top;
  logic [7:0] w; logic s; logic [9:0] o; logic [7:0] p;
  m u (.w(w), .s(s), .o(o), .p(p));
endmodule
