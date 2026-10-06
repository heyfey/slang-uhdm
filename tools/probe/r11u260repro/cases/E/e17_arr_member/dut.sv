// § castStructInstCopy260 (a struct holding a packed array of structs)
module m (input logic [31:0] w, output logic [3:0] o);
  typedef struct packed { logic [1:0] k; logic [1:0] v; } in_t;
  typedef struct packed {
    logic [15:0] a;
    in_t [3:0]   x;
  } t_t;
  t_t rd, wd;
  assign rd.x[1].k = '0;
  assign wd = t_t'(w);
  assign o = wd.x[2];
endmodule
module top;
  logic [31:0] w; logic [3:0] o;
  m u (.w(w), .o(o));
endmodule
