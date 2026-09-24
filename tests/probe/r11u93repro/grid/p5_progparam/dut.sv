// r11u92 p5 -- a PROGRAM parameter OVERRIDDEN at instantiation, read by both
// an nda and a written assign.
program prg #(parameter int P = 3) ();
  wire [31:0] w_nda = P;
  wire [31:0] w_ca;
  assign w_ca = P;
endprogram
module dut (output logic [31:0] o);
  prg #(.P(9)) u_p ();
  assign o = 32'd0;
endmodule
