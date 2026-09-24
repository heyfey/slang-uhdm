// v11u90 vx1 -- LAW A in the TOP module itself (def AND elab of the top).
module dut (output logic [31:0] o);
  wire [31:0] w_plain = 32'd11;
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  assign o = w_plain;
endmodule
