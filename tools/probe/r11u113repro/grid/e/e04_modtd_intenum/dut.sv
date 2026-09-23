module m(output logic [33:0] o);
  typedef struct packed { enum {A, B, C} e; logic [1:0] b; } s_t;
  s_t x;
  assign x = '0;
  assign o = x;
endmodule
