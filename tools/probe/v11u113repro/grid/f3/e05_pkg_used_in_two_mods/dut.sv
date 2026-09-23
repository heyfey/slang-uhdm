package pk; typedef struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } s_t; endpackage
module c(output pk::s_t o);
  assign o.e = pk::B;
  assign o.b = '0;
endmodule
module m(output logic [3:0] o);
  pk::s_t x;
  c u(.o(x));
  assign o = x;
endmodule
