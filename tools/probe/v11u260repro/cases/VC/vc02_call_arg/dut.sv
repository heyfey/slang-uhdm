// § castStructInstCopy260 (the cast as a user function's argument in a continuous assignment)
module m (input logic [31:0] w, output logic [5:0] o);
  typedef struct packed { logic [25:0] a; logic [5:0] x; } t_t;
  function automatic logic [5:0] f(t_t v);
    return v.x;
  endfunction
  assign o = f(t_t'(w));
endmodule
module top;
  logic [31:0] w; logic [5:0] o;
  m u (.w(w), .o(o));
endmodule
