// v11u90 vx2 -- the dropped net is READ inside its OWN module body.
module sub (output logic [31:0] o);
  wire [31:0] w_plain = 32'd11;
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  assign o = w_plain ^ w_str;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
