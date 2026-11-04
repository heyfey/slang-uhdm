module top(output logic [7:0] o);
  typedef logic [7:0] u8_t;
  u8_t a = 8'h5C;
  assign o = a;
endmodule
