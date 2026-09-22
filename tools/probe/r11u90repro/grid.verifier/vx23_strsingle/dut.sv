// v11u90 vx23 -- a STRENGTH-DECORATED declaration whose cell also carries the
// pass-82 drive fields via a separate strength CONTINUOUS ASSIGN in the same
// body, so both laws' grounds meet on one arm.
module sub (output logic [31:0] o);
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  wire [31:0] w_plain;
  assign (pull1, pull0) w_plain = 32'd11;
  assign o = w_plain;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
