// v11u90 vx19 -- the dropped name is read PROCEDURALLY (always_comb), which
// is NOT an implicit-net context.
module sub (output logic [31:0] o);
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  wire [31:0] w_plain = 32'd11;
  logic [31:0] r;
  always_comb r = w_str ^ w_plain;
  assign o = r;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
