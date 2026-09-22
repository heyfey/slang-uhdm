// v11u90 vx22 -- highz strengths, which the LRM restricts to one side.
module sub (output logic [31:0] o);
  wire (highz1, strong0) [31:0] w_hz1 = 32'd12;
  wire (strong1, highz0) [31:0] w_hz0 = 32'd13;
  wire [31:0] w_plain = 32'd11;
  assign o = w_plain;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
