// r11u92 n9 -- the non-ANSI port strength declaration in a PROGRAM home.
program prg (o, p);
  output [31:0] o;
  output [31:0] p;
  wire (strong1, weak0) [31:0] o = 32'd12;
  wire [31:0] p = 32'd13;
endprogram
module dut (output logic [31:0] o);
  logic [31:0] q;
  prg u_p (.o(o), .p(q));
endmodule
