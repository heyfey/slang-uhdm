module m(output logic [4:0] o);
  typedef struct packed { struct packed { enum logic [1:0] {A, B} e; logic c; } in; logic [1:0] b; } s_t;
  s_t x;
  assign x = '0;
  assign o = x;
endmodule
