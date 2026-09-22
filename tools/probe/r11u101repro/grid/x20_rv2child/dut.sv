// LAW B: the DROPPED duplicate instantiates a file-scope leaf nothing else uses
module leaf (); wire l; endmodule
module amod ();
  module innermod (); wire ra; endmodule
endmodule
module bmod ();
  module innermod (); leaf u_l (); endmodule
endmodule
module dut (output logic [31:0] o);
  amod u_a ();
  bmod u_b ();
  assign o = 32'd0;
endmodule
