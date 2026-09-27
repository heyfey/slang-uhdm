package p;
  typedef struct packed { int unsigned a; bit f1; } u_t;
  function automatic u_t mk(); u_t c; c.a = 7; c.f1 = 1'b1; return c; endfunction
  function automatic int unsigned get(input u_t u); return u.a; endfunction
  localparam u_t U = mk();
endpackage
module top(output int unsigned o);
  assign o = p::get(p::U);
endmodule
