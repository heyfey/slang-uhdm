package pkg;
  typedef logic [7:0] u8_t;
  typedef u8_t v8_t;
endpackage
module top import pkg::*; (output logic [7:0] o);
  v8_t a = 8'h3;
  assign o = a;
endmodule
