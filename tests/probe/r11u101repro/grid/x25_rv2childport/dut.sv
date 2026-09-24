// LAW B: the DROPPED duplicate instantiates a PORTED file-scope leaf nothing else uses
module leaf (output logic l); assign l = 1'b0; endmodule
module amod ();
  module innermod (); wire ra; endmodule
endmodule
module bmod ();
  module innermod (); wire rb; leaf u_l (.l(rb)); endmodule
endmodule
module dut (output logic [31:0] o);
  amod u_a ();
  bmod u_b ();
  assign o = 32'd0;
endmodule
