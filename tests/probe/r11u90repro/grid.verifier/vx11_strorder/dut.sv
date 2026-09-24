// v11u90 vx11 -- the dropped declaration sits BETWEEN two kept ones: net and
// cell ORDER must close over the hole the same way golden's does.
module sub (output logic [31:0] o);
  wire [31:0] w_a = 32'd11;
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  wire [31:0] w_c = 32'd13;
  assign o = w_a ^ w_c;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
