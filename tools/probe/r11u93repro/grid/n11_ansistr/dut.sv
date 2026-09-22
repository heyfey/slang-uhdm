// r11u92 n11 -- THE CONTROL: an ANSI port beside a strength-decorated body net.
module sub (output [31:0] o);
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  assign o = w_str;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
