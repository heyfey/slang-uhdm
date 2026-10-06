// § castStructInstCopy260 (a signed struct with an enum member and a typedef'd vector member)
module m (input logic [7:0] w, output logic [3:0] o);
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef logic [3:0] n_t;
  typedef struct packed signed { e_t e; n_t n; logic [1:0] z; } t_t;
  t_t r;
  assign r = t_t'(w);
  assign o = r.n;
endmodule
module top;
  logic [7:0] w; logic [3:0] o;
  m u (.w(w), .o(o));
endmodule
