package pk; typedef struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } s_t; endpackage
module m(output logic [3:0] o);
  pk::s_t x;
  assign x = '0;
  assign o = x;
endmodule
