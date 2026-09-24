module m(output logic [7:0] o);
  typedef struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } s_t;
  s_t [1:0] p;
  assign p = '0;
  assign o = p;
endmodule
