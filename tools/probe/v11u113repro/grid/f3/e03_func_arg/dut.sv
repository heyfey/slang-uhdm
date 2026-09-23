module m(output logic [3:0] o);
  typedef struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } s_t;
  function automatic s_t f(input logic [1:0] v);
    s_t r;
    r.e = C;
    r.b = v;
    return r;
  endfunction
  assign o = f(2'b1);
endmodule
