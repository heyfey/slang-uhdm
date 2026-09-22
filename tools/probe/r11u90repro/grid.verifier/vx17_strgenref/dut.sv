// v11u90 vx17 -- the dropped name is declared at module level and READ from
// inside a generate block of the same module.
module sub (output logic [31:0] o);
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  wire [31:0] w_plain = 32'd11;
  if (1) begin : g
    wire [31:0] r = w_str ^ w_plain;
  end
  assign o = g.r;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
