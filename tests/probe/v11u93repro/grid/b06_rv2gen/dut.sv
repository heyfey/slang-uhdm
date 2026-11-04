module amod ();
  module innermod (); wire ra; endmodule
endmodule
module bmod ();
  module innermod (output logic rb); assign rb = 1'b1; endmodule
  wire g1;
  if (1) begin : g
    innermod u_i (.rb(g1));
  end
endmodule
module dut (output logic [31:0] o);
  amod u_a ();
  bmod u_b ();
  assign o = 32'd0;
endmodule
