package pkg;
  typedef logic [7:0] u8_t;
endpackage
module top import pkg::*; (output logic [7:0] o);
  u8_t a = 8'h7;
  assign o = a;
endmodule
