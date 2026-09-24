package pkg;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top  (output logic [1:0] o);
  pkg::e_t a = pkg::B;
  assign o = a;
endmodule
