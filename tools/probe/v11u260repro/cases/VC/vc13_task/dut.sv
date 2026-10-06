// § castStructInstCopy260 (a cast inside a module task, abstaining)
module m (input logic [7:0] w, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  task automatic t(input logic [7:0] x, output logic [3:0] y);
    t_t r;
    r = t_t'(x);
    y = r.a;
  endtask
  always_comb t(w, o);
endmodule
module top;
  logic [7:0] w; logic [3:0] o;
  m u (.w(w), .o(o));
endmodule
