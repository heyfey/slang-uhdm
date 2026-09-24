module m(input struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; } i, output logic [3:0] o);
  assign o = i;
endmodule
