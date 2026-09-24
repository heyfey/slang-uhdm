module m(output logic [3:0] o);
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef struct packed { e_t e; logic [1:0] b; } s_t;
  s_t x;
  assign x = '0;
  assign o = x;
endmodule
