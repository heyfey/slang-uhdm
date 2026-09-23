module m(output logic [1:0] o);
  typedef union packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } u_t;
  u_t x;
  assign x = '0;
  assign o = x;
endmodule
