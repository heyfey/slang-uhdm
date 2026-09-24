module top(output logic [1:0] o);
  typedef enum logic [1:0] {A, B, C} e_t;
  e_t s = B;
  assign o = s;
endmodule
