module top(output logic [7:0] o);
  typedef logic [7:0] u8_t;
  typedef u8_t v8_t;
  v8_t a = 8'h3;
  assign o = a;
endmodule
