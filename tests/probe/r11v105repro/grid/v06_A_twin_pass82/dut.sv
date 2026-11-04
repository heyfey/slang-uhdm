// twin control of v05: no namesake collision
module sub ();
  module innerx (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod (input logic [3:0] a, output wire [3:0] b, output wire c, output wire [1:0] e);
  wire (strong0, weak1) [1:0] w = a[1:0];
  wire #2 d = a[3];
  assign (weak0, strong1) c = a[2];
  assign #1 b = a + 4'd1;
  assign e = w ^ {d, d};
endmodule
