// v11u90 vx6 -- other NET TYPES carrying a drive strength.
module sub (output logic [31:0] o);
  wand (strong1, weak0) [31:0] w_wand = 32'd12;
  wor  (pull1, pull0)   [31:0] w_wor  = 32'd13;
  tri0 [31:0] t0_plain = 32'd14;
  wire [31:0] w_plain = 32'd15;
  assign o = w_plain ^ t0_plain;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
