module m(output logic [3:0] o);
  typedef struct packed { enum logic [1:0] {A=1, B=3} e; logic [1:0] b; } s_t;
  s_t x;
  assign x = '0;
  assign o = x;
endmodule
