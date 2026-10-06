// § castStructInstCopy260 (the cast in an always_ff nonblocking assignment)
module m (input logic clk, input logic [31:0] w, output logic [5:0] o);
  typedef struct packed { logic [25:0] a; logic [5:0] x; } t_t;
  t_t r;
  always_ff @(posedge clk) r <= t_t'(w);
  assign o = r.x;
endmodule
module top;
  logic clk; logic [31:0] w; logic [5:0] o;
  m u (.clk(clk), .w(w), .o(o));
endmodule
