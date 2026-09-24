module m(output logic [1:0] o);
  typedef struct { enum logic [1:0] {A, B, C} e; logic [1:0] b; } s_t;
  s_t x;
  assign x.b = '0;
  assign o = x.b;
endmodule
