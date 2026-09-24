package pkg;
  typedef logic [7:0] u8_t;
endpackage
module top(output logic [7:0] o);
  pkg::u8_t a = 8'h3;
  pkg::u8_t b = 8'h4;
  pkg::u8_t c;
  assign c = a;
  assign o = c ^ b;
endmodule
