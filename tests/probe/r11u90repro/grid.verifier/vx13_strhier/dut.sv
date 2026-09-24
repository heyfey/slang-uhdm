// v11u90 vx13 -- a HIERARCHICAL reference reaches the dropped net.
module sub (output logic [31:0] o);
  wire [31:0] w_plain = 32'd11;
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  assign o = w_plain;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] q;
  sub u_s (.o(q));
  assign o = q ^ dut.u_s.w_str;
endmodule
