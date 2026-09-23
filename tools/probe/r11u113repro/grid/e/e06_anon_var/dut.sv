module m(output logic [3:0] o);
  struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } x;
  assign x = '0;
  assign o = x;
endmodule
