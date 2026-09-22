module innermod (); wire [31:0] f = 32'd9; endmodule
module amod ();
  module innermod (); wire ra; endmodule
endmodule
module bmod ();
  module innermod (output logic rb); assign rb = 1'b0; endmodule
endmodule
module dut (output logic [31:0] o);
  amod u_a ();
  bmod u_b ();
  innermod u_f ();
  assign o = 32'd0;
endmodule
