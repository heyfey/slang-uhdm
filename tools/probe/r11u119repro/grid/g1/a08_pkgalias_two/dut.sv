package pkg;
  typedef logic [7:0] u8_t;
endpackage
module top(output logic [7:0] o);
  pkg::u8_t a = 8'h1, b = 8'h2;
  assign o = a ^ b;
endmodule
