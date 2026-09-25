// § uncaughtExitsReject160
module top (input logic a, output logic o);
  typedef enum logic { \E#1 , E2 } e_t;
  e_t v;
  assign v = \E#1 ;
  assign o = a;
endmodule
