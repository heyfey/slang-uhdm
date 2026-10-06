// § castStructInstCopy260 (the cast in a module function)
module m (input logic [31:0] w, output logic [5:0] o);
  typedef struct packed {
    logic [25:0] a;
    logic [5:0]  x;
  } t_t;
  t_t rd, wd;
  function automatic t_t f(logic [31:0] v);
    return t_t'(v);
  endfunction
  assign rd.a = '0;
  assign wd = f(w);
  assign o = wd.x;
endmodule
module top;
  logic [31:0] w; logic [5:0] o;
  m u (.w(w), .o(o));
endmodule
