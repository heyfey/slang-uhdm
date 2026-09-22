// v11u90 vx20 -- CONTROL for the implicit-net mint: the SAME body, the same
// reference, but the declaration carries NO strength.  Nothing is dropped
// and nothing is minted.
module sub (output logic [31:0] o);
  wire [31:0] w_str = 32'd12;
  wire [31:0] w_plain = 32'd11;
  assign o = w_plain ^ w_str;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
