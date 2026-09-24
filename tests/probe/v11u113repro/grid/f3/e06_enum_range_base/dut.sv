module m(output logic [3:0] o);
  typedef struct packed { enum bit [2:0] {A, B, C} e; logic b; } s_t;
  s_t x;
  assign x = '0;
  assign o = x;
endmodule
