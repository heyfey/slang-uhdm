// r11u90 u2 -- LAW A: the MODULE twin of u1, no initializer.
module sub (output logic [31:0] o);
  wire [31:0] w_plain;
  wire (strong1, weak0) [31:0] w_ni;
  assign w_plain = 32'd11;
  assign o = w_plain;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
