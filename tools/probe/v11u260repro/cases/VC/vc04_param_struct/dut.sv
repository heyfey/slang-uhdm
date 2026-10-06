// § castStructInstCopy260 (a struct whose member width is a module parameter, two instances with different widths)
module m #(parameter int W = 4) (input logic [31:0] w, output logic [W-1:0] o);
  typedef struct packed { logic [W-1:0] x; logic [3:0] y; } t_t;
  t_t r;
  assign r = t_t'(w);
  assign o = r.x;
endmodule
module top;
  logic [31:0] w; logic [3:0] o4; logic [7:0] o8;
  m u4 (.w(w), .o(o4));
  m #(.W(8)) u8 (.w(w), .o(o8));
endmodule
