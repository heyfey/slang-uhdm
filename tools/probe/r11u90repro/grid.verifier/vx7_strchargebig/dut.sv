// v11u90 vx7 -- CHARGE strengths large/medium beside a plain trireg.
module sub (output logic [31:0] o);
  trireg (large) [31:0] t_large;
  trireg (medium) [31:0] t_med;
  trireg [31:0] t_plain;
  wire [31:0] w_plain = 32'd15;
  assign o = w_plain;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
