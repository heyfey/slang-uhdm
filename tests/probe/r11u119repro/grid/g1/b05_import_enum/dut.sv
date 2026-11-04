package pkg;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top import pkg::*; (output logic [1:0] o);
  e_t s = B;
  assign o = s;
endmodule
