// r11u88 q11 -- the MODULE twin of q8: a net declaration carrying a DRIVE
// STRENGTH.  The producer's decline is `compileNetDeclaration`'s, which every
// home shares -- does OUR module home mint a cell for it?
module sub (output logic [31:0] o);
  wire [31:0] w_plain = 32'd11;
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  assign o = w_plain;
endmodule

module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
