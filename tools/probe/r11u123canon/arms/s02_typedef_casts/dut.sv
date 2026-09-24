module top(input logic [7:0] i, output logic [7:0] o);
  typedef logic [7:0] byte_t;
  byte_t a, b, c;
  assign a = byte_t'(i);
  assign b = byte_t'(a);
  assign c = byte_t'(b);
  assign o = c;
endmodule
