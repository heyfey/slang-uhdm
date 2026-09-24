// r11u92 n7 -- the strength re-declaration on an INPUT non-ANSI port.
module sub (i, p);
  input [31:0] i;
  output [31:0] p;
  wire (strong1, weak0) [31:0] i = 32'd12;
  wire [31:0] p = 32'd13;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] q;
  sub u_s (.i(32'd1), .p(o));
  assign q = 32'd0;
endmodule
