// § castStructInstCopy260 (a struct holding a packed union member)
module m (input logic [31:0] w, output logic [5:0] o);
  typedef union packed { logic [5:0] p; logic [5:0] q; } u_t;
  typedef struct packed {
    logic [25:0] a;
    u_t          x;
  } t_t;
  t_t rd, wd;
  assign rd.x.p = '0;
  assign wd = t_t'(w);
  assign o = wd.x.q;
endmodule
module top;
  logic [31:0] w; logic [5:0] o;
  m u (.w(w), .o(o));
endmodule
