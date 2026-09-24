module m(output logic [3:0] o);
  typedef struct packed { enum logic [1:0] {A, B} e; enum logic [1:0] {C, D} f; } s_t;
  s_t x;
  assign x = '0;
  assign o = x;
endmodule
