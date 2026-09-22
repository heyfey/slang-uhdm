module amod ();
  module innermod (); wire [31:0] ra = 32'd1; endmodule
  innermod u_i ();
endmodule
module bmod ();
  module innermod (); wire [7:0] rb = 8'd2; endmodule
  innermod u_i ();
endmodule
module dut (output logic [31:0] o);
  amod u_a ();
  bmod u_b ();
  assign o = 32'd0;
endmodule
