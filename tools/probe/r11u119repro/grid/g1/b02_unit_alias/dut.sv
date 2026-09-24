typedef logic [7:0] u8_t;
module top(output logic [7:0] o);
  u8_t a = 8'h3;
  assign o = a;
endmodule
