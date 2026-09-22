module amod ();
  module innermod (); wire ra; endmodule
endmodule
module bmod ();
  module innermod (output logic rb); assign rb = 1'b1; endmodule
  wire [1:0] g1;
  innermod u_i [1:0] (.rb(g1));
endmodule
module dut (output logic [31:0] o);
  amod u_a ();
  bmod u_b ();
  assign o = 32'd0;
endmodule
